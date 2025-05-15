# constructive::construct(rapply(osm_class_improved, proc_items, how = "list"))

osm_reclass <- list(
  military = list(
    category = c("military", "office_other"),
    building = c("barracks", "bunker", "military"),
    landuse = "military",
    office = "military",
    military = ""
  ),
  education_essential = list(
    category = c("education", "education_alt", "office_other"),
    amenity = c("college", "school", "university"),
    building = c("university", "school", "college"),
    landuse = "education", 
    office = c("school", "university", "educational_institution",  
               "school_office", "rectorat", "education")
  ),
  education_other = list(
    category = c("education_alt", "craft", "office_other"),
    craft = "organization",
    amenity = c(
      "kindergarten", "library", "music_school", "driving_school", "training",
      "language_school"
    ),
    building = "kindergarten",
    office = "computer_training_school"
  ),
  health_essential = list(
    category = c("health", "office_other"),
    amenity = c("hospital", "clinic", "pharmacy", "doctors", "veterinary", "dentist"),
    building = "hospital",
    healthcare = c(
      "clinic", "centre", "primary", "yes", "hospital", "nurse", "centre_de_sante",
      "pharmacy", "doctor", "birthing_centre", "health_center", "hospital_doctor",
      "hospital_pharmacy", "doctor_laboratory_pharmacy", "clinic_doctor_laboratory",
      "psychiatry", "paediatrics", "dentist_p", "health_care",
      "centre_de_sante_integre", "birthing_center", "vaccination_centre",
      "doctor_pharmacy_birthing_center", "center", "pharmacy_doctor", "midwife",
      "dentist", "hospital_clinic", "public", "general_practitioner",
      "health_post", "poste_dev_sante", "poste_de_sante", "health_outpost",
      "community_health_post", "community_health_worker", "community_health_work"
    ),
    office = c("physician", "healthcare", "health_care")
  ),
  health_specialized = list(
    category = c("health", "office_other"),
    healthcare = c(
      "hyperbaric_chamber", "laboratory", "occupational_therapist",
      "kinesiotherapy", "optometrist", "podiatrist", "gyrotonic_clinic",
      "audiologist"
    ), 
    office = c("skin_care_clinic", "skincare")
  ),
  health_other = list(
    category = c("health", "craft", "office_other"),
    amenity = c("nursing_home", "baby_hatch"),
    craft = "dental_technician",
    healthcare = c(
      "counselling", "physiotherapist", "speech_therapist", 
      "alternative", "rehabilitation", "psychotherapist", 
      "dispensory", "hospice", "blood_donation", "urgencias_medicas_e_laboratorio",
      "nursing_home", "traditional", "tetiary", "dispensary", "urban", "spa",
      "blood_bank", "office", "*", "infirmier", "ecole_se_sante", "maternity",
      "syndicate", "soins", "over_the_counter_medicine", "sample_collection",
      "secondary", "tertiary", "general_maternity_etc", "usine", "source", "eglise",
      "bureau", "pressing"
    ),
    office = c("medical", "therapist")
  ),
  farming = list(
    category = "farming",
    building = c(
      "greenhouse", "barn", "farm_auxiliary", "farm", "stable", "sty", "cowshed",
      "slurry_tank"
    ),
    landuse = c(
      "farmland", "orchard", "vineyard", "greenhouse_horticulture", 
      "farmyard", "plant_nursery", "aquaculture"
    ),
    man_made = "beehive",
    place = "farm"
  ),
  accommodation = list(
    category = c("accommodation", "tourism"),
    building = "hotel",
    tourism = c("hotel", "guest_house", "motel", "hostel", "chalet", "apartment", "wilderness_hut",
                "alpine_hut", "lodge", "cabin", "house", "apartments", "hunting_lodge", "batiment", 
                "guest_house_hotel", "apartment_hotel", "hotel_apartment", "luxury_lodge", "holiday_home")
  ),
  food = list(
    category = c("food", "craft", "tourism", "shopping"),
    amenity = c("restaurant", "cafe", "food_court", "fast_food", "ice_cream"),
    craft = "ice_cream",
    tourism = "restaurant",
    shop = "restaurant"
  ),
  drinking = list(
    category = "food",
    amenity = c("bar", "pub")
  ),
  institutional = list(
    category = c("institutional", "office_other"),
    building = "government",
    landuse = "institutional",
    office = c("government", "red_cross", "ministry_of_labour", "diplomatic", "ngo", "political_party", "association", 
               "administrative", "international_organization", "charity", 
               "union", "monuments_and_relics_commission", "organisation_de_la_societe_civile",
               "association_cooperative", "cooperative", "association_political_party",
               "igo", "un", "unhcr_office", "foundation", "labour_union", "municipality", "tax", "taxe",  #public tresor, import taxes etc.
               "goverment", "immigration", "development_agency_office", "non_government_association", 
               "foreign_national_agency", "politique", "student", "student_union", "humanitarian", "party",
               "intenational_ngo", "international_ngo", "ingo",  "association_ngo", "ecowas_institution",
               "gouvernement", "asociation", "institute",  "company_government", "politician", "quango", 
               "qquango", "forestry", "administration")
  ),
  public_service = list(
    category = c("public_service", "recreation", "office_other"),
    amenity = c(
      "community_centre", "public_building", "prison", "post_office", "townhall",
      "police", "courthouse", "fire_station", "ranger_station", "post_depot", "post_box"
    ),
    building = c("public", "fire_station"),
    office = c("police", "visa", "communal", "sos_childrens_village")
  ),
  storage = list(
    category = c("storage", "industrial", "office_other"),
    building = c("hangar", "storage_tank", "silo"),
    landuse = "depot",
    man_made = c("silo", "storage_tank"),
    industrial = c("depot", "storage", "oil_storage", "warehouse", "fuel_depot", "vehicle_depot", 
                   "container_yard", "empty_container_depot", "grain_storage_centre"),
    office = "depot_de_boisson"
  ),
  # Make separate category
  communications_network = list(
    category = c("communications", "industrial"),
    communication = c("line", "pole", "mobile", "mobile_phone", "mobile_phone=yes"),
    telecom = c(
      "exchange", "data_center", "shelter", "remote_terminal", "antenna",
      "connection_point", "pole", "service_device", "distribution_point", "reseau"
    ),
    utility = "telecom",
    man_made = c("satellite_dish", "communications_tower", "beacon", "antenna", "communication_tower"),
    `tower:type` = c("communication", "radar", "radio_transmitter", "telecommunication", "radio"),
    industrial = c("communication", "telecommunication")
  ),
  communications_other = list(
    category = c("communications", "creativity", "office_other"), # studio is tv or radio station
    amenity = c("telephone", "internet_cafe", "studio"),
    # communication = c("line", "pole", "mobile", "mobile_phone", "mobile_phone=yes"),
    man_made = c("lighthouse"), # "satellite_dish", "communications_tower", "beacon", "antenna", "communication_tower"),
    office = c("telecommunication", "telecom", "radio_station", "newspaper", 
               "radio_chretienne", "communication_agency", "telecommunications", "communication")
    # `tower:type` = c("communication", "radar", "radio_transmitter", "telecommunication", "radio"),
    # industrial = c("communication", "telecommunication")
  ),
  automotive = list(
    category = c("transport", "craft", "industrial", "shopping"),
    craft = c(
      "motorcycle_repair", "motocycle_repair", "garage_moto", "car_repair",
      "vulcanize", "vulcanizer"
    ),
    amenity = c(
      "parking", "fuel", "vehicle_inspection", "parking_space", "car_wash",
      "car_rental", "bicycle_parking", "motorcycle_parking", "car_sharing",
      "charging_station", "compressed_air", "bicycle_repair_station", "boat_rental",
      "bicycle_rental", "parking_entrance", "boat_sharing"
    ), 
    industrial = "car_repair",
    shop = c("car_repair", "car_parts", "car", "tyres", "motorcycle", "bicycle", 
             "fuel", "motorcycle_repair", "motorcycle_parts")  
  ),
  transport_other = list(
    category = c("transport", "industrial", "office_other"),
    aerialway = "!no", # all except no
    aeroway = "!no", # all except no
    amenity = c("grit_bin", "ferry_terminal", "bus_station", "taxi"), # Other items are "automotive"
    bridge = "!no", # all except no
    building = c("train_station", "transportation", "bridge"),
    highway = "", # all
    junction = "", # all
    man_made = c("bridge", "goods_conveyor"),
    office = c("logistics", "moving_company", "transport", "logistics", "public_transport", "airline", "transmaritime", "shipping_agent",
               "logistic", "association_de_transport"), 
    public_transport = "", # all: could make separate category...
    railway = "", # all
    landuse = "railway",
    industrial = c("logistics", "intermodal_freight_terminal", "terminal"),
    waterway = c("dam", "weir", "lock_gate", "boatyard", "dock", "fuel", "canal", "river")
  ),
  shopping_essential = list(
    category = c("shopping", "craft"),
    craft = "bakery", # No shop, could be wholesale
    amenity = c("marketplace", "shop"),   
    shop = c("convenience", "kiosk", "clothes", "supermarket", "bakery", "butcher", "greengrocer", "beverages",
             "department_store", "shopping_centre", "mall", "general", "general_store", "local_shop", "grocery", "yes"), # yes is very general, but mostly grocery shops
    building = c("retail", "supermarket", "kiosk"),
    landuse = "retail" # essential shopping ??
  ),
  beauty = list(
    category = c("shopping", "craft"),
    craft = c("wellness", "hairdresser"),
    shop = c("hairdresser", "beauty", "cosmetics")
  ),
  wholesale = list(
    category = c("shopping", "office_other", "shopping"),
    building = "warehouse",
    office = c("pharmaceutical_products_wholesaler", "office_supplies"),
    shop = c("wholesale", "warehouse")
  ),
  construction = list(
    category = c("craft", "industrial", "construction", "office_other", "shopping"),
    craft = c(
      "builder", "boatbuilder", "furniture", "furniture_maker", "carpenter",
      "charpenter", "carpet_layer", "plumber", "plaster", "plasterer",
      "electrician", "tiler", "locksmith", "woodworker", 
      "metal_lather", "welder", "welding", "tinsmith", "silversmith", "timberman",
      "stonemason", "construction", "painter", "insulation", "window_construction",
      "floorer", "rigger", "roofer", "paver", "joiner", "key_cutter",
      "parquet_layer", "cabinet_maker", "construction_company", "scaffolder",
      "construction_metallique", "brickmaker", "chemical_construction",
      "door_construction", "aluminum_construction", "upholsterer_carpenter", "glaziery"
    ),
    building = "construction",
    landuse = "construction",
    industrial = c("construction", "construction_company", "building_materials", "furniture"),
    office = c("construction_company", "construction", "plumber"),
    shop = c("glaziery", "locksmith", "cement", "doityourself", "building_materials")
  ),
  mining = list(
    category = c("mining", "industrial", "farming"),
    landuse = c("quarry", "salt_pond"),
    man_made = c("tailings_pond", "adit", "petroleum_well", "mineshaft"),
    industrial = c("mine", "salt_ponds", "salt_pond", "hydrocarbon_field")
  ),
  industrial = list(
    category = c("industrial", "craft"),
    craft = c(
      "sawmill", "saw_mill", "grinding_mill", "metal_construction", "turner",
      "tournage", "distillery", "oil_mill", "flour_mill", "corn_mill", "miller",
      "grounding_mill", "aluminum", "metal_works", "air_conditioning", "chemist", "plastic",
      "waterproofing", "machinery", "agricultural_engines",
      "auto_engines", "grinding_mill_distillery", "brewery", "mechanic",
      "mecanician"
    ),
    industrial = c( # Includes some mining related things, should combine with mining !!
      "industrial",  "manufacturing",
      "distributor", # Seems to contain some public utility companies...
      "oil", "refinery", "gas", "natural_gas", "oil_mill",
      "brewery", "sawmill", "factory", "railway", "food", "automobile", "wellsite", "cement", 
      "soutenir_la_zone_industrielle", "tailings", "sugar_refinery", 
      "steelmaking", "sugar_mill", "office", "works", "beverages", "grinding_mill", 
      "aluminium_smelting", "mineral_processing", "electrical", "cooling", "phosphate", 
      "water_treatment", "slaughterhouse", "fish_processing", "agrifood",  "paper_mill",
      "auto_wrecker", "concentrator", "petrochemical", "water", "timber", "food_processing", 
      "ice_factory", "metal_processing", "paper", "concrete_plant", "aggregate", "rice_mill", 
      "bakery", "textile", "quarry", "sugar", "cobalt_mining", "steelworks",
      "ferrochrome", "panel_beater", "precast_concrete", "garage", "paper_recycling", 
      "natural_ston_workshop", "plastic", "piping", "coffee", "wood", "machine_shop", "cotton_gin",
      "desalination", "chemical", "winery", "pump_house", "pumping_station",
      "packaging", "workshop", "water_works", "lumber_yard", "sand", "food_industry", 
      "pool_yard", "printing", "boatyard", "entrepot", 
      "yard", "scrap_yard", "brickyard", "shipyard", "well_cluster", "scrapper",
      "coton", "cottage_workshops", "substation", "fracking", "petroleum", "dairy",
      "truckstop_yard", "building_aggregates", "sugar_processing", "farm", "machinery"
    ),
    building = "industrial",
    landuse = "industrial",
    man_made = c("works", "kiln")
  ),
  financial = list(
    category = c("financial", "office_other"),
    amenity = c("bank", "atm", "bureau_de_change", "money_transfer", "mobile_money_agent", "mobile_money"),
    office = c("insurance", "financial", "accountant", "tax_advisor", "financial_advisor", 
               "financial_services", "accounting_firm", "insurance_broker", "health_insurance",
               "tresor_de_mbacke", "finance", "investment", "bank", "insurance_company")
  ),
  religion = list(
    category = c("religion", "office_other"),
    amenity = c("place_of_worship", "monastery", "grave_yard", "place_of_mourning"),
    building = c(
      "church", "mosque", "monastery", "cathedral", "temple", "chapel", "religious",
      "synagogue", "shrine", "presbytery"
    ),
    denomination = "", # all
    landuse = "religious",
    office = c("religion", "church", "parish"), # Parish is mostly religion...
    religion = c("!no", "!none")
  ),
  professional_services = list(
    category = c("creativity", "office_other"),
    leisure = "hackerspace",
    craft = c("it_consulting", "graphic_design"),
    office = c("research", "it", "coworking", "graphic_design", "engineer", 
               "architect", "lawyer", "law_firm", "geodesist", "land_surveyors",
               "civil_engineer",  "topographer", "web_design",
               "smith_aegis_plc_leading_digital_marketing_advertising_pr_agency", 
               "incubator", "consultants", "consulting", "landscape_architects", "designer", "engineering",
               "gis_and_drone_surveying", "notary", "surveyor", "private_investigator")
  ),
  business_services = list(
    category = "office_other", 
    office = c("advertising_agency", "employment_agency", "printing", 
               "aerial_photographer", "property_management", 
               "corporate_cleaning_hygiene_and_pest_control_services", 
               "emplyment_agency",  "wedo_business_solutions", "publisher", "courier")
  ),
  home_services = list(
    category = c("craft", "office_other", "shopping", "religion"),
    amenity = "crematorium",
    craft = c(
      "caterer", "gardener", "gardening", "cleaning", "building_maintenance",
      "signmaker", "pest_control", "sweep"
    ),
    office = c("event_management", "estate_agent", "interior_design", "wedding_planner", 
               "estate_agency", "estate_agent", "estate", "security"),
    shop = c("dry_cleaning", "laundry", "funeral_directors")
  ),
  residential = list(
    category = "residential",
    building = c(
      "dormitory", "apartments", "detached", "residential", "house", "terrace",
      "semidetached_house", "bungalow"
    ),
    `building:use` = c("residential", "apartments"),
    landuse = "residential"
  ),
  commercial = list(
    category = c("commercial", "commerical", "office_other"), # commerical was spelling mistake
    building = c("commercial", "office"), # Big category...
    landuse = "commercial",
    office = c("company", "yes", "commercial", "office", "building", "private")
  ),
  historic = list(
    category = "historic", 
    historic = "" # all
  ),
  power = list(
    category = c("power", "industrial", "craft", "office_other"),
    craft = "solar_energy",
    building = "transformer_tower",
    power = "",
    `tower:type` = "power",
    utility = "power",
    industrial = c("power", "geothermal", "electricity"),
    office = c("energy_supplier", "electricite")
  ),
  utilities_other = list(
    category = c("waste", "industrial", "utilities_other", "office_other", "transport", "shopping"), # categories "waste" and utilities_other + some offices
    building = c("service", "water_tower"),
    amenity = c(
      "recycling", "waste_disposal", "waste_transfer_station",
      "sanitary_dump_station", "waste_basket"
    ),
    landuse = c("landfill", "reservoir"),
    man_made = c(
      "wastewater_plant", "water_works", "water_well", "water_tank",
      "pumping_station", "water_tower", "reservoir_covered", "gasometer",
      "pipeline", "street_cabinet", "pump", "water_tap", "pumping_rig"
    ),
    water = c("wastewater", "reservoir"),
    industrial = c("interwaste", "wastewater_treatment_plant", "waste_handling"),
    office = "water_utility",
    shop = c("energy", "gas"), # energy and gas here mostly cooking gas. Could also be shopping_other
    waterway = c("drain", "spillway", "distribution_tower", "sanitary_dump_station", "drain_building_drain",
                 "drain_inlet", "drain_pipe_inflow", "drain_outflow", "drain_culvert_entrance",
                 "drain_bridge", "wastewater", "underground_drain", "drain_junction", "drain_silt_trap")
  ),
  museums = list(
    category = c("entertainment", "tourism"),
    amenity = "planetarium",
    tourism = c("museum", "gallery", "aquarium", "monument", "gallery_museum")
  ),
  parks_and_nature = list(
    category = c("recreation", "tourism"),
    leisure = c("nature_reserve", "park", "water_park", "garden", "playground", "dog_park", "marina"),
    tourism = c("caravan_site", "nature", "picnic_site", "camp_site", "camp", "camp_pitch", "theme_park", "zoo", 
                "bird_watching_and_fishing", "wetland", "bird_sanctuary"), 
    landuse = "recreation_ground"
  ),
  tours_and_sightseeing = list(
    category = c("tourism", "office_other"),
    office = c("travel_agency", "tourism", "travel_agent", "guide"),
    shop = "travel_agency",
    tourism = c("viewpoint", "game_hide", "wiewpoint", "travel_agent", "attraction", "information", "artwork", 
                "hiking_tours", "yes", "true", "lieu_historique", "ruins", "lean_to", 
                "wine_cellar", "winery", "popa_falls", "attraction_office", "tour_operator", "to_guano_cave", 
                "middle_kingdom_tombs", "temple_ruins", "company", "board", "statue")
  ),
  outdoor_activities = list(
    category = c("recreation", "sports", "tourism"),
    leisure = c("swimming_area", "fishing"),
    sport = c("water_sports", "scuba_diving", "surfing", "climbing", "sailing", "kitesurfing", 
              "ultralight_aviation", "free_flying", "canoe", "skiing", "climbing_adventure",
              "canoe_sailing", "sailing_canoe", "sailing_water_ski_windsurfing",
              "sailing_kitesurfing_windsurfing_kayaking", "gliding", "parachuting",
              "free_diving", "windsurfing", "wind_surfing", "kite", "diving", "fishing",
              "flying", "surfing_sailing", "surfing_windsurfing", "surfing_kitesurfing_windsurfing",
              "kitesurfing_windsurfing", "surf", "kitesurfing_surfing", "surf_surfing", 
              "water_sports_surf_sailing_fishing"),
    tourism = c("trail_riding_station", "rock_climing", "horsetrails")
  ),
  performing_arts = list(
    category = c("entertainment"),
    amenity = c("arts_centre", "theatre", "cinema"),
    leisure = "bandstand"
  ),
  nightlife = list( # casino could be gaming...
    category = "entertainment",
    amenity = c("casino", "love_hotel", "nightclub", "gambling", "brothel", "stripclub"),
    leisure = "dance"
  ),
  gaming = list(
    category = c("entertainment", "craft", "recreation", "sport"),
    craft = "amusement_arcade",
    leisure = c("amusement_arcade", "adult_gaming_centre", "miniature_golf"),
    sport = c("10_pin_bowling", "bowls", "bowling", "10pin_9pin", # "shooting_range", "shooting": now sport (rest)
              "archery", "10pin", "gaelic_games", "bullfighting", "miniature_golf", "9pin", 
              "billiards", "snooker", "10pin_billiards", "table_soccer_darts_billiards", "billiards_snooker_soccer")
  ),
  beaches_and_resorts = list(
    category = c("recreation", "tourism"),
    leisure = "beach_resort",
    tourism = c("resort", "beach", "spa_resort", "holiday_resort")
  ),
  facilities = list(
    category = c("facilities", "health", "entertainment", "creativity", "recreation", "office_other"),
    amenity = c(
      "events_venue", "exhibition_centre", "conference_centre", "public_bath", # TODO: commercial??
      "public_bookcase", "social_centre", "social_facility", 
      "toilets", "refugee_site", "shelter", "childcare", "dressing_room", "bbq",
      "shower", "kitchen", "drinking_water", "fountain", "vending_machine",
      "watering_place", "bench", "water_point", "parcel_locker", "clock",
      "give_box", "photo_booth"
    ),
    leisure = c("picnic_table", "common"),
    building = c("toilets", "civic"), 
    office = "event_hall"
    # tourism = "picnic_site" # moved to parks and natur
  ),
  emergency = list(category = "emergency", emergency = ""),
  SEZ = list(category = "SEZ", special_economic_zone = "open_zone_map_2021"),
  port = list(
    category = c("port", "industrial", "office_other"),
    industrial = c("port_yard", "harbour", "container_terminal"),
    office = "harbour_master",
    port = "world_port_index_2015"
  ),
  sport = list(
    category = c("sports", "office_other", "shopping"),
    building = c("stadium", "grandstand", "pavilion", "sports_hall", "riding_hall"),
    leisure = c(
      "stadium", "sports_centre", "pitch", "track", "swimming_pool",
      "fitness_centre", "fitness_station"
    ),
    office = "sports",
    shop = "sports",
    sport = "" # rest (all others not used in outdoor_activities and gaming)
  ),
  # TODO: Could create separate shopping_craft category...
  shopping_other = list(
    category = c("shopping", "craft"),
    shop = "", # All other shops not classified elsewhere
    # c("tailor", "hardware", "electronics", "mobile_phone", "variety_store", "furniture", 
    #   "boutique", "alcohol", "stationery", "copyshop", "computer", "books", "shoes", 
    #   "gift", "jewelry", "chemist", "kitchen", "seafood", "doityourself", "trade", # trade shop could also be construction or wholesale.. but not clearly defined. 
    #   "optician", "confectionery", "pastry", "video", "houseware", "photo", "agrarian",
    #   "pet", "florist", "bookmaker", "perfumery", "...", "sewing"),
    craft = c(
      "handicraft", "hardware", "winery", "photographer", "beekeeper",
      "photographic_laboratory", "optician", "tailor", "print", "sculptor", "art",
      "art_painter", "toolmaker", "makerspace", 
      "clothes", "embroiderer", "weaver", "upholsterer", "basket_weaver",
      "musical_instrument", "bag", "tannery", "printer", "dressmaker",
      "dressmarker", "dressmakere", "dressmarket", "dressmakers", "dressmakert",
      "leathre", "tailoring", "sun_protection", "maroquinerie_leather_goods",
      "shoemaker", "pottery", "blacksmith", "stand_builder", "winepress", "cheese",
      "imprint", "weaving", "bookbinder", "artist", "clockmaker", "saddler",
      "photo_studio", "print_shop", "printmaker", "computer", "textile_printing",
      "watchmaker", "jeweller", "basket_maker", "sewing", "tea", "basket_weaving",
      "printmarker", "atelier", "pan_production", "confectionery", "tents",
      "fishnet", "wood_market", "dressmaker_beauty", "knife_sharpener",
      "pressing_shopping", "pastry", "fabric", "dryer", "dyer", "repair",
      "electronics", "electronics_repair", "electonics_repair", "electronic_repair",
      "haberdashery", "workshop", "tisserant", "serigraphie", "vente_de_recharge",
      "couture", "cold", "bijoutier_createur", "model", "hvac", "yes", "*"
    )
  )
)
