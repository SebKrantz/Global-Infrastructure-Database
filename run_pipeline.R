library(targets)
source("_targets.R")
tar_make()


# Run overture_places and everything downstream of it
tar_make(names = any_of(.c(
  overture_places, foursquares_places, alltheplaces_csv,
  ocid_file, portswatch_file, egm_grid_file, ogim_gpkg_file
)))

tar_make(overture_places)
tar_make(foursquares_places)
tar_make(ocid_file)
tar_make(portswatch_file)
tar_make(egm_grid_file)





tar_outdated()