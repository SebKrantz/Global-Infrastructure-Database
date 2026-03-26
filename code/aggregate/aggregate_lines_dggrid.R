#' Bounding box (WGS84) covering Natural Earth polygons for \code{inc_ctry$iso3c}.
#'
#' @return Named numeric \code{c(xmin, ymin, xmax, ymax)} or \code{NULL} if unavailable.
inc_ctry_bbox_for_lines <- function(inc_ctry) {
  if (!requireNamespace("rnaturalearth", quietly = TRUE)) {
    warning(
      "rnaturalearth not installed; Overture lines are not bbox-clipped (very heavy). ",
      "Install rnaturalearth for LMIC clipping."
    )
    return(NULL)
  }
  world <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")
  iso <- unique(inc_ctry$iso3c)
  hit <- world$iso_a3 %in% iso | world$adm0_a3 %in% iso
  sub <- world[hit, , drop = FALSE]
  if (!nrow(sub)) {
    warning("inc_ctry_bbox_for_lines: no Natural Earth match for inc_ctry iso3 codes")
    return(NULL)
  }
  u <- sf::st_union(sf::st_make_valid(sub))
  bb <- sf::st_bbox(u)
  c(xmin = unname(bb["xmin"]), ymin = unname(bb["ymin"]),
    xmax = unname(bb["xmax"]), ymax = unname(bb["ymax"]))
}

read_overture_transport_parquet <- function(path, bbox = NULL) {
  if (!file.exists(path)) {
    stop("read_overture_transport_parquet: file not found: ", path)
  }
  con <- DBI::dbConnect(duckdb::duckdb())
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE), add = TRUE)
  DBI::dbExecute(con, "INSTALL spatial; LOAD spatial;")
  path_esc <- gsub("'", "''", normalizePath(path, winslash = "/"))
  bbox_sql <- ""
  if (!is.null(bbox)) {
    bbox_sql <- sprintf(
      " AND ST_Intersects(geometry, ST_MakeEnvelope(%f, %f, %f, %f))",
      bbox[["xmin"]], bbox[["ymin"]], bbox[["xmax"]], bbox[["ymax"]]
    )
  }
  sql <- sprintf(
    "SELECT subtype, class, subclass, ST_AsWKB(geometry) AS geom_wkb
     FROM read_parquet('%s')
     WHERE geometry IS NOT NULL %s",
    path_esc,
    bbox_sql
  )
  raw_df <- DBI::dbGetQuery(con, sql)
  if (!nrow(raw_df)) {
    return(data.table::data.table(
      subtype = character(0),
      class = character(0),
      subclass = character(0)
    ))
  }
  geom_sfc <- sf::st_as_sfc(raw_df$geom_wkb, crs = 4326)
  g2 <- s2::as_s2_geography(geom_sfc)
  data.table::data.table(
    subtype = raw_df$subtype,
    class = raw_df$class,
    subclass = raw_df$subclass,
    geom = g2
  )
}

load_egm_lines_dt <- function(gpkg_path) {
  lay <- sf::st_layers(gpkg_path)
  parts <- list()
  for (L in lay$name) {
    sf_i <- tryCatch(
      sf::st_read(gpkg_path, layer = L, quiet = TRUE),
      error = function(e) NULL
    )
    if (is.null(sf_i) || nrow(sf_i) == 0L) next
    gt <- unique(as.character(sf::st_geometry_type(sf_i)))
    ok <- gt %in% c("LINESTRING", "MULTILINESTRING")
    if (!any(ok)) next
    sf_i <- sf::st_transform(sf_i, 4326)
    sf_i <- sf::st_cast(sf_i, "MULTILINESTRING", warn = FALSE)
    sf_i$line_class <- paste0("egm_", gsub("[^a-zA-Z0-9]+", "_", L))
    parts[[L]] <- sf_i
  }
  if (!length(parts)) {
    stop("load_egm_lines_dt: no line geometries in ", gpkg_path)
  }
  x <- do.call(rbind, parts)
  g <- s2::as_s2_geography(sf::st_geometry(x))
  data.table::data.table(line_class = x$line_class, geom = g)
}

