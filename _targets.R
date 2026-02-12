# Global Infrastructure Database Pipeline
# See: https://books.ropensci.org/targets/walkthrough.html

# Load packages required to define the pipeline:
library(fastverse)
library(targets)
fastverse_conflicts()

# Set target options:
tar_option_set(
  packages = c("wbstats", "rvest", "countrycode", "sf", "s2", "osmclass", "DBI", "duckdb"),
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
    format = "file"
  ),

  tar_target(
    name = osm_proc,
    command = proc_osm(osm_ctry),
    format = "file"
  ),

  tar_target(
    name = combined_osm,
    command = { osm_proc; combine_osm_proc() },
    format = "file"
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
    format = "file"
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
    format = "file"
  ),

  # ============================================
  # AllThePlaces Pipeline
  # ============================================

  tar_target(
    name = alltheplaces_zip,
    command = { system("python3 code/fetch/fetch_alltheplaces.py"); "data/alltheplaces/output.zip" },
    format = "file"
  ),

  tar_target(
    name = alltheplaces_csv,
    command = { alltheplaces_zip; system("python3 code/process/proc_alltheplaces.py"); "data/alltheplaces/alltheplaces.csv" },
    format = "file"
  ),

  # ============================================
  # Smaller Datasets: OCID (OpenCellID)
  # ============================================

  tar_target(
    name = ocid_file,
    command = fetch_OCID(),
    format = "file"
  ),

  tar_target(
    name = ocid_data,
    command = { ocid_file; load_OCID() }
  ),

  # ============================================
  # Smaller Datasets: WPI (World Port Index)
  # ============================================

  tar_target(
    name = wpi_file,
    command = fetch_WPI(),
    format = "file"
  ),

  tar_target(
    name = wpi_data,
    command = { wpi_file; load_WPI() }
  ),

  # ============================================
  # Smaller Datasets: OOKLA (Internet Speeds)
  # ============================================

  tar_target(
    name = ookla_files,
    command = fetch_OOKLA(),
    format = "file"
  ),

  tar_target(
    name = ookla_data,
    command = { ookla_files; load_OOKLA() }
  )

)
