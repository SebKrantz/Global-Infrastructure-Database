# Interactive / one-off: build global R12 hex grid (see targets: wld12_grid).
# Reproducible runs should use targets::tar_make(names = wld12_grid).
# Run from repository root.

source("code/aggregate/build_wld12_dggrid.R")

library(fastverse)
fastverse_extend(dggridR)
library(sf)

out <- build_wld12_dggrid(
  water_raster_path = Sys.getenv("WLD12_WATER_RASTER", ""),
  res = 12L,
  save_path = "data/dggrid/wld12_grid.qs"
)

message("Cells: ", nrow(out$hex_sf))
