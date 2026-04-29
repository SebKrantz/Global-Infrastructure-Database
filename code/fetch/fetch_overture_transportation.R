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
  DBI::dbExecute(con, "SET http_retries = 6;")
  DBI::dbExecute(con, "SET http_retry_wait_ms = 5000;")
  DBI::dbExecute(con, "SET http_timeout = 600000;")
  con
}

# Process all S3 parquet files one at a time into local chunk files, then merge.
# Each chunk takes a few minutes (vs one 7+ hour query), and chunks already written
# are skipped on restart (resume capability).
.overture_copy_chunked <- function(files, where_sql, out_file, select_sql,
                                    memory_limit, threads) {
  chunk_dir <- paste0(out_file, "_chunks")
  dir.create(chunk_dir, recursive = TRUE, showWarnings = FALSE)
  n <- length(files)

  for (i in seq_len(n)) {
    chunk_file <- file.path(chunk_dir, sprintf("chunk_%04d.parquet", i))
    if (file.exists(chunk_file)) {
      next
    }
    message(sprintf("  [%d/%d] %s", i, n, basename(files[i])))
    sql <- sprintf(
      "COPY (SELECT %s FROM read_parquet('%s') WHERE %s) TO '%s' (FORMAT PARQUET)",
      select_sql, files[i], where_sql, chunk_file)
    # Run in a fully isolated Rscript subprocess so a DuckDB segfault
    # (SIGSEGV) cannot propagate to the parent process.
    tmp_rds <- tempfile(fileext = ".rds")
    tmp_scr <- tempfile(fileext = ".R")
    saveRDS(list(sql = sql, memory_limit = memory_limit, threads = threads,
                 wd = getwd()), tmp_rds)
    writeLines(c(
      sprintf("a <- readRDS('%s')", tmp_rds),
      "setwd(a$wd)",
      "con <- DBI::dbConnect(duckdb::duckdb())",
      "DBI::dbExecute(con, 'LOAD spatial; LOAD httpfs;')",
      "DBI::dbExecute(con, \"SET s3_region = 'us-west-2';\")",
      "DBI::dbExecute(con, paste0(\"SET memory_limit = '\",a$memory_limit,\"';\"))",
      "DBI::dbExecute(con, paste0('SET threads TO ',a$threads,';'))",
      "DBI::dbExecute(con, 'SET http_retries = 6;')",
      "DBI::dbExecute(con, 'SET http_retry_wait_ms = 5000;')",
      "DBI::dbExecute(con, 'SET http_timeout = 600000;')",
      "DBI::dbExecute(con, a$sql)",
      "DBI::dbDisconnect(con, shutdown = TRUE)"
    ), tmp_scr)
    rc <- system2("Rscript", args = tmp_scr, stdout = FALSE, stderr = FALSE)
    file.remove(tmp_rds, tmp_scr)
    if (rc != 0L) {
      warning(sprintf("chunk %d/%d failed with exit %d (skipping)", i, n, rc))
      file.create(chunk_file)  # placeholder so this chunk is not retried
    }
  }

  # Merge non-empty chunk files into the final output.
  chunk_files <- list.files(chunk_dir, pattern = "^chunk_.*\\.parquet$",
                            full.names = TRUE)
  valid_chunks <- chunk_files[file.size(chunk_files) > 0]
  message("  merging ", length(valid_chunks), "/", n,
          " chunks -> ", basename(out_file))
  chunk_list <- paste(sprintf("'%s'", valid_chunks), collapse = ", ")
  con <- overture_transport_connect_duckdb(memory_limit, threads)
  DBI::dbExecute(con, sprintf(
    "COPY (SELECT * FROM read_parquet([%s])) TO '%s' (FORMAT PARQUET, ROW_GROUP_SIZE 100000)",
    chunk_list, out_file))
  DBI::dbDisconnect(con, shutdown = TRUE)
  unlink(chunk_dir, recursive = TRUE)
}