load_ogim_pipeline_lines_dt <- function(gpkg_path) {
  if (!file.exists(gpkg_path)) {
    stop("load_ogim_pipeline_lines_dt: file not found: ", gpkg_path)
  }
  layer <- "Oil_Natural_Gas_Pipelines"
  lay <- sf::st_layers(gpkg_path)
  if (!layer %in% lay$name) {
    stop(
      "load_ogim_pipeline_lines_dt: layer ", layer, " not in ",
      gpkg_path, " (available: ", paste(lay$name, collapse = ", "), ")"
    )
  }
  sf_i <- sf::st_read(gpkg_path, layer = layer, quiet = TRUE)
  if (!nrow(sf_i)) {
    e <- s2::as_s2_geography(sf::st_sfc(crs = 4326))
    return(data.table::data.table(line_class = character(0), geom = e))
  }
  gt <- unique(as.character(sf::st_geometry_type(sf_i)))
  if (!any(gt %in% c("LINESTRING", "MULTILINESTRING"))) {
    stop("load_ogim_pipeline_lines_dt: layer ", layer, " has no line geometries")
  }
  sf_i <- sf::st_transform(sf_i, 4326)
  sf_i <- sf::st_zm(sf_i, drop = TRUE, warn = FALSE)
  sf_i <- sf::st_cast(sf_i, "MULTILINESTRING", warn = FALSE)
  sf_i$line_class <- "ogim_oil_natural_gas_pipelines"
  g <- s2::as_s2_geography(sf::st_geometry(sf_i))
  data.table::data.table(line_class = sf_i$line_class, geom = g)
}

tiered_line_union_dt <- function(x, group_cols = character(0)) {
  x <- data.table::as.data.table(x)
  if (!nrow(x)) {
    return(x)
  }
  if (!inherits(x$geom, "s2_geography")) {
    x$geom <- s2::as_s2_geography(x$geom)
  }
  # Do not use := for s2_geography columns (data.table corrupts them); lon/lat only.
  cent <- s2::s2_centroid(x$geom)
  x[, lon := floor(s2::s2_x(cent) * 4) / 4]
  x[, lat := floor(s2::s2_y(cent) * 4) / 4]
  byv <- c(group_cols, "lon", "lat")
  a <- x[, list(N = .N, geom = s2::s2_union_agg(geom)), by = c(byv)]
  a[, lon := as.integer(lon)][, lat := as.integer(lat)]
  a <- a[, list(N = sum(N), geom = s2::s2_union_agg(geom)), by = c(group_cols, "lon", "lat")]
  a[, lon := as.integer(lon / 4) * 4L][, lat := as.integer(lat / 4) * 4L]
  a <- a[, list(N = sum(N), geom = s2::s2_union_agg(geom)), by = c(group_cols, "lon", "lat")]
  a[, lon := as.integer(lon / 16) * 16L][, lat := as.integer(lat / 16) * 16L]
  a <- a[, list(N = sum(N), geom = s2::s2_union_agg(geom)), by = c(group_cols, "lon", "lat")]
  if (length(group_cols)) {
    a <- a[, list(N = sum(N), geom = s2::s2_union_agg(geom)), by = c(group_cols)]
  } else {
    a <- a[, list(N = sum(N), geom = s2::s2_union_agg(geom))]
  }
  a
}

hex_lengths_from_merged <- function(merged_dt, class_col, hex_s2_dt) {
  if (!nrow(merged_dt)) {
    out <- hex_s2_dt[, .(cell)]
    return(out)
  }
  labs <- as.character(merged_dt[[class_col]])
  col_names <- paste0(make.names(labs, unique = TRUE), "_len")
  out <- hex_s2_dt[, .(cell)]
  for (nm in col_names) {
    out[, (nm) := 0]
  }
  for (i in seq_len(nrow(merged_dt))) {
    gi <- merged_dt$geom[i]
    # Pre-filter hex candidates using bounding box before exact intersection
    bb <- s2::s2_bounds_rect(gi)
    cands <- which(s2::s2_intersects_box(
      hex_s2_dt$geometry,
      ymin = bb$lat_lo, xmin = bb$lng_lo,
      ymax = bb$lat_hi, xmax = bb$lng_hi
    ))
    if (!length(cands)) next
    wi_sub <- which(s2::s2_intersects(hex_s2_dt$geometry[cands], gi))
    wi <- cands[wi_sub]
    if (!length(wi)) next
    leni <- s2::s2_length(s2::s2_intersection(hex_s2_dt$geometry[wi], gi))
    data.table::set(out, i = wi, j = col_names[i], value = leni)
  }
  out
}

