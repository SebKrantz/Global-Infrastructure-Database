# Grid cache helpers for pipeline and interactive use.
# No code in this file executes on source().

wld12_grid_cache_path <- function() {
  "data/dggrid/wld12_grid.qs"
}

get_or_build_wld12_dggrid <- function(
    cache_path = wld12_grid_cache_path(),
    water_raster_path = Sys.getenv("WLD12_WATER_RASTER", ""),
    res = 12L) {
  if (file.exists(cache_path)) {
    return(qs::qread(cache_path))
  }
  build_wld12_dggrid(
    water_raster_path = water_raster_path,
    res = res,
    save_path = cache_path
  )
}

build_wld12_dggrid_interactive <- function() {
  out <- get_or_build_wld12_dggrid()
  message("Cells: ", nrow(out$hex_sf))
  invisible(out)
}
