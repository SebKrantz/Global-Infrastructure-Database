# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline:
library(fastverse)
library(targets)
fastverse_conflicts()
# library(tarchetypes) # Load other packages as needed.

# Set target options:
tar_option_set(
  packages = c("wbstats", "rvest", "countrycode", "sf", "s2", "osmclass", "DBI", "duckdb"), # Packages that your targets need for their tasks.
  trust_timestamps = TRUE, 
  format = "qs" # Optionally set the default storage format. qs is fast.
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source("code")

# Replace the target list below with your own:
list(
  
  tar_target(
    name = income_groups,
    command = get_wb_income_groups()
  ),
  
  tar_target(
    name = geo_ctry,
    command = get_geofabrik_countries(),
  ),
  
  tar_target(
    name = inc_ctry, 
    command = get_income_countries(geo_ctry, income_groups, exclude = "HIC")
  ),
  
  tar_target(
    name = osm_ctry, # Data is saved under data/OSM/raw
    command = download_geofabrik_countries(inc_ctry), 
    cue = tar_cue(mode = "never"), # Track file changes
    format = "file"
  ),
  
  tar_target(
    name = osm_proc, # Data is saved under data/OSM/processed
    command = proc_osm(osm_ctry), 
    cue = tar_cue(mode = "never"), # Track file changes
    format = "file"
  ),
  
  tar_target(
    name = combined_osm, # Data is saved under data/OSM/
    command = combine_osm_proc(proc_osm_dir),
    cue = tar_cue(mode = "never"), # Track file changes
    format = "file"
  ),
  
  tar_target(
    name = overture_latest_release, # Latest overture release
    command = get_overture_latest_release() 
  ),
  
  tar_target(
    name = overture_places, # Data is saved under data/overture/
    command = download_overture_places(overture_latest_release, inc_ctry),
    cue = tar_cue(mode = "never"), # Track file changes
    format = "file"
  ),
  
  tar_target(
    name = foursquares_s3_paths,
    command = get_foursquares_s3_paths()
  ),
  
  tar_target(
    name = foursquares_places, # Data is saved under data/foursquares/
    command = download_foursquares_places(foursquares_s3_paths, inc_ctry),
    cue = tar_cue(mode = "never"), # Track file changes
    format = "file"
  )
  
)

#  More on tar_option_set()
# Pipelines that take a long time to run may benefit from
# optional distributed computing. To use this capability
# in tar_make(), supply a {crew} controller
# as discussed at https://books.ropensci.org/targets/crew.html.
# Choose a controller that suits your needs. For example, the following
# sets a controller that scales up to a maximum of two workers
# which run as local R processes. Each worker launches when there is work
# to do and exits if 60 seconds pass with no tasks to run.
#
#   controller = crew::crew_controller_local(workers = 2, seconds_idle = 60)
#
# Alternatively, if you want workers to run on a high-performance computing
# cluster, select a controller from the {crew.cluster} package.
# For the cloud, see plugin packages like {crew.aws.batch}.
# The following example is a controller for Sun Grid Engine (SGE).
# 
#   controller = crew.cluster::crew_controller_sge(
#     # Number of workers that the pipeline can scale up to:
#     workers = 10,
#     # It is recommended to set an idle time so workers can shut themselves
#     # down if they are not running tasks.
#     seconds_idle = 120,
#     # Many clusters install R as an environment module, and you can load it
#     # with the script_lines argument. To select a specific verison of R,
#     # you may need to include a version string, e.g. "module load R/4.3.2".
#     # Check with your system administrator if you are unsure.
#     script_lines = "module load R"
#   )
#
# Set other options as needed.