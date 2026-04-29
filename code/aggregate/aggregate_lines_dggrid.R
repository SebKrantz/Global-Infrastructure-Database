#' Line aggregation helpers for DGGRID hex cells.
#'
#' This file is sourced by the \code{targets} pipeline and used by the
#' \code{lines_hex_agg} target. The public entry point is
#' \code{aggregate_lines_to_hex()}, which reads Overture transportation
#' segments, EGM power-grid lines, and OGIM pipeline lines, then returns one
#' row per DGGRID cell with line-length columns in meters.
#'
#' The implementation keeps line geometry in \code{s2_geography} form so length
#' and intersection calculations use spherical geometry. Large line datasets are
#' first unioned by class in spatial tiers, then intersected with candidate hex
#' cells using a bounding-box pre-filter before exact \code{s2} intersections.
NULL

#' Bounding box (WGS84) covering Natural Earth polygons for \code{inc_ctry$iso3c}.
#'
#' The box is used to reduce the Overture transportation parquet scan to the
#' low- and middle-income country extent before individual line classes are
#' loaded into R.
#'
#' @param inc_ctry Income-country table with an \code{iso3c} column.
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

#' Read Overture transportation line features from one parquet file.
#'
#' DuckDB performs the parquet scan and optional spatial/class filters. Geometry
#' is returned as WKB and converted to \code{s2_geography} after the query, which
#' keeps the in-memory object small and suitable for later \code{s2} operations.
#'
#' @param path Path to an Overture transportation parquet file, such as
#'   \code{road_segments.parquet}, \code{rail_segments.parquet}, or
#'   \code{water_segments.parquet}.
#' @param bbox Optional WGS84 bounding box from \code{inc_ctry_bbox_for_lines()}.
#' @param class_filter Optional single Overture \code{class} value used when
#'   processing roads class-by-class.
#' @return \code{data.table} with \code{subtype}, \code{class},
#'   \code{subclass}, and \code{geom} (\code{s2_geography}).
read_overture_transport_parquet <- function(path, bbox = NULL, class_filter = NULL) {
  if (!file.exists(path)) {
    stop("read_overture_transport_parquet: file not found: ", path)
  }
  con <- DBI::dbConnect(duckdb::duckdb())
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE), add = TRUE)
  DBI::dbExecute(con, "INSTALL spatial; LOAD spatial;")
  path_esc <- gsub("'", "''", normalizePath(path, winslash = "/"))

  # Push coarse spatial and class filters into DuckDB so large parquet files are
  # trimmed before their geometries are materialized in R.
  bbox_sql <- ""
  if (!is.null(bbox)) {
    bbox_sql <- sprintf(
      " AND ST_Intersects(geometry, ST_MakeEnvelope(%f, %f, %f, %f))",
      bbox[["xmin"]], bbox[["ymin"]], bbox[["xmax"]], bbox[["ymax"]]
    )
  }
  class_sql <- ""
  if (!is.null(class_filter)) {
    cls_esc <- gsub("'", "''", class_filter)
    class_sql <- sprintf(" AND class = '%s'", cls_esc)
  }
  sql <- sprintf(
    "SELECT subtype, class, subclass, ST_AsWKB(geometry) AS geom_wkb
     FROM read_parquet('%s')
     WHERE geometry IS NOT NULL %s%s",
    path_esc,
    bbox_sql,
    class_sql
  )
  raw_df <- DBI::dbGetQuery(con, sql)
  if (!nrow(raw_df)) {
    return(data.table::data.table(
      subtype = character(0),
      class = character(0),
      subclass = character(0)
    ))
  }

  # Keep only WKB in the SQL result, then convert once to s2 for spherical
  # length/intersection calculations downstream.
  geom_sfc <- sf::st_as_sfc(raw_df$geom_wkb, crs = 4326)
  g2 <- s2::as_s2_geography(geom_sfc)
  data.table::data.table(
    subtype = raw_df$subtype,
    class = raw_df$class,
    subclass = raw_df$subclass,
    geom = g2
  )
}

