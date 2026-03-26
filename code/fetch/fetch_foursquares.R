# https://github.com/OvertureMaps/schema/blob/main/docs/schema/concepts/by-theme/places/overture_categories.csv

get_foursquares_s3_paths <- function() {
  
  page_text <- rvest::read_html("https://docs.foursquare.com/data-products/docs/access-fsq-os-places") |>
    rvest::html_text2()
  
  # Extract all S3 URLs even when multiple paths appear in one text block.
  s3_matches <- regmatches(page_text, gregexpr("s3://[^[:space:]`'\"\\)]+", page_text, perl = TRUE))[[1]]
  s3_paths <- sub("[,;]+$", "", s3_matches)
  s3_paths <- sub("\\\\u003c.*$", "", s3_paths)
  s3_paths <- sub("&#x27.*$", "", s3_paths)
  s3_paths <- sub("[^A-Za-z0-9./_=:*\\-].*$", "", s3_paths)
  s3_paths <- unique(s3_paths[nzchar(s3_paths)])
  
  if (length(s3_paths) == 0L) {
    stop("No Foursquare S3 paths found on the docs page.")
  }
  
  s3_paths
  
}

download_foursquares_places <- function(s3_paths, inc_ctry) {
  
  places_path <- grep("places/parquet", s3_paths, value = TRUE)
  categories_path <- grep("categories/parquet", s3_paths, value = TRUE)
  
  if (length(places_path) == 0L) {
    stop("Could not find a Foursquare places parquet S3 path.")
  }
  if (length(categories_path) == 0L) {
    stop("Could not find a Foursquare categories parquet S3 path.")
  }
  
  places_path <- grep("/$", places_path, value = TRUE)[[1]]
  categories_path <- grep("/$", categories_path, value = TRUE)[[1]]
  
  dir.create("data/foursquares", recursive = TRUE, showWarnings = FALSE)
  
  # Connect to DuckDB
  con <- DBI::dbConnect(duckdb::duckdb())
  
  # DBI::dbExecute(con, "INSTALL spatial; INSTALL httpfs;")
  DBI::dbExecute(con, "LOAD spatial; LOAD httpfs; SET s3_region='us-east-1';")
  
  # See number of rows
  DBI::dbGetQuery(con, sprintf("select count(*) from read_parquet('%s*') limit 1", places_path))
  
  categories <- DBI::dbGetQuery(con, sprintf("select * from read_parquet('%s*')", categories_path))

  # Saving
  qs::qsave(categories, "data/foursquares/categories.qs")
  
  # Exclude countries
  excl_ctry <- c(na_rm(countrycode::codelist$iso2c[!countrycode::codelist$iso3c %in% inc_ctry$iso3c]), "usa")
  
  # Define the SQL query
  query <- paste0("
    SELECT
        fsq_place_id as id, 
        date_refreshed as update_date,
        name, 
        fsq_category_ids[1] as category,
        address, locality, postcode, country, 
        website, tel,
        latitude, longitude,
        ST_Area_Spheroid(geom) as area
    FROM
      read_parquet('", places_path, "*')
    WHERE 
      date_closed IS NULL AND latitude IS NOT NULL AND country NOT IN ('", paste(excl_ctry, collapse = "', '"), "')")
  
    # Test 
    # res <- DBI::dbGetQuery(con, paste(query, "limit 1000000")) # "offset 4000000 limit 1000000"
    
    # Now fetching the data
    places <- DBI::dbGetQuery(con, query)
    
    # Saving
    qs::qsave(places, "data/foursquares/places.qs")
    
    # Disconnect from DuckDB
    DBI::dbDisconnect(con, shutdown = TRUE)
    
    c("data/foursquares/places.qs", "data/foursquares/categories.qs")
}

