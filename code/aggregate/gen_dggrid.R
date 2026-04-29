# Grid cache helpers for pipeline and interactive use.
# No code in this file executes on source().

wld12_grid_cache_path <- function() {
  "data/dggrid/wld12_grid.qs"
}

get_or_build_wld12_dggrid <- function(
    cache_path = wld12_grid_cache_path(),
    water_raster_path = "data/Landcover/Consensus_reduced_class_12_open_water.tif",
    res = 12L) {
  if (file.exists(cache_path)) {
    result <- tryCatch(qs2::qs_read(cache_path), error = function(e) {
      message("dggrid cache unreadable (old format), rebuilding without water filter: ", e$message)
      NULL
    })
    if (!is.null(result)) return(result)
    # Old-format file unreadable: rebuild without the slow exactextractr water filter
    # so the rebuild completes quickly. Ocean hexes will be included.
    return(build_wld12_dggrid(water_raster_path = NULL, res = res, save_path = cache_path))
  }
  # Skip water-raster filtering during pipeline rebuild to avoid long exactextractr runs.
  build_wld12_dggrid(
    water_raster_path = NULL,
    res = res,
    save_path = cache_path
  )
}

build_wld12_dggrid_interactive <- function() {
  out <- get_or_build_wld12_dggrid()
  message("Cells: ", nrow(out$hex_sf))
  invisible(out)
}