#' List road classes present in an Overture road parquet file.
#'
#' Road segments are aggregated one class at a time to keep peak memory use
#' bounded when the global road parquet is large.
#'
#' @param path Path to the Overture road-segments parquet file.
#' @param bbox Optional WGS84 bounding box from \code{inc_ctry_bbox_for_lines()}.
#' @return Character vector of distinct Overture road classes.
road_classes_from_parquet <- function(path, bbox = NULL) {
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
  res <- DBI::dbGetQuery(con, sprintf(
    "SELECT DISTINCT class FROM read_parquet('%s')
     WHERE subtype = 'road' AND geometry IS NOT NULL %s ORDER BY class",
    path_esc, bbox_sql
  ))
  as.character(res$class)
}

#' Load EGM power-grid line layers from a GeoPackage.
#'
#' Every line or multiline layer is read, transformed to WGS84, cast to
#' \code{MULTILINESTRING}, and assigned a \code{line_class} derived from the
#' layer name.
#'
#' @param gpkg_path Path to the EGM \code{grid.gpkg} file.
#' @return \code{data.table} with \code{line_class} and \code{geom}
#'   (\code{s2_geography}).
load_egm_lines_dt <- function(gpkg_path) {
  lay <- sf::st_layers(gpkg_path)
  parts <- list()
  for (L in lay$name) {
    # EGM packages several layers; only line-like layers contribute length
    # measures, while point/polygon layers are skipped.
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

  # Bind after per-layer normalization so the s2 conversion sees one consistent
  # WGS84 multiline geometry column.
  x <- do.call(rbind, parts)
  g <- s2::as_s2_geography(sf::st_geometry(x))
  data.table::data.table(line_class = x$line_class, geom = g)
}

#' Load OGIM oil and natural gas pipeline lines.
#'
#' Reads the \code{Oil_Natural_Gas_Pipelines} layer, normalizes geometry to
#' WGS84 two-dimensional multilines, and labels every feature with the shared
#' \code{ogim_oil_natural_gas_pipelines} class.
#'
#' @param gpkg_path Path to the OGIM GeoPackage.
#' @return \code{data.table} with \code{line_class} and \code{geom}
#'   (\code{s2_geography}).
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

  # Drop Z/M dimensions and cast to multiline geometry before s2 conversion;
  # length aggregation only needs two-dimensional WGS84 paths.
  sf_i <- sf::st_transform(sf_i, 4326)
  sf_i <- sf::st_zm(sf_i, drop = TRUE, warn = FALSE)
  sf_i <- sf::st_cast(sf_i, "MULTILINESTRING", warn = FALSE)
  sf_i$line_class <- "ogim_oil_natural_gas_pipelines"
  g <- s2::as_s2_geography(sf::st_geometry(sf_i))
  data.table::data.table(line_class = sf_i$line_class, geom = g)
}

#' Union line geometries in spatial tiers.
#'
#' Aggregates features within progressively coarser centroid buckets before the
#' final union. This reduces the number of geometries passed to each
#' \code{s2_union_agg()} call and is used before intersecting classes with the
#' global DGGRID cells.
#'
#' @param x Table containing a \code{geom} column coercible to
#'   \code{s2_geography}.
#' @param group_cols Optional columns to preserve as grouping keys, usually
#'   \code{line_class}.
#' @return \code{data.table} with \code{N}, grouped columns, and unioned
#'   \code{geom}.
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

  # Union nearby features first, then repeatedly union coarser buckets. This
  # mirrors the original OSM prototype and avoids one very large all-at-once
  # union per class.
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

