# Global Infrastructure Database Pipeline
# See: https://books.ropensci.org/targets/walkthrough.html

# Bootstrap required R packages (install only missing ones).
REQUIRED_PACKAGES <- c(
  "fastverse", "targets", "wbstats", "rvest", "countrycode", "sf", "s2", "osmclass",
  "DBI", "duckdb", "geohashTools", "readxl", "janitor", "qs2", "geojsonsf", "httr",
  "jsonlite", "dggridR", "terra", "exactextractr", "rnaturalearth", "collapse",
  "data.table", "R.utils", "arrow"
)

missing_packages <- REQUIRED_PACKAGES[!vapply(REQUIRED_PACKAGES, requireNamespace, TRUE, quietly = TRUE)]

if (length(missing_packages)) {
  install.packages(missing_packages, repos = "https://cloud.r-project.org")
}

# Load packages required to define the pipeline:
library(fastverse)
library(targets)
# targets::tar_destroy(destroy = 'all') # For fresh starts
fastverse_conflicts()

# Set to "never" to skip re-running expensive fetch/process targets and skip
# re-downloading files that already exist inside fetcher functions.
# Set to "thorough" to re-run all targets and re-fetch all data.
# Set ot "always" to always redownload
CUES_MODE <- "never"
PIPELINE_FLAGS <- list(
  point_fetching = TRUE,
  lines_fetching = TRUE,
  point_processing = TRUE,
  points_combination = TRUE,
  point_aggregation = TRUE,
  line_aggregation = TRUE,
  alltheplaces = FALSE,
  foursquares = FALSE
)

# Set target options:
tar_option_set(
  packages = c("wbstats", "rvest", "countrycode", "sf", "s2", "osmclass", "DBI", "duckdb",
               "geohashTools", "readxl", "janitor", "qs2", "geojsonsf", "httr", "jsonlite",
               "dggridR", "terra", "exactextractr", "rnaturalearth", "collapse", "data.table",
               "arrow"),
  trust_timestamps = TRUE,
  format = "rds"
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
ANY_AGGREGATION <- POINT_AGGREGATION || LINE_AGGREGATION
ATP_ENABLED <- isTRUE(PIPELINE_FLAGS$alltheplaces)
FSQ_ENABLED <- isTRUE(PIPELINE_FLAGS$foursquares)

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
  if (FSQ_ENABLED) tar_target(
    name = foursquares_s3_paths,
    command = get_foursquares_s3_paths()
  ),

  if (FSQ_ENABLED) tar_target(
    name = foursquares_places,
    command = download_foursquares_places(foursquares_s3_paths, inc_ctry),
    format = "file",
    cue = tar_cue(mode = CUES_MODE)
  ),
  # AllThePlaces Pipeline
  if (ATP_ENABLED) tar_target(
    name = alltheplaces_zip,
    command = {
      rc <- system("venv/bin/python code/fetch/fetch_alltheplaces.py")
      if (rc != 0L) stop("fetch_alltheplaces.py exited with status ", rc)
      "data/alltheplaces/output.zip"
    },
    format = "file",
    cue = tar_cue(mode = CUES_MODE)
  ),

  if (ATP_ENABLED) tar_target(
    name = alltheplaces_csv,
    command = {
      alltheplaces_zip
      rc <- system("venv/bin/python code/process/proc_alltheplaces.py")
      if (rc != 0L) stop("proc_alltheplaces.py exited with status ", rc)
      "data/alltheplaces/alltheplaces.csv"
    },
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
  #
  # tar_target(
  #   name = wpi_data,
  #   command = { wpi_file; load_WPI() }
  # ),
  # # Smaller Datasets: OOKLA (Internet Speeds)
  # tar_target(
  #   name = ookla_files,
  #   command = fetch_OOKLA(),
  #   format = "file"
  # ),
  #
  # tar_target(
  #   name = ookla_data,
  #   command = { ookla_files; load_OOKLA() }
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
    command = {
      combined_osm; overture_places; ocid_file; portswatch_file; egm_grid_file; ogim_gpkg_file
      if (FSQ_ENABLED) foursquares_places
      if (ATP_ENABLED) alltheplaces_csv
      combine_points(atp = ATP_ENABLED, fsq = FSQ_ENABLED)
    },
    format = "file"
  ),
  tar_target(
    name = points_deduplicated,
    command = {
      pts <- arrow::open_dataset(dirname(points_combined[1])) |>
        dplyr::collect() |> collapse::qDT()
      # Re-factorise low-cardinality columns once, after concatenation, to
      # mirror the factor-harmonised output the previous in-memory rowbind
      # produced.
      fct_cols <- c("source", "main_cat", "main_tag", "main_tag_value",
                    "variable", "source_orig")
      for (c in intersect(fct_cols, names(pts))) {
        pts[, (c) := collapse::qF(get(c))]
      }
      deduplicate_points(pts)
    },
    format = "file"
  )
) else list()

aggregation_common_targets <- if (ANY_AGGREGATION) list(
  tar_target(
    name = wld12_grid,
    command = {
      get_or_build_wld12_dggrid()
      wld12_grid_cache_path()
    },
    format = "file",
    cue = tar_cue(mode = CUES_MODE)
  )
) else list()

point_aggregation_targets <- if (POINT_AGGREGATION) list(
  # ============================================
  # Hex grid (dggrid R12) + gridded aggregates
  # ============================================

  tar_target(
    name = points_hex_agg,
    command = {
      dir.create("data/aggregate", recursive = TRUE, showWarnings = FALSE)
      ph <- aggregate_points_to_hex(qs2::qs_read(points_deduplicated), qs2::qs_read(wld12_grid))
      out <- "data/aggregate/points_by_hex.qs"
      qs2::qs_save(ph, out)
      out
    }
    ,
    format = "file"
  )
) else list()

line_aggregation_targets <- if (LINE_AGGREGATION) list(
  tar_target(
    name = lines_hex_agg,
    command = {
      dir.create("data/aggregate", recursive = TRUE, showWarnings = FALSE)
      lh <- aggregate_lines_to_hex(
        overture_transportation, egm_grid_file, ogim_gpkg_file, qs2::qs_read(wld12_grid), inc_ctry
      )
      out <- "data/aggregate/lines_by_hex.qs"
      qs2::qs_save(lh, out)
      out
    },
    format = "file",
    cue = tar_cue(mode = CUES_MODE)
  ),
  tar_target(
    name = hex_gridded_combined,
    command = {
      dir.create("data/aggregate", recursive = TRUE, showWarnings = FALSE)
      hc <- combine_hex_gridded(qs2::qs_read(points_hex_agg), qs2::qs_read(lines_hex_agg))
      out <- "data/aggregate/infrastructure_hex_r12.qs"
      qs2::qs_save(hc, out)
      out
    }
    ,
    format = "file"
  )
) else list()

# Pipeline targets:
pipeline_targets <- c(
  base_targets,
  overture_meta_targets,
  point_fetch_targets,
  lines_fetch_targets,
  point_processing_targets,
  points_combination_targets,
  aggregation_common_targets,
  point_aggregation_targets,
  line_aggregation_targets
)

pipeline_targets