merge_line_hex_tables <- function(base, add) {
  if (!nrow(add)) return(base)
  if (!nrow(base)) return(add)
  collapse::join(base, add, on = "cell", how = "full")
}

#' Aggregate Overture transportation segments, EGM power lines, and OGIM pipelines
#' to hex cell line lengths.
#'
#' @param overture_transport_files Character vector of parquet paths (from
#'   \code{download_overture_transportation()}).
#' @param egm_grid_file Path to \code{grid.gpkg}.
#' @param ogim_gpkg_file Path to OGIM GeoPackage (e.g. \code{data/OGIM/OGIM.gpkg}).
#' @param wld12_grid_list Output of \code{build_wld12_dggrid()}.
#' @param inc_ctry Income-country table with \code{iso3c} (for bbox clip via rnaturalearth).
#' @return \code{data.table} with \code{cell} and \code{*_len} columns (meters).
aggregate_lines_to_hex <- function(
    overture_transport_files,
    egm_grid_file,
    ogim_gpkg_file,
    wld12_grid_list,
    inc_ctry) {

  hex_sf <- wld12_grid_list$hex_sf
  hex_s2 <- data.table::data.table(
    cell = hex_sf$cell,
    geometry = s2::as_s2_geography(sf::st_geometry(hex_sf))
  )

  bbox <- tryCatch(
    inc_ctry_bbox_for_lines(inc_ctry),
    error = function(e) {
      warning("inc_ctry_bbox_for_lines failed: ", conditionMessage(e))
      NULL
    }
  )

  road_p <- grep("road_segments", overture_transport_files, value = TRUE)[1]
  rail_p <- grep("rail_segments", overture_transport_files, value = TRUE)[1]
  water_p <- grep("water_segments", overture_transport_files, value = TRUE)[1]

  out <- hex_s2[, .(cell)]

  if (length(road_p) && nzchar(road_p)) {
    rd <- read_overture_transport_parquet(road_p, bbox)
    rd <- rd[subtype == "road"]
    if (nrow(rd)) {
      rd[, line_class := paste0("overture_road_", as.character(class))]
      rd_m <- tiered_line_union_dt(rd[, .(line_class, geom)], "line_class")
      out <- merge_line_hex_tables(out, hex_lengths_from_merged(rd_m, "line_class", hex_s2))
    }
  }

  if (length(rail_p) && nzchar(rail_p)) {
    rl <- read_overture_transport_parquet(rail_p, bbox)
    rl <- rl[subtype == "rail"]
    if (nrow(rl)) {
      rl[, line_class := "overture_rail"]
      rl_m <- tiered_line_union_dt(rl[, .(line_class, geom)], "line_class")
      out <- merge_line_hex_tables(out, hex_lengths_from_merged(rl_m, "line_class", hex_s2))
    }
  }

  if (length(water_p) && nzchar(water_p)) {
    wt <- read_overture_transport_parquet(water_p, bbox)
    wt <- wt[subtype == "water"]
    if (nrow(wt)) {
      wt[, line_class := "overture_water"]
      wt_m <- tiered_line_union_dt(wt[, .(line_class, geom)], "line_class")
      out <- merge_line_hex_tables(out, hex_lengths_from_merged(wt_m, "line_class", hex_s2))
    }
  }

  egm <- load_egm_lines_dt(egm_grid_file)
  egm_m <- tiered_line_union_dt(egm, "line_class")
  out <- merge_line_hex_tables(out, hex_lengths_from_merged(egm_m, "line_class", hex_s2))

  ogim <- load_ogim_pipeline_lines_dt(ogim_gpkg_file)
  if (nrow(ogim)) {
    ogim_m <- tiered_line_union_dt(ogim, "line_class")
    out <- merge_line_hex_tables(out, hex_lengths_from_merged(ogim_m, "line_class", hex_s2))
  }

  nlen <- grep("_len$", names(out), value = TRUE)
  for (nm in nlen) {
    out[, (nm) := data.table::fifelse(is.na(get(nm)), 0, get(nm))]
  }
  data.table::setorder(out, cell)
  out[]
}
