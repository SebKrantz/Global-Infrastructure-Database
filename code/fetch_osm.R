
get_wb_income_groups <- function() {
  
  cache <- wbstats::wb_cache()
  
  income_groups <- cache$countries |>
    fsubset(!is.na(income_level_iso3c), iso3c, country, region, income_level_iso3c)

  # Retrieve the most recent GNI per capita data for each country
  gni_data <- wbstats::wb_data("NY.GDP.PCAP.CD") |>
    fsubset(!is.na(NY.GDP.PCAP.CD), iso3c, GNI = NY.GDP.PCAP.CD, year = date) |>
    fslice(iso3c, how = "max", order.by = year)
  
  # Merge the two datasets by country code
  join(income_groups, gni_data, on = "iso3c")

}

# install.packages("https://cran.r-project.org/src/contrib/Archive/geofabrik/geofabrik_0.1.0.tar.gz", type = "source", repos = NULL)
# geofabrik::urlgeo

get_geofabrik_countries <- function() {
  
  sub_regions <- rvest::read_html("https://download.geofabrik.de/") |>
    # rvest::html_element("table") |>
    rvest::html_element("#subregions") |>
    rvest::html_elements("td.subregion") |>
    rvest::html_elements("a") |>
    rvest::html_attr("href")
  
  grep("antarct", sub_regions, value = TRUE, invert = TRUE) |>
   sapply(function(sub_region) {
    
    reg <- rvest::read_html(paste0("https://download.geofabrik.de/", sub_region)) |>
      rvest::html_elements("#subregions") |> tail(1) |>
      rvest::html_elements("td") |>
      rvest::html_elements("a") 
    
    country <- rvest::html_text(reg)
    country[startsWith(country, "[")] <- NA_character_
    link <- rvest::html_attr(reg, "href")
    link <- sub(".html", "-latest.osm.pbf", link)
  
    na_omit(data.frame(country, link))
    
  }, simplify = FALSE) |> 
    rowbind(idcol = "region", id.factor = FALSE) |>
    fmutate(iso3c = countrycode::countryname(country, "iso3c"), 
                      iso3c = fcoalesce(iso3c, countrycode::countryname(tstrsplit(country, " ")[[1]], "iso3c")),
                      region = sub(".html", "", region), 
                      link = paste0("https://download.geofabrik.de/", link)) |>
    colorder(region, iso3c, country, link) |>
    fsubset(!is.na(iso3c) & !fduplicated(iso3c))
}


download_geofabrik_countries <- function(geo_ctry, income_groups, exclude = "HIC") {
  
  ctry <- join(geo_ctry, income_groups, on = "iso3c", how = "inner", suffix = c("_geo", "_wb"), validate = "1:1") |>
          fsubset(!income_level_iso3c %in% exclude)
  
  oldopt <- options(timeout = 10000) 
  on.exit(options(oldopt))
  
  for (c in seq_len(nrow(ctry))) {
    Sys.sleep(1)
    country <- ss(ctry, c)
    message("Downloading ", country$country_geo, " data from ", country$link)
    download.file(country$link, paste0("data/OSM/raw/", basename(country$link)), mode = "wb")
    if(c %% 10 == 0) Sys.sleep(10)
  }
  
  if(length(list.files("data/OSM/raw")) != nrow(ctry)) {
    warning("Some files were not downloaded")
  }
  
  ctry
}
