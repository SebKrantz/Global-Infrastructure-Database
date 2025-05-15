# https://github.com/OvertureMaps/schema/blob/main/docs/schema/concepts/by-theme/places/overture_categories.csv

get_foursquares_s3_paths <- function() {
  
  rvest::read_html("https://docs.foursquare.com/data-products/docs/access-fsq-os-places") |>
    rvest::html_nodes("code, pre") |>  # Adjust selectors based on actual HTML structure
    rvest::html_text() |>
    grep(pattern = "s3://", value = TRUE) |>  # Filter for S3 paths
    extract(1:2)
  
}

download_foursquares_places <- function(s3_paths, inc_ctry) {
  
  places_path <- grep("places/parquet", s3_paths, value = TRUE)
  categories_path <- grep("categories/parquet", s3_paths, value = TRUE)
  
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

