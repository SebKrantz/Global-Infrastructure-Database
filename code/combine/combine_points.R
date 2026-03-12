

classify_overture_foursquares <- function(source) {
  
  # Load the mapping
  source("code/combine/overture_foursquares_to_osm_det.R")
  
  # Load categories
  categories <- qread(sprintf("data/%s/categories.qs", source))
  cat("Total", source, "categories:", fnrow(categories), "\n\n")
  
  # Apply classification in order (earlier categories take precedence)
  remaining <- categories
  results <- list()
  
  for (osm_cat in names(overture_foursquares_to_osm_det)) {
    cat <- overture_foursquares_to_osm_det[[osm_cat]][[source]]
    if (is.null(cat)) next
    
    matched <- rep(FALSE, nrow(remaining))
    for (col_name in names(cat)) {
      matched <- matched | (.subset2(remaining, col_name) %in% cat[[col_name]])
    }
    
    if (any(matched)) {
      results[[osm_cat]] <- ss(remaining, matched)
      remaining <- ss(remaining, !matched)
    }
  }
  
  if(any_duplicated(vec(results))) warning("Duplicate classifications found")
  
  return(results)
}


combine_points <- function() {
  
  #
  ### Overture Places ------------------------------------------------------------
  #
  
  overture_places <- qread("data/overture/places.qs") |> fsubset(!is.na(category))
  overture_cat <- classify_overture_foursquares("overture") |> rowbind(idcol = "main_cat")
  
  OVP_prep <- overture_places |> fcompute(
    id = paste0("OVP_", id),
    lon = lon,
    lat = lat,
    ref = NA_character_,
    name = name,
    address = paste(address, locality, postcode, country, sep = "; "),
    # description = NA_character_,
    source_orig = source,
    main_cat = overture_cat$main_cat[ckmatch(category, overture_cat$category)],
    main_tag = "category",
    main_tag_value = category,
    alt_cats = NA_character_, # TODO: Match?
    alt_tags_values = category_alt, # paste0('update_time:"', update_time, '", website:"', website, '", tel:"', tel, '"') # ?
    variable = "confidence",
    value = confidence
  )
  rm(overture_places, overture_cat); gc()
  
  settfmv(OVP_prep, char_vars(OVP_prep, "names")[-1], qF); gc()
  
  if(any_duplicated(OVP_prep$id)) stop("OVP: Duplicated ids")
  
  # OVP_prep |> st_as_sf(coords = c("lon", "lat"), crs = 4326) |> mapview::mapview()
  
  #
  ### Foursquares Places ------------------------------------------------------------
  #
  
  foursquares_places <- qread("data/foursquares/places.qs") |> fsubset(!is.na(category))
  foursquares_cat <- classify_overture_foursquares("foursquares") |> rowbind(idcol = "main_cat")
  ind <- ckmatch(foursquares_places$category, foursquares_cat$category_id)
  
  FSP_prep <- foursquares_places |> fcompute(
    id = paste0("FSP_", id),
    lon = longitude,
    lat = latitude,
    ref = NA_character_,
    name = name,
    address = paste(address, locality, postcode, country, sep = "; "), 
    # description = NA_character_,
    source_orig = NA_character_, # placemaker_url,
    main_cat = foursquares_cat$main_cat[ind],
    main_tag = "category",
    main_tag_value = foursquares_cat$category_name[ind],
    alt_cats = NA_character_,
    alt_tags_values = NA_character_,
    other_tags_values = paste0('tel:"', tel, '", website:"', website, '"'),
    variable = "area",
    value = area
  )
  rm(foursquares_places, foursquares_cat, ind); gc()
  
  settfmv(FSP_prep, char_vars(FSP_prep, "names")[-1], qF); gc()
  
  if(any_duplicated(FSP_prep$id)) stop("FSP: Duplicated ids")
  
  # FSP_prep |> st_as_sf(coords = c("lon", "lat"), crs = 4326) |> mapview::mapview()
  
  #
  ### Alltheplaces ------------------------------------------------------------
  #
  
  ATP <- fread("data/alltheplaces/alltheplaces.csv") |> janitor::clean_names()
  
  # Deduplication
  # ATP |> fselect(longitude, latitude, amenity, shop, brand, brand_wikidata, spider) |> fduplicated() |> qtable()
  ATP %<>% fgroup_by(longitude, latitude, ref, brand_wikidata) %>% fmode()
  # ATP |> fcompute(am = pfirst(amenity, shop), keep = .c(longitude, latitude, brand_wikidata, ref)) |> fduplicated() |> qtable()
  
  ATP$other_tags = ""
  ATP_class <- osm_classify(ATP, osm_point_polygon_class_det)
  # qtable(ATP_class$classified)
  # fcount(ATP_class, main_cat, main_tag, main_tag_value) |> roworder(-N)
  # fndistinct(ATP_class)
  gc()

  ATP_prep <- ATP |> fcompute(
    id = paste("ATP", ref, brand_wikidata, geohashTools::gh_encode(
      replace_outliers(latitude, 90-1e-10, "clip", "max"), 
      replace_outliers(longitude, 180-1e-10, "clip", "max"), precision = 15), sep = "_"),
    lon = longitude,
    lat = latitude,
    ref = ref,
    name = name,
    address = paste(addr_postcode, addr_city, addr_state, addr_country, sep = ", "),
    # description = NA_character_,
    source_orig = source,
    main_cat = ATP_class$main_cat, 
    main_tag = ATP_class$main_tag, 
    main_tag_value = ATP_class$main_tag_value,
    alt_cats = ATP_class$alt_cats, 
    alt_tags_values = ATP_class$alt_tags_values, 
    other_tags_values = paste0('spider:"', spider, '", operator:"', operator, '", brand:"', brand, '", brand_wikidata:"', brand_wikidata, '", nsi_id:"', nsi_id, '"'),
    variable = NA_character_,
    value = NA_real_
  ) |> ss(ATP_class$classified) # TODO: could manually improve misclassification
  
  if(any_duplicated(ATP_prep$id)) message("ATP: Duplicated ids")
  rm(ATP, ATP_class); gc()
  
  ATP_prep %<>% fgroup_by(id) %>% fmode()
  # ATP_prep |> st_as_sf(coords = c("lon", "lat"), crs = 4326) |> mapview::mapview()
  
  # 
  ### Opencellid Cell Towers -------------------------------------------------
  #
  
  OCID <- fread("data//opencellid/cell_towers.csv.gz") %>% get_vars(varying(.))
  # descr(OCID)
  # Deduplication 
  OCID %<>% collap(~ radio + lon + lat, fmode, w = ~ samples, wFUN = fmax)
  
  # Scrape table of mobile country codes
  # The table follows the 'National operators' span with id 'National_operators'
  # We use xpath to navigate from this span to the following table
  # mcc_table <- rvest::read_html("https://en.wikipedia.org/wiki/Mobile_country_code") |>
  #   rvest::html_node(xpath = "//h2[span[@id='National_operators']]/following-sibling::table[1]") |>
  #   rvest::html_table(fill = TRUE) |>
  #   janitor::clean_names()
  mcc_table <- rvest::read_html("https://en.wikipedia.org/wiki/Mobile_country_code") |> 
      rvest::html_table(fill = TRUE) |> 
      extract2(2) |> janitor::clean_names()
  
  OCID_prep <- OCID |> fcompute(
    id = paste("OCID", radio, geohashTools::gh_encode(lat, lon, precision = 15), sep = "_"),
    lon = lon,
    lat = lat,
    ref = as.double(cell),
    name = NA_character_,
    address = mcc_table$country[ckmatch(mcc, mcc_table$mobile_country_code)],
    # description = NA_character_,
    source_orig = NA_character_,
    main_cat = "communications", 
    main_tag = "radio", 
    main_tag_value = radio,
    alt_cats = NA_character_, 
    alt_tags_values = NA_character_,
    other_tags_values = paste0('mobile_country_code:"', mcc, '", mobile_network_code:"', net, '", samples:"', samples, 
                             '", created:"', as.POSIXct(created, origin="1970-01-01", tz="UTC"), 
                             '", updated:"', as.POSIXct(updated, origin="1970-01-01", tz="UTC"), '"'),
    variable = "accuracy_in_m",
    value = range
  )
  
  if(any_duplicated(OCID_prep$id)) stop("OCID: Duplicated ids")
  
  rm(OCID, mcc_table); gc()
  
  #
  ### Global Integrated Power Tracker -----------------------------------------------
  #
  
  GIP <- load_GIP()
  # descr(GIP)
  
  # Deduplication
  GIP |> fsubset(fduplicated(geohashTools::gh_encode(latitude, longitude, precision = 15), all = TRUE))
  # GIP %<>% mutate(id = geohashTools::gh_encode(latitude, longitude, precision = 15)) 
  # GIP %>% varying(gem_location_id ~ id)
  GIP %<>% fgroup_by(gem_location_id, status) %>% collapg(w = capacity_mw) %>% 
    fsubset(status %in% c("operating", "construction", "inactive", "mothballed"))
  table(GIP$status)
  
  GIP_prep <- GIP |> fcompute(
    id = paste("GIP", gem_location_id, status, sep = "_"), 
    lon = longitude,
    lat = latitude,
    ref = gem_unit_phase_id,
    name = plant_project_name,
    address = paste(city, subnational_unit_state_province, country_area, sep = ", "),
    # description = NA_character_,
    source_orig = gem_wiki_url,
    main_cat = "power", 
    main_tag = "plant_type", 
    main_tag_value = type,
    alt_cats = NA_character_, 
    alt_tags_values = NA_character_,
    other_tags_values = paste0('status:"', status, '", start_year:"', start_year, '", retired_year:"', retired_year, '", technology:"', technology, 
                             '", fuel:"', fuel, '", owner:"', owner, '", parent:"', parent, '", location_accuracy:"', location_accuracy, '"'),
    variable = "capacity_mw",
    value = capacity_mw
  )
  
  if(any_duplicated(GIP_prep$id)) stop("GIP: Duplicated ids")
  
  rm(GIP); gc()
  
  #
  ### PortWatch (IMF) ---------------------------------------------------------------
  #
  
  PW <- load_portswatch()
  
  PW_prep <- PW |> fcompute(
    id = paste0("PW_", portid),
    lon = lon,
    lat = lat,
    ref = portid,
    name = portname,
    address = fullname,
    source_orig = NA_character_,
    main_cat = "port",
    main_tag = "facility",
    main_tag_value = "port",
    alt_cats = NA_character_,
    alt_tags_values = NA_character_,
    other_tags_values = paste0(
      'iso3:"', iso3, '", locode:"', locode, '", continent:"', continent, '", ',
      'industry_top1:"', industry_top1, '", industry_top2:"', industry_top2, '", industry_top3:"', industry_top3, '", ',
      'vessel_count_total:"', vessel_count_total, '", vessel_count_container:"', vessel_count_container, '", ',
      'vessel_count_dry_bulk:"', vessel_count_dry_bulk, '", vessel_count_general_cargo:"', vessel_count_general_cargo, '", ',
      'vessel_count_ro_ro:"', vessel_count_ro_ro, '", vessel_count_tanker:"', vessel_count_tanker, '", ',
      'share_country_maritime_import:"', share_country_maritime_import, '", share_country_maritime_export:"', share_country_maritime_export, '"'
    ),
    variable = "vessel_count_total",
    value = as.double(vessel_count_total)
  )
  
  if (any_duplicated(PW_prep$id)) stop("PW: Duplicated ids")
  
  rm(PW); gc()
  
  #
  ### Open Zone Map ---------------------------------------------------------------
  #
  
  OZM <- load_OZM()
  
  OZM_prep <- OZM |> fcompute(
    id = paste0("OZM_", id),
    lon = longitude,
    lat = latitude,
    ref = NA_character_,
    name = title,
    address = country,
    # description = NA_character_,
    source_orig = note,
    main_cat = "SEZ", 
    main_tag = "zone_type", 
    main_tag_value = zone_type,
    alt_cats = NA_character_, 
    alt_tags_values = NA_character_,
    other_tags_values = paste0('status:"', status, '", zone_specialization:"', zone_specialization, 
                             '", management_type:"', management_type, '", management_company:"', management_company,
                             '", sez_framework:"', sez_framework, '", size_class:"', size_class, '", url:"', url,
                             '", created:"', created, '", modified:"', modified,  
                             '", nearest_airport:"', nearest_airport, '", nearest_airport_distance_km:"', nearest_airport_distance_km,
                             '", nearest_port:"', nearest_port, '", nearest_port_distance_km:"', nearest_port_distance_km,
                             '", capital_city:"', capital_city, '", capital_city_distance_km:"', capital_city_distance_km, 
                             '", populous_city:"', populous_city, '", populous_city_distance_km:"', populous_city_distance_km, '"'),
    variable = "size_hectares",
    value = as.numeric(size_hectares)
  ) 
  
  if (any_duplicated(OZM_prep$id)) stop("PW: Duplicated ids")
  
  rm(OZM); gc()
  
}

