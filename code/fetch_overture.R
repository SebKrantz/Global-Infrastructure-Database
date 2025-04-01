# https://github.com/OvertureMaps/schema/blob/main/docs/schema/concepts/by-theme/places/overture_categories.csv

get_overture_latest_release <- function() {
  
  latest <- rvest::read_html("https://docs.overturemaps.org/release/latest/") |>
    rvest::html_element("h1") |>
    rvest::html_text(trim = TRUE)
  
  if(!grepl("[0-9]+[-][0-9]+[-][0-9]+\\.[0-9]+", latest)) {
    stop("Could not find the latest overture release version.")
  }
  
  latest
}

download_overture_places <- function(latest) {
  
  places_url <- sprintf("s3://overturemaps-us-west-2/release/%s/theme=places/*/*", latest)
  
  # Connect to DuckDB
  con <- DBI::dbConnect(duckdb::duckdb())
  
  # DBI::dbExecute(con, "INSTALL spatial; INSTALL httpfs;")
  DBI::dbExecute(con, "LOAD spatial; LOAD httpfs; SET s3_region='us-west-2';")
  
  # See number of rows
  DBI::dbGetQuery(con, sprintf("select count(*) from read_parquet('%s') limit 1", places_url))

  # Define the SQL query
  query <- paste0("
    select 
        id, 
        -- sources[1].dataset as source, 
        -- strptime(sources[1].update_time, '%Y-%m-%dT%H:%M:%S.%fZ') as update_time, 
        -- names.primary as name, 
        categories.primary as category,
        categories.alternate as category_alt,
        -- brand.names.primary as brand,
        -- brand.wikidata as brand_wikidata,
        confidence, 
        -- addresses[1].freeform as address, 
        -- addresses[1].locality as locality, 
        -- addresses[1].postcode as postcode,
        -- addresses[1].region as region, 
        addresses[1].country as country, 
        -- websites[1] as website, 
        -- emails[1] as email, 
        -- phones[1] as tel,
        ST_X(geometry) as lon, 
        ST_Y(geometry) as lat
    from
      read_parquet('", places_url, "')")
  
    # Test 
    res <- DBI::dbGetQuery(con, paste(query, "offset 4000000 limit 1000000")) # "offset 4000000 limit 1000000"
    
    # Now fetching the data
    places <- DBI::dbGetQuery(con, query)
    
    # Saving
    qs::qsave(places, "data/overture/places.qs")
    
    # Disconnect from DuckDB
    DBI::dbDisconnect(con, shutdown = TRUE)
    
    "data/overture/places.qs"
}

