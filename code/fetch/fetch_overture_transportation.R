# Overture Maps transportation theme: segment extracts via DuckDB (S3 GeoParquet).
# Schema: https://docs.overturemaps.org/schema/reference/transportation/segment/
# Subtype "water" is Overture's waterway/ferry centerlines (small global layer); refine inland vs marine downstream if needed.

# Segment columns: same core as misc/fetch_network_data.R but no connectors[] (only a count).
.overture_transport_segment_select_sql <- "
    id,
    theme,
    \"type\",
    version,
    bbox,
    sources,
    subtype,
    class,
    subclass,
    subclass_rules,
    names,
    destinations,
    len(connectors) AS n_connectors,
    speed_limits,
    access_restrictions,
    prohibited_transitions,
    routes,
    road_surface,
    width_rules,
    level_rules,
    road_flags,
    rail_flags,
    geometry
"

overture_transport_connect_duckdb <- function(memory_limit = "32GB", threads = 4L) {
  con <- DBI::dbConnect(duckdb::duckdb())
  DBI::dbExecute(con, "INSTALL spatial; LOAD spatial;")
  DBI::dbExecute(con, "INSTALL httpfs; LOAD httpfs;")
  DBI::dbExecute(con, "SET s3_region = 'us-west-2';")
  DBI::dbExecute(con, sprintf("SET memory_limit = '%s';", memory_limit))
  DBI::dbExecute(con, sprintf("SET threads TO %d;", as.integer(threads)))
  # Retry dropped S3 connections automatically
  DBI::dbExecute(con, "SET http_retries = 6;")
  DBI::dbExecute(con, "SET http_retry_wait_ms = 5000;")
  DBI::dbExecute(con, "SET http_timeout = 600000;")  # 10 min per individual HTTP request
  con
}

# Run a single COPY statement, retrying with a fresh DuckDB connection on failure.
.overture_copy_with_retry <- function(sql, memory_limit, threads, max_tries = 3L) {
  for (i in seq_len(max_tries)) {
    con <- overture_transport_connect_duckdb(memory_limit, threads)
    tryCatch({
      DBI::dbExecute(con, sql)
      DBI::dbDisconnect(con, shutdown = TRUE)
      return(invisible(NULL))
    }, error = function(e) {
      DBI::dbDisconnect(con, shutdown = TRUE)
      if (i == max_tries) stop(e)
      message("COPY attempt ", i, "/", max_tries, " failed: ", conditionMessage(e), " — retrying in 30s...")
      Sys.sleep(30)
    })
  }
}

#' Download Overture transportation segments to local Parquet (global extract).
#'
#' Roads are restricted to motorway, trunk, primary, secondary, tertiary (includes
#' ramp segments with \code{subclass = 'link'}). Rail and water use \code{subtype} only.
#' There is no country field on segments; crop to countries outside this fetcher if needed.
#'
#' @param latest Release string from \code{get_overture_latest_release()}.
#' @param output_dir Directory for output Parquet files.
#' @param fetch Subset of \code{c("road", "rail", "water")}.
#' @param road_classes Road \code{class} values to keep when \code{"road"} \%in\% fetch.
#' @param memory_limit DuckDB \code{memory_limit} setting.
#' @param threads DuckDB thread count.
#' @return Character vector of written file paths (road, rail, water in that order, omitting skipped types).
download_overture_transportation <- function(
    latest,
    output_dir = "data/overture/transportation",
    fetch = c("road", "rail", "water"),
    road_classes = c("motorway", "trunk", "primary", "secondary", "tertiary"),
    memory_limit = "32GB",
    threads = 4L) {

  fetch <- unique(fetch)
  if (!length(fetch)) {
    stop("fetch must be non-empty.")
  }
  bad <- setdiff(fetch, c("road", "rail", "water"))
  if (length(bad)) {
    stop("Invalid fetch value(s): ", paste(bad, collapse = ", "))
  }

  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

  s3_base <- sprintf("s3://overturemaps-us-west-2/release/%s/theme=transportation", latest)
  seg_parquet <- sprintf("%s/type=segment/*", s3_base)
  sel <- .overture_transport_segment_select_sql

  out_paths <- character(0)

  # Skip if already written for this release date.
  release_date <- as.Date(sub("\\.[0-9]+$", "", latest))
  .skip <- function(path) {
    file.exists(path) && file.size(path) > 1e6 &&
      as.Date(file.mtime(path)) >= release_date
  }

  if ("road" %in% fetch) {
    road_file <- file.path(output_dir, "road_segments.parquet")
    if (.skip(road_file)) {
      message("road_segments.parquet already current (",
              round(file.size(road_file) / 1e9, 2), " GB), skipping.")
    } else {
      classes_sql <- paste(sprintf("'%s'", road_classes), collapse = ", ")
      .overture_copy_with_retry(sprintf("
        COPY (
          SELECT %s
          FROM read_parquet('%s', filename=true, hive_partitioning=1)
          WHERE subtype = 'road' AND class IN (%s)
        ) TO '%s' (FORMAT PARQUET, ROW_GROUP_SIZE 100000)
      ", sel, seg_parquet, classes_sql, road_file), memory_limit, threads)
    }
    out_paths <- c(out_paths, road_file)
  }

  if ("rail" %in% fetch) {
    rail_file <- file.path(output_dir, "rail_segments.parquet")
    if (.skip(rail_file)) {
      message("rail_segments.parquet already current (",
              round(file.size(rail_file) / 1e9, 2), " GB), skipping.")
    } else {
      .overture_copy_with_retry(sprintf("
        COPY (
          SELECT %s
          FROM read_parquet('%s', filename=true, hive_partitioning=1)
          WHERE subtype = 'rail'
        ) TO '%s' (FORMAT PARQUET, ROW_GROUP_SIZE 100000)
      ", sel, seg_parquet, rail_file), memory_limit, threads)
    }
    out_paths <- c(out_paths, rail_file)
  }

  if ("water" %in% fetch) {
    water_file <- file.path(output_dir, "water_segments.parquet")
    if (.skip(water_file)) {
      message("water_segments.parquet already current (",
              round(file.size(water_file) / 1e9, 2), " GB), skipping.")
    } else {
      .overture_copy_with_retry(sprintf("
        COPY (
          SELECT %s
          FROM read_parquet('%s', filename=true, hive_partitioning=1)
          WHERE subtype = 'water'
        ) TO '%s' (FORMAT PARQUET, ROW_GROUP_SIZE 100000)
      ", sel, seg_parquet, water_file), memory_limit, threads)
    }
    out_paths <- c(out_paths, water_file)
  }

  out_paths
}
