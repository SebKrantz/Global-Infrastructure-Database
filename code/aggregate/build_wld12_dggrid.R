#' Build dggrid resolution-12 global hex grid and optional land mask.
#'
#' Saves \code{dg_spec} (from \code{dggridR::dgconstruct}) required for
#' \code{dgGEO_to_SEQNUM}, plus an \code{sf} hex layer with \code{cell},
#' \code{lon_deg}, \code{lat_deg}, \code{area_m2}, \code{geometry}.
#'
#' @param water_raster_path Path to a landcover raster (e.g. open-water class).
#'   If NULL or empty string, skips water filtering (all hex cells kept).
#' @param res dggrid resolution (default 12).
#' @param save_path If non-NULL, directory is created and list saved via \code{qs::qsave}.
#' @return Invisibly \code{list(dg_spec = ..., hex_sf = ...)}. Also returns the
#'   same list invisibly after save for use in \code{targets}.
#' @keywords internal
build_wld12_dggrid <- function(
    water_raster_path = "data/Landcover/Consensus_reduced_class_12_open_water.tif",
    res = 12L,
    save_path = NULL) {

  dg_spec <- dggridR::dgconstruct(res = as.integer(res))
  wld12 <- dggridR::dgearthgrid(dg_spec)
  gc()

  if (!all(sf::st_is_valid(wld12))) {
    stop("build_wld12_dggrid: invalid geometries in dgearthgrid output")
  }

  water_raster_path <- water_raster_path[1L]
  if (length(water_raster_path) && nzchar(as.character(water_raster_path)) &&
      isTRUE(file.exists(water_raster_path))) {
    water <- terra::rast(water_raster_path)
    water_perc <- exactextractr::exact_extract(water, wld12, fun = "mean")
    wld12 <- collapse::ss(wld12, is.finite(water_perc) & water_perc < 100 - 1e-5)
    gc()
  } else if (length(water_raster_path) && nzchar(as.character(water_raster_path))) {
    stop(
      "build_wld12_dggrid: water_raster_path file does not exist: ",
      water_raster_path
    )
  } else {
    message(
      "build_wld12_dggrid: no water raster provided (ocean hexes are not filtered)"
    )
  }

  collapse::setrename(wld12, seqnum = cell)
  wld12$area_m2 <- as.numeric(sf::st_area(wld12$geometry))
  geo_coords <- dggridR::dgSEQNUM_to_GEO(dg_spec, wld12$cell)
  wld12$lon_deg <- geo_coords$lon_deg
  wld12$lat_deg <- geo_coords$lat_deg
  data.table::setcolorder(wld12, c("cell", "lon_deg", "lat_deg", "area_m2", "geometry"))

  out <- list(dg_spec = dg_spec, hex_sf = wld12)

  if (length(save_path) && nzchar(save_path)) {
    dir.create(dirname(save_path), recursive = TRUE, showWarnings = FALSE)
    qs2::qs_save(out, save_path)
  }

  out
}
