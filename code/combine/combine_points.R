

classify_overture_foursquares <- function(source) {
  
  # Load the mapping
  source("code/combine/overture_foursquares_to_osm_det.R")
  
  # Load categories
  categories <- qs2::qs_read(sprintf("data/%s/categories.qs", source))
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


combine_points <- function(out = "data/combined/points_combined.qs", atp = TRUE, fsq = TRUE) {
  
  
  #
  ### Open Street Map ------------------------------------------------------------
  #
  
  OSM_points <- qs2::qs_read("data/OSM/points.qs")
  
  OSM_points_prep <- OSM_points |> fcompute(
    id = paste0("OSM_node_", osm_id),
    lon = lon,
    lat = lat,
    ref = ref,
    name = name,
    address = factor(NA_character_),
    # description = NA_character_,
    source_orig = factor(NA_character_),
    main_cat = main_cat,
    main_tag = main_tag,
    main_tag_value = main_tag_value,
    alt_cats = alt_cats,
    alt_tags_values = alt_tags_values,
    other_tags_values = factor(NA_character_),
    variable = factor(NA_character_),
    value = NA_real_
  ) |> collap(~ id)
  
  if(any_duplicated(OSM_points_prep$id)) stop("OSM: Duplicated ids")
  rm(OSM_points); gc()
  
  OSM_multipolygons <- qs2::qs_read("data/OSM/multipolygons.qs")
  
  OSM_multipolygons_prep <- OSM_multipolygons |> fcompute(
    id = iif(is.na(osm_id), paste0("OSM_way_", osm_way_id), paste0("OSM_node_", osm_id)),
    lon = lon,
    lat = lat,
    ref = ref,
    name = name,
    address = factor(NA_character_),
    # description = NA_character_,
    source_orig = factor(NA_character_),
    main_cat = main_cat,
    main_tag = main_tag,
    main_tag_value = main_tag_value,
    alt_cats = alt_cats,
    alt_tags_values = alt_tags_values,
    other_tags_values = factor(NA_character_),
    variable = factor("area_m2"),
    value = unattrib(area)
  ) |> collap(~ id)
  
  if(any_duplicated(OSM_multipolygons_prep$id)) stop("OSM: Duplicated ids")
  rm(OSM_multipolygons); gc()
  
  #
  ### Overture Places ------------------------------------------------------------
  #
  
  overture_places <- qs2::qs_read("data/overture/places.qs") |> fsubset(!is.na(category))
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
    other_tags_values = paste0('update_time:"', update_time, '", website:"', website, '", tel:"', tel, '"'),
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

  if (fsq) {
    foursquares_places <- qs2::qs_read("data/foursquares/places.qs") |> fsubset(!is.na(category))
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
  }
  
  #
  ### Alltheplaces ------------------------------------------------------------
  #

  if (atp) {
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
  }
  
  # 
  ### Opencellid Cell Towers -------------------------------------------------
  #
  
  OCID <- fread("data/opencellid/cell_towers.csv.gz") %>% get_vars(varying(.))
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
    main_cat = "communications_network",
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
  
  # Deduplication
  # GIP |> fsubset(fduplicated(geohashTools::gh_encode(latitude, longitude, precision = 15), all = TRUE))
  GIP %<>% fgroup_by(gem_location_id, status) %>% collapg(w = capacity_mw) %>% 
    fsubset(status %in% c("operating", "construction", "inactive", "mothballed"))
  
  GIP_prep <- GIP |> fcompute(
    id = paste("GIP", gem_location_id, status, sep = "_"), 
    lon = longitude,
    lat = latitude,
    ref = gem_unit_phase_id,
    name = plant_project_name,
    address = paste(city, local_area_taluk_county, major_area_prefecture_district,
                    subnational_unit_state_province, country_area, sep = ", "),
    source_orig = gem_wiki_url,
    main_cat = "power_plant_large",
    main_tag = "plant_type",
    main_tag_value = type,
    alt_cats = NA_character_, 
    alt_tags_values = NA_character_,
    other_tags_values = paste0('status:"', status, '", start_year:"', start_year, '", retired_year:"', retired_year, '", technology:"', technology, 
                               '", fuel:"', fuel_combustion_only, '", owner:"', owner_s, '", parent:"', parent_s, '", location_accuracy:"', location_accuracy, '"'),
    variable = "capacity_mw",
    value = capacity_mw
  )
  
  if(any_duplicated(GIP_prep$id)) stop("GIP: Duplicated ids")
  
  rm(GIP); gc()

  #
  ### Global Cement and Concrete Tracker --------------------------------------------
  #
  
  GEM_cement <- load_GEM_cement()
  coords_cem <- strsplit(GEM_cement$coordinates, ",")
  lat_cem <- as.numeric(trimws(vapply(coords_cem, `[`, character(1), 1L)))
  lon_cem <- as.numeric(trimws(vapply(coords_cem, `[`, character(1), 2L)))
  GEM_cement$latitude <- lat_cem
  GEM_cement$longitude <- lon_cem
  
  CEMENT_prep <- GEM_cement |> fcompute(
    id = paste("GEMCEM", gem_plant_id, sep = "_"), 
    lon = longitude,
    lat = latitude,
    ref = gem_plant_id,
    name = gem_asset_name_english,
    address = paste(municipality, subnational_unit, country_area, sep = ", "),
    source_orig = gem_wiki_page,
    main_cat = "industrial", 
    main_tag = "sector", 
    main_tag_value = "cement",
    alt_cats = NA_character_, 
    alt_tags_values = NA_character_,
    other_tags_values = paste0('operating_status:"', operating_status, '", start_date:"', start_date, '", owner:"', owner_name_english,
                               '", plant_type:"', plant_type, '", production_type:"', production_type,
                               '", ccs_ccus:"', ccs_ccus, '", alternative_fuel:"', alternative_fuel, '"'),
    variable = "cement_capacity_millions_metric_tonnes_per_annum",
    value = cement_capacity_millions_metric_tonnes_per_annum
  )
  
  if(any_duplicated(CEMENT_prep$id)) stop("GEM Cement: Duplicated ids")
  
  rm(GEM_cement); gc()
  
  #
  ### Global Iron Ore Mines Tracker -------------------------------------------------
  #
  
  GEM_iron_ore <- load_GEM_iron_ore()
  coords_iron <- strsplit(GEM_iron_ore$coordinates, ",")
  lat_iron <- as.numeric(trimws(vapply(coords_iron, `[`, character(1), 1L)))
  lon_iron <- as.numeric(trimws(vapply(coords_iron, `[`, character(1), 2L)))
  GEM_iron_ore$latitude <- lat_iron
  GEM_iron_ore$longitude <- lon_iron
  
  IRON_prep <- GEM_iron_ore |> fcompute(
    id = paste("GEMIRON", gem_asset_id, sep = "_"), 
    lon = longitude,
    lat = latitude,
    ref = gem_asset_id,
    name = asset_name_english,
    address = paste(municipality, subnational_unit, country_area, sep = ", "),
    source_orig = gem_wiki_page_url,
    main_cat = "mining", 
    main_tag = "commodity", 
    main_tag_value = "iron_ore",
    alt_cats = NA_character_, 
    alt_tags_values = NA_character_,
    other_tags_values = paste0('operating_status:"', operating_status, '", start_date:"', start_date, '", stop_date:"', stop_date,
                               '", design_capacity_ttpa:"', design_capacity_ttpa,
                               '", production_2024_ttpa:"', production_2024_ttpa, '"'),
    variable = "design_capacity_ttpa",
    value = suppressWarnings(as.numeric(design_capacity_ttpa))
  )
  
  if(any_duplicated(IRON_prep$id)) stop("GEM Iron Ore: Duplicated ids")
  
  rm(GEM_iron_ore); gc()
  
  #
  ### Global Chemicals Inventory ----------------------------------------------------
  #
  
  GEM_chem <- load_GEM_chemicals()
  coords_chem <- strsplit(GEM_chem$coordinates, ",")
  lat_chem <- as.numeric(trimws(vapply(coords_chem, `[`, character(1), 1L)))
  lon_chem <- as.numeric(trimws(vapply(coords_chem, `[`, character(1), 2L)))
  GEM_chem$latitude <- lat_chem
  GEM_chem$longitude <- lon_chem
  
  CHEM_prep <- GEM_chem |> fcompute(
    id = paste("GEMCHEM", gem_plant_id, sep = "_"), 
    lon = longitude,
    lat = latitude,
    ref = gem_plant_id,
    name = plant_name_english,
    address = paste(municipality, subnational_unit, country_area, sep = ", "),
    source_orig = gem_wiki_page,
    main_cat = "industrial", 
    main_tag = "sector", 
    main_tag_value = "chemicals",
    alt_cats = NA_character_, 
    alt_tags_values = NA_character_,
    other_tags_values = paste0('primary_products:"', primary_products, '", secondary_products:"', secondary_products,
                               '", feedstock:"', feedstock, '", feedstock_accuracy:"', feedstock_accuracy, '"'),
    variable = NA_character_,
    value = NA_real_
  )
  
  if(any_duplicated(CHEM_prep$id)) stop("GEM Chemicals: Duplicated ids")
  
  rm(GEM_chem); gc()
  
  #
  ### Global Iron and Steel Tracker -------------------------------------------------
  #
  
  GEM_steel <- load_GEM_steel()
  coords_steel <- strsplit(GEM_steel$coordinates, ",")
  lat_steel <- as.numeric(trimws(vapply(coords_steel, `[`, character(1), 1L)))
  lon_steel <- as.numeric(trimws(vapply(coords_steel, `[`, character(1), 2L)))
  GEM_steel$latitude <- lat_steel
  GEM_steel$longitude <- lon_steel
  
  STEEL_prep <- GEM_steel |> fcompute(
    id = paste("GEMSTEEL", plant_id,
               geohashTools::gh_encode(latitude, longitude, precision = 15), sep = "_"), 
    lon = longitude,
    lat = latitude,
    ref = plant_id,
    name = plant_name_english,
    address = paste(municipality, subnational_unit_province_state, country_area, sep = ", "),
    source_orig = gem_wiki_page,
    main_cat = "industrial", 
    main_tag = "sector", 
    main_tag_value = "steel",
    alt_cats = NA_character_, 
    alt_tags_values = NA_character_,
    other_tags_values = paste0('status:"', status, '", start_date:"', start_date,
                               '", nominal_crude_steel_capacity_ttpa:"', nominal_crude_steel_capacity_ttpa, '"'),
    variable = "nominal_crude_steel_capacity_ttpa",
    value = suppressWarnings(as.numeric(nominal_crude_steel_capacity_ttpa))
  ) |> fslice(id, how = "max", order.by = replace_na(value))
  
  if(any_duplicated(STEEL_prep$id)) stop("GEM Steel: Duplicated ids")
  
  rm(GEM_steel); gc()
  
  #
  ### TZ-SAM Solar Asset Mapper -----------------------------------------------------
  #
  
  SAM <- load_solar_assets()
  
  SAM_prep <- SAM |> fcompute(
    id = paste("SAM", cluster_id,
               geohashTools::gh_encode(latitude, longitude, precision = 15), sep = "_"),
    lon = longitude,
    lat = latitude,
    ref = as.character(cluster_id),
    name = NA_character_,
    address = country,
    source_orig = NA_character_,
    main_cat = "power_plant_small",
    main_tag = "plant_type",
    main_tag_value = "solar",
    alt_cats = NA_character_,
    alt_tags_values = NA_character_,
    other_tags_values = paste0('constructed_before:"', constructed_before, '", constructed_after:"', constructed_after, '"'),
    variable = "capacity_mw",
    value = capacity_mw
  )
  
  if (any_duplicated(SAM_prep$id)) stop("SAM: Duplicated ids")
  
  rm(SAM); gc()
  
  #
  ### Oil and Gas Infrastructure Mapping (OGIM) -------------------------------------
  #
  
  OGIM_list <- load_OGIM()
  OGIM_flat <- Map(function(d, nm) { d$ogim_layer <- nm; d }, OGIM_list, names(OGIM_list)) |>
    rowbind(fill = TRUE)
  OGIM_flat$name_display <- fcoalesce(OGIM_flat$fac_name, OGIM_flat$name)
  OGIM_flat %<>% fsubset(!is.na(latitude) & !is.na(longitude))

  # Per-layer category mapping (extraction → mining, processing → industrial,
  # pumping/compression → utilities_other, bulk storage → storage)
  ogim_cat_map <- c(
    Oil_Natural_Gas_Wells           = "mining",          # wellheads = extraction
    Equipment_and_Components        = "mining",          # field equipment at production sites
    Tank_Battery                    = "mining",          # tank groups at well sites
    Injection_and_Disposal          = "mining",          # injection wells = extraction operations
    Natural_Gas_Flaring_Detections  = "mining",          # co-located with production
    Offshore_Platforms              = "mining",          # offshore extraction
    Gathering_and_Processing        = "industrial",      # gas processing plants
    Crude_Oil_Refineries            = "industrial",      # OSM: industrial = "refinery"
    LNG_Facilities                  = "industrial",      # large terminal facilities
    Natural_Gas_Compressor_Stations = "utilities_other", # OSM: man_made = "pumping_station"
    Stations_Other                  = "utilities_other", # pump/valve stations
    Petroleum_Terminals             = "storage"          # OSM: industrial = "oil_storage"
  )

  OGIM_prep <- OGIM_flat |> fcompute(
    id = paste("OGIM", ogim_id,
               geohashTools::gh_encode(latitude, longitude, precision = 15), sep = "_"),
    lon = longitude,
    lat = latitude,
    ref = as.character(ogim_id),
    name = name_display,
    address = paste(country, state_prov, sep = ", "),
    source_orig = NA_character_,
    main_cat = ogim_cat_map[ogim_layer],
    main_tag = "ogim_oil_gas_layer",
    main_tag_value = ogim_layer,
    alt_cats = NA_character_,
    alt_tags_values = NA_character_,
    other_tags_values = paste0(
      'fac_type:"', fcoalesce(fac_type, ""), '", operator:"', fcoalesce(operator, ""),
      '", commodity:"', fcoalesce(commodity, ""), '", on_offshore:"', fcoalesce(on_offshore, ""),
      '", gas_capacity_mmcfd:"', fcoalesce(as.character(gas_capacity_mmcfd), ""),
      '", gas_throughput_mmcfd:"', fcoalesce(as.character(gas_throughput_mmcfd), ""),
      '", gas_flared_mmcf:"', fcoalesce(as.character(gas_flared_mmcf), ""),
      '", average_flare_temp_k:"', fcoalesce(as.character(average_flare_temp_k), ""),
      '", days_clear_observations:"', fcoalesce(as.character(days_clear_observations), ""),
      '", segment_type:"', fcoalesce(segment_type, ""),
      '", liq_throughput_bpd:"', fcoalesce(as.character(liq_throughput_bpd), ""),
      '", pipe_diameter_mm:"', fcoalesce(as.character(pipe_diameter_mm), ""),
      '", pipe_length_km:"', fcoalesce(as.character(pipe_length_km), ""),
      '", pipe_material:"', fcoalesce(pipe_material, ""),
      '", area_km2:"', fcoalesce(as.character(area_km2), ""),
      '", num_storage_tanks:"', fcoalesce(as.character(num_storage_tanks), ""),
      '", num_compr_units:"', fcoalesce(as.character(num_compr_units), ""),
      '", site_hp:"', fcoalesce(as.character(site_hp), ""), '"'
    ),
    variable = "liq_capacity_bpd",
    value = as.double(liq_capacity_bpd)
  )
  
  if (any_duplicated(OGIM_prep$id)) stop("OGIM: Duplicated ids")
  
  rm(OGIM_list, OGIM_flat); gc()
  
  #
  ### ITU nodes (telecom) -----------------------------------------------------------
  #
  
  ITU <- load_ITU_nodes()
  
  ITU_prep <- ITU |> fcompute(
    id = paste("ITU", id, geohashTools::gh_encode(lat, lon, precision = 15), sep = "_"),
    lon = lon,
    lat = lat,
    ref = as.character(id),
    name = name,
    address = paste(country, region, sep = ", "),
    source_orig = NA_character_,
    main_cat = "communications_network",
    main_tag = "type_infr",
    main_tag_value = type_infr,
    alt_cats = NA_character_,
    alt_tags_values = NA_character_,
    other_tags_values = paste0('layer:"', fcoalesce(layer, ""), '", node_id:"', fcoalesce(as.character(node_id), ""),
                              '", country:"', fcoalesce(country, ""), '", region:"', fcoalesce(region, ""),
                              '", type_:"', fcoalesce(as.character(type_), ""), '", uid:"', fcoalesce(as.character(uid), ""),
                              '", validity:"', fcoalesce(as.character(validity), ""), '"'),
    variable = NA_character_,
    value = NA_real_
  ) |> collap(~ id)
  
  if (any_duplicated(ITU_prep$id)) stop("ITU: Duplicated ids")
  
  rm(ITU); gc()
  
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
  
  if (any_duplicated(OZM_prep$id)) stop("OZM: Duplicated ids")
  
  rm(OZM); gc()

  #
  ### Combine all datasets -----------------------------------------------------------
  #
  
  fsq_list <- if (fsq) list(FSP = FSP_prep) else list()
  atp_list <- if (atp) list(ATP = ATP_prep) else list()
  points_combined <- do.call(rowbind, c(
    list(
      OSM_points = OSM_points_prep,
      OSM_multipolygons = OSM_multipolygons_prep,
      OVP = OVP_prep
    ),
    fsq_list,
    atp_list,
    list(
      OCID = OCID_prep,
      GIP = GIP_prep,
      GEMCEM = CEMENT_prep,
      GEMIRON = IRON_prep,
      GEMCHEM = CHEM_prep,
      GEMSTEEL = STEEL_prep,
      SAM = SAM_prep,
      OGIM = OGIM_prep,
      ITU = ITU_prep,
      PW = PW_prep,
      OZM = OZM_prep
    ),
    list(idcol = "source")
  ))
  
  dir.create(dirname(out), recursive = TRUE, showWarnings = FALSE)
  qs2::qs_save(points_combined, out)
  out
}


deduplicate_points <- function(points,
                               out = "data/combined/points_deduplicated.qs",
                               exempt_sources = c("PW", "OZM", "WPI", "WBP"),
                               important_sources = c("GIP", "GPP", "GSP", "NHF"),
                               shift_steps = 0:9,
                               cell_tolerance_m = 10,
                               shift_step_m = 1) {
  points <- qDT(points)
  required_cols <- c("source", "lon", "lat", "main_cat", "value")
  missing_cols <- setdiff(required_cols, names(points))
  if (length(missing_cols)) {
    stop("deduplicate_points: points is missing required columns: ", paste(missing_cols, collapse = ", "))
  }

  if (anyNA(points$source) || anyNA(points$lon) || anyNA(points$lat)) {
    stop("deduplicate_points: source, lon, and lat must not contain missing values.")
  }

  deg_per_meter <- 1 / (40075017 / 360)
  cell_tolerance_deg <- cell_tolerance_m * deg_per_meter
  shift_step_deg <- shift_step_m * deg_per_meter

  points_exempt <- fsubset(points, source %in% exempt_sources | is.na(main_cat))
  points_dedup <- fsubset(points, source %!in% exempt_sources & !is.na(main_cat))

  if (!fnrow(points_dedup)) {
    out_tbl <- points
  } else {
    value_for_weight <- pmax(replace_na(suppressWarnings(as.numeric(points_dedup$value)), 0), 0)
    points_dedup[, lon_cos := lon * cos(lat * pi / 180)]
    points_dedup[, weight := 1 + log(iif(source %in% important_sources, fmax(value_for_weight) + 1, value_for_weight + 1)) / 1e5]

    shift_grid <- expand.grid(
      lon_nudge = shift_steps * shift_step_deg,
      lat_nudge = shift_steps * shift_step_deg
    )

    for (i in seq_row(shift_grid)) {
      n <- fnrow(points_dedup)
      points_dedup %<>% fmutate(
        dup_id = finteraction(
          main_cat,
          TRA(lon_cos + shift_grid$lon_nudge[i], cell_tolerance_deg, "-%%"),
          TRA(lat + shift_grid$lat_nudge[i], cell_tolerance_deg, "-%%"),
          factor = FALSE
        )
      ) %>%
        fsubset(source == fmode(source, dup_id, weight, "fill"))
      cat("Dups removed:", n - fnrow(points_dedup), "\n")
    }

    points_dedup[, c("lon_cos", "weight", "dup_id") := NULL]
    out_tbl <- rowbind(points_exempt, get_vars(points_dedup, names(points_exempt)))
  }

  dir.create(dirname(out), recursive = TRUE, showWarnings = FALSE)
  qs2::qs_save(out_tbl, out)
  out
}

