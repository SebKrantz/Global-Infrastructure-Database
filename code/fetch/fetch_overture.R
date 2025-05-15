
get_overture_latest_release <- function() {
  
  latest <- rvest::read_html("https://docs.overturemaps.org/release/latest/") |>
    rvest::html_element("h1") |>
    rvest::html_text(trim = TRUE)
  
  if(!grepl("[0-9]+[-][0-9]+[-][0-9]+\\.[0-9]+", latest)) {
    stop("Could not find the latest overture release version.")
  }
  
  latest
}

download_overture_places <- function(latest, inc_ctry) {
  
  places_url <- sprintf("s3://overturemaps-us-west-2/release/%s/theme=places/*/*", latest)
  
  # Connect to DuckDB
  con <- DBI::dbConnect(duckdb::duckdb())
  
  # DBI::dbExecute(con, "INSTALL spatial; INSTALL httpfs;")
  DBI::dbExecute(con, "LOAD spatial; LOAD httpfs; SET s3_region='us-west-2';")
  
  # Get categories
  categories <- fread("https://raw.githubusercontent.com/OvertureMaps/schema/refs/heads/main/docs/schema/concepts/by-theme/places/overture_categories.csv") |>
    set_names(c("category", "taxonomy")) |>
    ftransform(tstrsplit(gsub("\\[|\\]", "", taxonomy), ",") |> qDF()) |>
    fmutate(taxonomy = NULL)
  
  # Saving 
  qs::qsave(categories, "data/overture/categories.qs")
  
  # See number of rows
  # DBI::dbGetQuery(con, sprintf("select count(*) from read_parquet('%s') limit 1", places_url))
  # DBI::dbGetQuery(con, sprintf("select addresses[1].country as country, count(*) as N from read_parquet('%s') group by country order by N desc", places_url))
  
  # Exclude countries
  excl_ctry <- c(na_rm(countrycode::codelist$iso2c[!countrycode::codelist$iso3c %in% inc_ctry$iso3c]), "usa")
  
  # Define the SQL query
  query <- paste0("
    select 
        id, 
        REPLACE(sources[1].dataset, chr(0), '') as source, 
        strptime(REPLACE(sources[1].update_time, chr(0), ''), '%Y-%m-%dT%H:%M:%S.%fZ') as update_time, 
        REPLACE(names.primary, chr(0), '') as name, 
        categories.primary as category,
        categories.alternate as category_alt,
        -- brand.names.primary as brand,
        -- brand.wikidata as brand_wikidata,
        confidence, 
        REPLACE(addresses[1].freeform, chr(0), '') as address, 
        REPLACE(addresses[1].locality, chr(0), '') as locality, 
        REPLACE(addresses[1].postcode, chr(0), '') as postcode,
        -- REPLACE(addresses[1].region, chr(0), '') as region, 
        addresses[1].country as country, 
        REPLACE(websites[1], chr(0), '') as website, 
        -- REPLACE(emails[1], chr(0), '') as email, 
        REPLACE(phones[1], chr(0), '') as tel,
        ST_X(geometry) as lon, 
        ST_Y(geometry) as lat
    from
      read_parquet('", places_url, "')
    where not country in ('", paste(excl_ctry, collapse = "', '"), "')")
  
    # Test 
    # res <- DBI::dbGetQuery(con, paste(query, "offset 4000000 limit 1000000")) # "offset 4000000 limit 1000000"
    
    # Now fetching the data
    places <- DBI::dbGetQuery(con, query)
    # places %<>% fsubset(country %!in% excl_ctry)

    settfmv(places, is.list, as.character)
    char_vars(places) %<>% 
      lapply(setv, "", NA_character_) %>% 
      lapply(setv, "NULL", NA_character_) %>% 
      lapply(qF, sort = FALSE)
    
    # Saving
    qs::qsave(places, "data/overture/places.qs")
    
    # Disconnect from DuckDB
    DBI::dbDisconnect(con, shutdown = TRUE)
    
    c("data/overture/places.qs", "data/overture/categories.qs")
}

