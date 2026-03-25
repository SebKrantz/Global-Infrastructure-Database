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
  con
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

  con <- overture_transport_connect_duckdb(memory_limit, threads)
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE), add = TRUE)

  s3_base <- sprintf("s3://overturemaps-us-west-2/release/%s/theme=transportation", latest)
  seg_parquet <- sprintf("%s/type=segment/*", s3_base)
  sel <- .overture_transport_segment_select_sql

  out_paths <- character(0)

  if ("road" %in% fetch) {
    road_file <- file.path(output_dir, "road_segments.parquet")
    classes_sql <- paste(sprintf("'%s'", road_classes), collapse = ", ")
    DBI::dbExecute(con, sprintf("
      COPY (
        SELECT %s
        FROM read_parquet('%s', filename=true, hive_partitioning=1)
        WHERE subtype = 'road' AND class IN (%s)
      ) TO '%s' (FORMAT PARQUET, ROW_GROUP_SIZE 100000)
    ", sel, seg_parquet, classes_sql, road_file))
    out_paths <- c(out_paths, road_file)
  }

  if ("rail" %in% fetch) {
    rail_file <- file.path(output_dir, "rail_segments.parquet")
    DBI::dbExecute(con, sprintf("
      COPY (
        SELECT %s
        FROM read_parquet('%s', filename=true, hive_partitioning=1)
        WHERE subtype = 'rail'
      ) TO '%s' (FORMAT PARQUET, ROW_GROUP_SIZE 100000)
    ", sel, seg_parquet, rail_file))
    out_paths <- c(out_paths, rail_file)
  }

  if ("water" %in% fetch) {
    water_file <- file.path(output_dir, "water_segments.parquet")
    DBI::dbExecute(con, sprintf("
      COPY (
        SELECT %s
        FROM read_parquet('%s', filename=true, hive_partitioning=1)
        WHERE subtype = 'water'
      ) TO '%s' (FORMAT PARQUET, ROW_GROUP_SIZE 100000)
    ", sel, seg_parquet, water_file))
    out_paths <- c(out_paths, water_file)
  }

  out_paths
}