# Skip a file if a sidecar .release file confirms it was downloaded for this release.
.transport_skip <- function(path, latest) {
  sidecar <- paste0(path, ".release")
  file.exists(path) && file.exists(sidecar) &&
    identical(trimws(readLines(sidecar, warn = FALSE)), latest)
}

#' Download Overture transportation segments to local Parquet (global extract).
#'
#' Roads are restricted to motorway, trunk, primary, secondary, tertiary (includes
#' ramp segments with \code{subclass = 'link'}). Rail and water use \code{subtype} only.
#' There is no country field on segments; crop to countries outside this fetcher if needed.
#' Files are processed one at a time for robustness against S3 connection drops;
#' completed chunks are skipped on restart.
#'
#' @param latest Release string from \code{get_overture_latest_release()}.
#' @param output_dir Directory for output Parquet files.
#' @param fetch Subset of \code{c("road", "rail", "water")}.
#' @param road_classes Road \code{class} values to keep when \code{"road"} \%in\% fetch.
#' @param memory_limit DuckDB \code{memory_limit} setting.
#' @param threads DuckDB thread count.
#' @return Character vector of written file paths (road, rail, water in that order).
download_overture_transportation <- function(
    latest,
    output_dir = "data/overture/transportation",
    fetch = c("road", "rail", "water"),
    road_classes = c("motorway", "trunk", "primary", "secondary", "tertiary"),
    memory_limit = "32GB",
    threads = 4L) {

  fetch <- unique(fetch)
  if (!length(fetch)) stop("fetch must be non-empty.")
  bad <- setdiff(fetch, c("road", "rail", "water"))
  if (length(bad)) stop("Invalid fetch value(s): ", paste(bad, collapse = ", "))

  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

  # Enumerate all segment parquet files once (fast metadata-only query).
  s3_base <- sprintf(
    "s3://overturemaps-us-west-2/release/%s/theme=transportation", latest)
  seg_parquet <- sprintf("%s/type=segment/*", s3_base)
  sel <- .overture_transport_segment_select_sql

  message("Listing segment parquet files...")
  con <- overture_transport_connect_duckdb(memory_limit, threads)
  all_files <- DBI::dbGetQuery(
    con, sprintf("SELECT * FROM glob('%s')", seg_parquet))$file
  DBI::dbDisconnect(con, shutdown = TRUE)
  message("Found ", length(all_files), " parquet files.")

  out_paths <- character(0)

  if ("road" %in% fetch) {
    road_file <- file.path(output_dir, "road_segments.parquet")
    if (.transport_skip(road_file, latest)) {
      message("road_segments.parquet already current for release ", latest, ", skipping.")
    } else {
      message("Downloading road segments (chunked)...")
      classes_sql <- paste(sprintf("'%s'", road_classes), collapse = ", ")
      where_sql <- sprintf("subtype = 'road' AND class IN (%s)", classes_sql)
      .overture_copy_chunked(all_files, where_sql, road_file, sel,
                             memory_limit, threads)
      writeLines(latest, paste0(road_file, ".release"))
    }
    out_paths <- c(out_paths, road_file)
  }

  if ("rail" %in% fetch) {
    rail_file <- file.path(output_dir, "rail_segments.parquet")
    if (.transport_skip(rail_file, latest)) {
      message("rail_segments.parquet already current for release ", latest, ", skipping.")
    } else {
      message("Downloading rail segments (chunked)...")
      .overture_copy_chunked(all_files, "subtype = 'rail'", rail_file, sel,
                             memory_limit, threads)
      writeLines(latest, paste0(rail_file, ".release"))
    }
    out_paths <- c(out_paths, rail_file)
  }

  if ("water" %in% fetch) {
    water_file <- file.path(output_dir, "water_segments.parquet")
    if (.transport_skip(water_file, latest)) {
      message("water_segments.parquet already current for release ", latest, ", skipping.")
    } else {
      message("Downloading water segments (chunked)...")
      .overture_copy_chunked(all_files, "subtype = 'water'", water_file, sel,
                             memory_limit, threads)
      writeLines(latest, paste0(water_file, ".release"))
    }
    out_paths <- c(out_paths, water_file)
  }

  out_paths
}
