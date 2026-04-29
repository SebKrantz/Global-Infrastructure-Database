#' Aggregate combined points to dggrid hex cells (counts by \code{main_cat}).
#'
#' @param points_tbl Output of \code{combine_points()} (must have \code{lon}, \code{lat}, \code{main_cat}).
#' @param wld12_grid_list \code{list(dg_spec, hex_sf)} from \code{build_wld12_dggrid()}.
#' @return \code{data.table} with all hex cells, \code{lon_deg}, \code{lat_deg}, \code{area_m2},
#'   and columns \code{pt_<main_cat>} (integer counts, zero-filled).
aggregate_points_to_hex <- function(points_tbl, wld12_grid_list) {
  # The grid list carries both the DGGRID spec for coordinate-to-cell lookup and
  # the sf grid layer used for output metadata.
  dg_spec <- wld12_grid_list$dg_spec
  hex_sf <- wld12_grid_list$hex_sf
  valid_cells <- unique(hex_sf$cell)

  pts <- collapse::qDT(points_tbl)
  if (!all(c("lon", "lat", "main_cat") %in% names(pts))) {
    stop("aggregate_points_to_hex: points_tbl needs lon, lat, main_cat")
  }

  # Assign every point to a DGGRID sequence number, then drop points that fall
  # outside the retained grid cells (for example, cells removed by land masking).
  pts[, cell := suppressWarnings(dggridR::dgGEO_to_SEQNUM(dg_spec, lon, lat)$seqnum)]
  pts <- collapse::fsubset(pts, cell %in% valid_cells)

  # Keep one metadata row for every grid cell so the aggregate output includes
  # empty cells, not only cells containing infrastructure points.
  meta <- collapse::qDT(sf::st_drop_geometry(hex_sf))
  meta <- meta[, c("cell", "lon_deg", "lat_deg", "area_m2"), with = FALSE]
  if ("area_m2" %in% names(meta)) {
    meta[, area_m2 := as.numeric(area_m2)]
  }

  if (!nrow(pts)) {
    return(meta)
  }

  # Count by cell and harmonized main category, then pivot categories to stable
  # point-count columns using the pt_ prefix.
  cnt <- collapse::fcount(pts, cell, main_cat)
  wide <- collapse::pivot(
    cnt,
    ids = "cell",
    names = "main_cat",
    values = "N",
    how = "w",
    sort = "ids"
  )
  nm <- setdiff(names(wide), "cell")
  safe <- make.names(as.character(nm), unique = TRUE)
  data.table::setnames(wide, nm, paste0("pt_", safe))

  # Left join to the complete grid metadata and zero-fill categories that are
  # absent in a cell.
  out <- collapse::join(meta, wide, on = "cell", how = "left")
  pt_cols <- grep("^pt_", names(out), value = TRUE)
  for (col in pt_cols) {
    out[, (col) := data.table::nafill(get(col), fill = 0L)]
  }
  data.table::setorder(out, cell)
  out[]
}

#' Join point-hex and line-hex tables on \code{cell}; zero-fill missing numerics.
#'
#' Point columns use prefix \code{pt_}; line columns use suffix \code{_len}.
combine_hex_gridded <- function(points_hex, lines_hex) {
  p <- collapse::qDT(points_hex)
  l <- collapse::qDT(lines_hex)
  if (!"cell" %in% names(p) || !"cell" %in% names(l)) {
    stop("combine_hex_gridded: inputs must contain cell")
  }

  # Use a full join so either point-only or line-only cells are preserved in the
  # final combined grid.
  out <- collapse::join(p, l, on = "cell", how = "full", sort = TRUE)
  is_num_col <- function(x) {
    is.numeric(x) || inherits(x, "units")
  }
  num_cols <- names(out)[vapply(out, is_num_col, logical(1L))]
  num_cols <- setdiff(num_cols, c("cell"))

  # Convert units objects from spatial calculations to plain numeric values and
  # treat missing joined values as zero observed infrastructure.
  for (col in num_cols) {
    if (inherits(out[[col]], "units")) {
      out[, (col) := as.numeric(get(col))]
    }
    out[, (col) := data.table::nafill(get(col), fill = 0)]
  }

  # Keep grid identifiers and metadata first, followed by sorted point count
  # columns and sorted line length columns.
  first <- c("cell", "lon_deg", "lat_deg", "area_m2")
  first <- first[first %in% names(out)]
  rest <- setdiff(names(out), first)
  pt_rest <- sort(grep("^pt_", rest, value = TRUE))
  len_rest <- sort(grep("_len$", rest, value = TRUE))
  other <- setdiff(rest, c(pt_rest, len_rest))
  data.table::setcolorder(out, c(first, pt_rest, other, len_rest))
  data.table::setorder(out, cell)
  out[]
}
