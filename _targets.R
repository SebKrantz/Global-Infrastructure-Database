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
PIPELINE_FLAGS <- list(
  point_fetching = TRUE,
  lines_fetching = TRUE,
  point_processing = TRUE,
  points_combination = TRUE,
  point_aggregation = TRUE,
  line_aggregation = TRUE
)

# Set target options:
tar_option_set(
  packages = c("wbstats", "rvest", "countrycode", "sf", "s2", "osmclass", "DBI", "duckdb",
               "geohashTools", "readxl", "janitor", "qs", "geojsonsf", "httr", "jsonlite",
               "dggridR", "terra", "exactextractr", "rnaturalearth", "collapse", "data.table"),
  globals = list(CUES_MODE = CUES_MODE, PIPELINE_FLAGS = PIPELINE_FLAGS),
  trust_timestamps = TRUE,
  format = "qs"
)

# Source all R scripts in code/ folder:
tar_source("code")

# Stage toggles:
POINT_FETCHING <- isTRUE(PIPELINE_FLAGS$point_fetching)
LINES_FETCHING <- isTRUE(PIPELINE_FLAGS$lines_fetching)
POINT_PROCESSING <- isTRUE(PIPELINE_FLAGS$point_processing)
POINTS_COMBINATION <- isTRUE(PIPELINE_FLAGS$points_combination)
POINT_AGGREGATION <- isTRUE(PIPELINE_FLAGS$point_aggregation)
LINE_AGGREGATION <- isTRUE(PIPELINE_FLAGS$line_aggregation)

# Fail-fast validation for stage dependencies:
if (POINT_PROCESSING && !POINT_FETCHING) {
  stop("Invalid stage toggles: point_processing=TRUE requires point_fetching=TRUE.")
}
if (POINTS_COMBINATION && (!POINT_FETCHING || !POINT_PROCESSING)) {
  stop("Invalid stage toggles: points_combination=TRUE requires point_fetching=TRUE and point_processing=TRUE.")
}
if (POINT_AGGREGATION && !POINTS_COMBINATION) {
  stop("Invalid stage toggles: point_aggregation=TRUE requires points_combination=TRUE.")
}
if (LINE_AGGREGATION && !LINES_FETCHING) {
  stop("Invalid stage toggles: line_aggregation=TRUE requires lines_fetching=TRUE.")
}
if (LINE_AGGREGATION && !POINT_FETCHING) {
  stop("Invalid stage toggles: line_aggregation=TRUE requires point_fetching=TRUE for EGM/OGIM inputs.")
}
if (LINE_AGGREGATION && !POINT_AGGREGATION) {
  stop("Invalid stage toggles: line_aggregation=TRUE requires point_aggregation=TRUE for final hex combination.")
}

# Base targets always required:
base_targets <- list(

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
  )
)

overture_meta_targets <- if (POINT_FETCHING || LINES_FETCHING) list(
  tar_target(
    name = overture_latest_release,
    command = get_overture_latest_release()
  )
) else list()

point_fetch_targets <- if (POINT_FETCHING) list(
  # ============================================
  # Point Fetching
  # ============================================

  # OSM Pipeline
  tar_target(
    name = osm_ctry,
    command = download_geofabrik_countries(inc_ctry),
    format = "file",
    cue = tar_cue(mode = CUES_MODE)
  ),
  # Overture Pipeline
  tar_target(
    name = overture_places,
    command = download_overture_places(overture_latest_release, inc_ctry),
    format = "file",
    cue = tar_cue(mode = CUES_MODE)
  ),
  # Foursquares Pipeline
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
  # AllThePlaces Pipeline
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
  # Smaller Datasets: OCID (OpenCellID)
  tar_target(
    name = ocid_file,
    command = fetch_OCID(),
    format = "file",
    cue = tar_cue(mode = CUES_MODE)
  ),
  # Smaller Datasets: PortWatch (IMF)
  tar_target(
    name = portswatch_file,
    command = fetch_portswatch(),
    format = "file",
    cue = tar_cue(mode = CUES_MODE)
  ),
  # Smaller Datasets: EGM (Gridfinder global power grid, Zenodo)
  tar_target(
    name = egm_grid_file,
    command = fetch_EGM_grid(),
    format = "file",
    cue = tar_cue(mode = CUES_MODE)
  ),
  # Smaller Datasets: OGIM (Zenodo)
  tar_target(
    name = ogim_gpkg_file,
    command = fetch_OGIM(),
    format = "file",
    cue = tar_cue(mode = CUES_MODE)
  )
  # # Smaller Datasets: WPI (World Port Index)
  # tar_target(
  #   name = wpi_file,
  #   command = fetch_WPI(),
  #   format = "file"
  # ),
  # # Smaller Datasets: OOKLA (Internet Speeds)
  # tar_target(
  #   name = ookla_files,
  #   command = fetch_OOKLA(),
  #   format = "file"
  # ),
) else list()

lines_fetch_targets <- if (LINES_FETCHING) list(
  # ============================================
  # Lines Fetching
  # ============================================

  tar_target(
    name = overture_transportation,
    command = download_overture_transportation(overture_latest_release),
    format = "file",
    cue = tar_cue(mode = CUES_MODE)
  )
) else list()

point_processing_targets <- if (POINT_PROCESSING) list(
  # ============================================
  # Point Processing and Classification
  # ============================================

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
  )
) else list()

points_combination_targets <- if (POINTS_COMBINATION) list(
  # ============================================
  # Combine Datasets
  # ============================================
  
  tar_target(
    name = points_combined,
    command = { combined_osm; overture_places; foursquares_places; alltheplaces_csv; ocid_file; portswatch_file; egm_grid_file; ogim_gpkg_file; combine_points() },
    format = "qs"
  )
) else list()

point_aggregation_targets <- if (POINT_AGGREGATION) list(
  # ============================================
  # Hex grid (dggrid R12) + gridded aggregates
  # ============================================

  tar_target(
    name = wld12_grid,
    command = build_wld12_dggrid(),
    cue = tar_cue(mode = CUES_MODE)
  ),

  tar_target(
    name = points_hex_agg,
    command = {
      dir.create("data/aggregate", recursive = TRUE, showWarnings = FALSE)
      ph <- aggregate_points_to_hex(points_combined, wld12_grid)
      qs::qsave(ph, "data/aggregate/points_by_hex.qs")
      ph
    }
  )
) else list()

line_aggregation_targets <- if (LINE_AGGREGATION) list(
  tar_target(
    name = lines_hex_agg,
    command = {
      dir.create("data/aggregate", recursive = TRUE, showWarnings = FALSE)
      lh <- aggregate_lines_to_hex(
        overture_transportation, egm_grid_file, ogim_gpkg_file, wld12_grid, inc_ctry
      )
      qs::qsave(lh, "data/aggregate/lines_by_hex.qs")
      lh
    },
    cue = tar_cue(mode = CUES_MODE)
  ),
  tar_target(
    name = hex_gridded_combined,
    command = {
      dir.create("data/aggregate", recursive = TRUE, showWarnings = FALSE)
      hc <- combine_hex_gridded(points_hex_agg, lines_hex_agg)
      qs::qsave(hc, "data/aggregate/infrastructure_hex_r12.qs")
      hc
    }
  )
) else list()

# Pipeline targets:
c(
  base_targets,
  overture_meta_targets,
  point_fetch_targets,
  lines_fetch_targets,
  point_processing_targets,
  points_combination_targets,
  point_aggregation_targets,
  line_aggregation_targets
)