#' Calculate line length inside each hex cell.
#'
#' For each merged line geometry, candidate cells are selected by bounding-box
#' intersection before exact \code{s2} intersection and length calculation. Each
#' class receives one output column named \code{<line_class>_len}.
#'
#' @param merged_dt Output from \code{tiered_line_union_dt()} with a class column
#'   and unioned \code{geom}.
#' @param class_col Name of the column containing class labels.
#' @param hex_s2_dt Table with \code{cell} and hex \code{geometry}
#'   (\code{s2_geography}).
#' @return \code{data.table} with all \code{cell} values and zero or more
#'   \code{*_len} columns in meters.
hex_lengths_from_merged <- function(merged_dt, class_col, hex_s2_dt) {
  if (!nrow(merged_dt)) {
    out <- hex_s2_dt[, .(cell)]
    return(out)
  }

  # Column names are derived from class labels and sanitized once here because
  # data.table::set() updates cells by column name inside the loop.
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
      lng1 = bb$lng_lo, lat1 = bb$lat_lo,
      lng2 = bb$lng_hi, lat2 = bb$lat_hi
    ))
    if (!length(cands)) next
    wi_sub <- which(s2::s2_intersects(hex_s2_dt$geometry[cands], gi))
    wi <- cands[wi_sub]
    if (!length(wi)) next

    # Length is measured after clipping each class union to each intersecting
    # cell, which prevents lines crossing many cells from being counted whole.
    leni <- s2::s2_length(s2::s2_intersection(hex_s2_dt$geometry[wi], gi))
    data.table::set(out, i = wi, j = col_names[i], value = leni)
  }
  out
}

#' Full-join two line-length hex tables.
#'
#' @param base Existing \code{cell}-keyed line table.
#' @param add Additional \code{cell}-keyed line table.
#' @return Combined \code{data.table}; missing values are zero-filled by
#'   \code{aggregate_lines_to_hex()} after all sources are merged.
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

  # The DGGRID sf layer is converted to s2 once and reused for every source and
  # class. Keeping the cell id beside geometry lets helper outputs join cleanly.
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

  # The Overture downloader returns separate files by transport subtype; select
  # the files by name so the target can pass the whole file vector unchanged.
  road_p <- grep("road_segments", overture_transport_files, value = TRUE)[1]
  rail_p <- grep("rail_segments", overture_transport_files, value = TRUE)[1]
  water_p <- grep("water_segments", overture_transport_files, value = TRUE)[1]

  out <- hex_s2[, .(cell)]

  # Roads are the largest Overture line layer, so scan, union, intersect, and
  # discard one road class at a time to keep peak memory lower.
  if (length(road_p) && nzchar(road_p)) {
    road_cls <- road_classes_from_parquet(road_p, bbox)
    message("Road classes found: ", paste(road_cls, collapse = ", "))
    for (cls in road_cls) {
      message("  Processing road class: ", cls)
      rd <- read_overture_transport_parquet(road_p, bbox, class_filter = cls)
      rd <- rd[subtype == "road"]
      if (!nrow(rd)) next
      rd[, line_class := paste0("overture_road_", cls)]
      rd_m <- tiered_line_union_dt(rd[, .(line_class, geom)], "line_class")
      out <- merge_line_hex_tables(out, hex_lengths_from_merged(rd_m, "line_class", hex_s2))
      rm(rd, rd_m); gc()
    }
  }

  # Rail and water are smaller layers; process each as a single class-specific
  # geometry union before intersecting with the grid.
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

  # EGM may contain multiple line layers. Each layer keeps a separate class name
  # so power-grid components produce separate length columns.
  egm <- load_egm_lines_dt(egm_grid_file)
  egm_m <- tiered_line_union_dt(egm, "line_class")
  out <- merge_line_hex_tables(out, hex_lengths_from_merged(egm_m, "line_class", hex_s2))

  # OGIM contributes one pipeline class if the source layer is present and has
  # features.
  ogim <- load_ogim_pipeline_lines_dt(ogim_gpkg_file)
  if (nrow(ogim)) {
    ogim_m <- tiered_line_union_dt(ogim, "line_class")
    out <- merge_line_hex_tables(out, hex_lengths_from_merged(ogim_m, "line_class", hex_s2))
  }

  # Full joins introduce NA for cells with no overlap in a given class; convert
  # those to true zero lengths before saving the target output.
  nlen <- grep("_len$", names(out), value = TRUE)
  for (nm in nlen) {
    out[, (nm) := data.table::fifelse(is.na(get(nm)), 0, get(nm))]
  }
  data.table::setorder(out, cell)
  out[]
}
