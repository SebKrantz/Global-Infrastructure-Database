# Global Infrastructure Database Pipeline
# See: https://books.ropensci.org/targets/walkthrough.html

# Load packages required to define the pipeline:
library(fastverse)
library(targets)
fastverse_conflicts()

# Set to "never" to skip re-running expensive fetch/process targets and skip
# re-downloading files that already exist inside fetcher functions.
# Set to "thorough" to re-run all targets and re-fetch all data.
CUES_MODE <- "never"

# Set target options:
tar_option_set(
  packages = c("wbstats", "rvest", "countrycode", "sf", "s2", "osmclass", "DBI", "duckdb",
               "geohashTools", "readxl", "janitor", "qs", "geojsonsf", "httr", "jsonlite"),
  globals = list(CUES_MODE = CUES_MODE),
  trust_timestamps = TRUE,
  format = "qs"
)

# Source all R scripts in code/ folder:
tar_source("code")

# Pipeline targets:
list(

  # ============================================
  # Country/Income Group Setup
  # ============================================

  tar_target(
    name = income_groups,
    command = get_wb_income_groups()
  ),

  tar_target(
    name = geo_ctry,
    command = get_geofabrik_countries()
  ),

  tar_target(
    name = inc_ctry,
    command = get_income_countries(geo_ctry, income_groups, exclude = "HIC")
  ),

  # ============================================
  # OSM Pipeline
  # ============================================

  tar_target(
    name = osm_ctry,
    command = download_geofabrik_countries(inc_ctry),
    format = "file",
    cue = tar_cue(mode = CUES_MODE)
  ),

  tar_target(
    name = osm_proc,
    command = proc_osm(osm_ctry),
    format = "file",
    cue = tar_cue(mode = CUES_MODE)
  ),

  tar_target(
    name = combined_osm,
    command = { osm_proc; combine_osm_proc() },
    format = "file",
    cue = tar_cue(mode = CUES_MODE)
  ),

  # ============================================
  # Overture Pipeline
  # ============================================

  tar_target(
    name = overture_latest_release,
    command = get_overture_latest_release()
  ),

  tar_target(
    name = overture_places,
    command = download_overture_places(overture_latest_release, inc_ctry),
    format = "file",
    cue = tar_cue(mode = CUES_MODE)
  ),

  tar_target(
    name = overture_transportation,
    command = download_overture_transportation(overture_latest_release),
    format = "file",
    cue = tar_cue(mode = CUES_MODE)
  ),

  # ============================================
  # Foursquares Pipeline
  # ============================================

  tar_target(
    name = foursquares_s3_paths,
    command = get_foursquares_s3_paths()
  ),

  tar_target(
    name = foursquares_places,
    command = download_foursquares_places(foursquares_s3_paths, inc_ctry),
    format = "file",
    cue = tar_cue(mode = CUES_MODE)
  ),

  # ============================================
  # AllThePlaces Pipeline
  # ============================================

  tar_target(
    name = alltheplaces_zip,
    command = { system("python3 code/fetch/fetch_alltheplaces.py"); "data/alltheplaces/output.zip" },
    format = "file",
    cue = tar_cue(mode = CUES_MODE)
  ),

  tar_target(
    name = alltheplaces_csv,
    command = { alltheplaces_zip; system("python3 code/process/proc_alltheplaces.py"); "data/alltheplaces/alltheplaces.csv" },
    format = "file",
    cue = tar_cue(mode = CUES_MODE)
  ),

  # ============================================
  # Smaller Datasets: OCID (OpenCellID)
  # ============================================

  tar_target(
    name = ocid_file,
    command = fetch_OCID(),
    format = "file",
    cue = tar_cue(mode = CUES_MODE)
  ),

  # ============================================
  # Smaller Datasets: PortWatch (IMF)
  # ============================================

  tar_target(
    name = portswatch_file,
    command = fetch_portswatch(),
    format = "file",
    cue = tar_cue(mode = CUES_MODE)
  ),

  # # ============================================
  # # Smaller Datasets: WPI (World Port Index)
  # # ============================================

  # tar_target(
  #   name = wpi_file,
  #   command = fetch_WPI(),
  #   format = "file"
  # ),

  # tar_target(
  #   name = wpi_data,
  #   command = { wpi_file; load_WPI() }
  # ),

  # # ============================================
  # # Smaller Datasets: OOKLA (Internet Speeds)
  # # ============================================

  # tar_target(
  #   name = ookla_files,
  #   command = fetch_OOKLA(),
  #   format = "file"
  # ),

  # tar_target(
  #   name = ookla_data,
  #   command = { ookla_files; load_OOKLA() }
  # ),
  
  # ============================================
  # Combine Datasets
  # ============================================
  
  tar_target(
    name = points_combined,
    command = { combined_osm; overture_places; foursquares_places; alltheplaces_csv; ocid_file; portswatch_file; combine_points() },
    format = "qs"
  )

)
