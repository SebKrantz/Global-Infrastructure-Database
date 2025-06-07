overture_foursquares_to_osm_det <- list(
  port = list(
    foursquares = list(level2_category_name = "Port") # add "Harbor or Marina"? also in overture "marina"
  ),
  military = list(
    overture = list(category = c("armed_forces_branch", "military_surplus_store")),
    foursquares = list(level3_category_name = "Military")
  ),
  power_plant_large = list(
    overture = list(V3 = c("energy_company", "electric_utility_provider", "electricity_supplier", "energy_equipment_and_solution", "power_plants_and_power_plant_service", "wind_energy")), 
    foursquares = list(level2_category_name = c("Power Plant", "Renewable Energy Service"))
  ),
  education_essential = list(
    overture = list(V2 = c("college_university", "school")), # "adult_education"?
    foursquares = list(level2_category_name = c("College and University", "Primary and Secondary School"))
  ),
  accommodation = list(
    overture = list(V1 = "accommodation"),
    foursquares = list(level2_category_name = "Lodging")
  ),
  food = list(
    overture = list(V2 = "restaurant"),
    foursquares = list(level2_category_name = c("Restaurant", "Dessert Shop", "Breakfast Spot", "Cafeteria", "Creperie", 
                                                "Night Market", "Food Truck", "Food Stand", "Food Court", "Donut Shop", "Snack Place"))
  ),
  drinking = list(
    overture = list(V1 = "eat_and_drink"), # Any other items
    foursquares = list(level1_category_name = "Dining and Drinking") # Any other items
  ),
  health_essential = list(
    overture = list(V2 = c("doctor", "dentist", "medical_center", "hospital", "childrens_hospital", "pharmacy", 
                           "community_health_center", "public_health_clinic", "women's_health_clinic")),
    foursquares = list(level2_category_name = c("Physician", "Urgent Care Center", "Medical Center", "Hospital", 
                                                "Healthcare Clinic", "Emergency Service", "Dentist", "Women's Health Clinic", "Pharmacy"))
  ),
  pets = list(
    overture = list(V1 = "pets", V3 = c("pet_store", "dog_park")),
    foursquares = list(level2_category_name = c("Pet Service", "Pet Supplies Store", "Veterinarian", "Dog Park")) # Needs to be before health_other
  ),
  education_other = list(
    overture = list(V1 = "education"), # Any other features
    foursquares = list(level2_category_name = "Education")
  ),
  health_other = list(
    overture = list(V1 = "health_and_medical"), # Any other features
    foursquares = list(level1_category_name = "Health and Medicine") # Any other features
  ),
  mining = list(
    overture = list(category = c("mining", "b2b_energy_mining"))
  ),
  farming = list(
    overture = list(V2 = c("b2b_agriculture_and_food", "farm_equipment_repair_service"), 
                    V3 = c("agricultural_production", "agricultural_seed_store", "farming_equipment_store", "poultry_farm")),
    foursquares = list(category_name = c("Farm", "Agriculture and Forestry Service", "Stable"))
  ),
  museums = list(
    overture = list(V2 = c("museum", "art_gallery", "planetarium")),
    foursquares = list(level2_category_name = c("Museum", "Art Gallery", "Planetarium"))
  ),
  parks_and_nature = list(
    overture = list(V2 = "park",
                    category = c("botanical_garden", "campground",  
                                 "national_park", "nature_reserve", "park", 
                                 "petting_zoo", "playground", "marina",
                                 "wildlife_sanctuary", "zoo", "water_park", # water park ??
                                 "natural_hot_springs")),
    foursquares = list(level2_category_name = c("Park", "Botanical Garden", "Garden", "Water Park", "Harbor or Marina",
                                                "Hiking Trail", "Hot Spring", "Nature Preserve", "Zoo"))
  ),
  beaches_and_resorts = list(
    overture = list(category = c("beach", "beach_resort", "resort", "ski_resort")),
    foursquares = list(category_name = c("Ski Resort and Area", "Resort", "Beach", "Nudist Beach", "Country Club")) # Resort also in Lodging (= accommodation)
  ),
  outdoor_activities = list(
    overture = list(category = c("canoe_and_kayak_hire_service", "diving_center", "paddleboarding_center", "fishing_club", "fishing_charter",
                                 "hiking_trail", "horse_riding", "horseback_riding_service", "horse_boarding",
                                 "kiteboarding", "mountain_bike_trails", "rock_climbing_spot", "flyboarding_center", "jet_skis_rental",
                                 "scuba_diving_center", "scuba_diving_instruction", "hang_gliding_center",
                                 "sky_diving", "snorkeling", "surfing", "ski_and_snowboard_school", "bike_rentals", "boat_rental_and_training")),
    foursquares = list(category_name = c("Sailing Club", "Scuba Diving Instructor", "Rafting Spot", "Water Sports",
                                         "Canoe and Kayak Rental", "Surfing", "Rafting Outfitter", "Skydiving Center", # Stores??
                                         "Skydiving Drop Zone", "Surf Spot", "Surf Store"))
    # leisure = c("swimming_area", "fishing"),
    # sport = c(
    #   "water_sports", "scuba_diving", "surfing", "climbing", "sailing",
    #   "kitesurfing", "ultralight_aviation", "free_flying", "canoe", "skiing",
    #   "climbing_adventure", "canoe_sailing", "sailing_canoe",
    #   "sailing_water_ski_windsurfing", "sailing_kitesurfing_windsurfing_kayaking",
    #   "gliding", "parachuting", "free_diving", "windsurfing", "wind_surfing",
    #   "kite", "diving", "fishing", "flying", "surfing_sailing",
    #   "surfing_windsurfing", "surfing_kitesurfing_windsurfing",
    #   "kitesurfing_windsurfing", "surf", "kitesurfing_surfing", "surf_surfing",
    #   "water_sports_surf_sailing_fishing"
    # ),
    # tourism = c("trail_riding_station", "rock_climing", "horsetrails"),
    # landuse = "winter_sports"
  ),
  performing_arts = list(
    overture = list(category = c("arts_and_entertainment", "cinema", "circus", "cultural_center", "choir", "opera_and_ballet",
      "jazz_and_blues", "music_venue", "performing_arts", "theatre", "laser_tag", "marching_band", "comedy_club", "eatertainment",
      "theatrical_productions", "topic_concert_venue", "theaters_and_performance_venues", "drive_in_theater"), 
      V2 = c("cinema", "festival")),
    foursquares = list(level2_category_name = c("Performing Arts Venue", "Movie Theater", "Carnival"))
    # amenity = c("arts_centre", "theatre", "cinema"), leisure = "bandstand"
  ),
  nightlife = list(
    overture = list(category = c("adult_entertainment", "casino", "comedy_club", "karaoke", "dance_club", "lounge", "salsa_club")),
    foursquares = list(level1_category_name = "Nightlife Spot",
                       level2_category_name = c("Dance Hall", "Strip Club", "Karaoke Box", "Country Dance Club", "Party Center", 
                                                "Salsa Club", "Night Club", "Casino"))
    # amenity = c(
    #   "casino", "love_hotel", "nightclub", "gambling", "brothel", "stripclub",
    #   "swingerclub"
    # ),
    # leisure = "dance"
  ),
  gaming = list(
    overture = list(category = c("amusement_park", "arcade", "betting_center", "bingo_hall", "bowling_alley", 
                                 "pool_billiards", "go_kart_club", "miniature_golf_course", "paintball")),
    foursquares = list(category_name = c("Gaming Cafe", "Amusement Park", "Betting Shop", "Bowling Alley", "Pool Hall", "Mini Golf Course"))
    # craft = "amusement_arcade",
    # leisure = c("amusement_arcade", "adult_gaming_centre", "miniature_golf"),
    # sport = c(
    #   "10_pin_bowling", "bowls", "bowling", "10pin_9pin", "archery", "10pin",
    #   "gaelic_games", "bullfighting", "miniature_golf", "9pin", "billiards",
    #   "snooker", "10pin_billiards", "table_soccer_darts_billiards",
    #   "billiards_snooker_soccer"
    # )
  ),
  tours_and_sightseeing = list(
    overture = list(V2 = c("tours", "travel_services", "agriturismo")), 
    foursquares = list(level2_category_name = c("Tourist Information and Service", "Travel Agency", "General Travel", "Cruise", "Hot Air Balloon Tour Agency"))
    # tourism = c("!no", "!picnic_site"),
    # shop = "travel_agency",
    # office = c("travel_agency", "tourism", "travel_agent", "guide")
  ),
  sports = list(
    overture = list(V1 = "active_life"),
    foursquares = list(level1_category_name = "Sports and Recreation")
    # building = c("stadium", "grandstand", "pavilion", "sports_hall", "riding_hall", "sports_centre"),
    # leisure = c(
    #   "stadium", "sports_centre", "pitch", "track", "swimming_pool",
    #   "fitness_centre", "fitness_station", "golf_course", "sports_hall"
    # ),
    # office = "sports",
    # shop = "sports",
    # sport = "!no"
  ),
  institutional = list(
    office = c(
      "government", "ngo", "association", "diplomatic", "political_party",
      "red_cross", "ministry_of_labour", "administrative",
      "international_organization", "charity", "union",
      "monuments_and_relics_commission", "organisation_de_la_societe_civile",
      "association_cooperative", "cooperative", "association_political_party",
      "igo", "un", "unhcr_office", "foundation", "labour_union", "municipality",
      "tax", "taxe", "goverment", "immigration", "development_agency_office",
      "non_government_association", "foreign_national_agency", "politique",
      "student", "student_union", "humanitarian", "party", "intenational_ngo",
      "international_ngo", "ingo", "association_ngo", "ecowas_institution",
      "gouvernement", "asociation", "institute", "company_government", "politician",
      "quango", "qquango", "forestry", "administration"
    ),
    building = "government",
    landuse = "institutional"
  ),
  public_service = list(
    amenity = c(
      "community_centre", "courthouse", "fire_station", "police", "post_box",
      "post_depot", "post_office", "prison", "ranger_station", "townhall",
      "public_building"
    ),
    building = c("fire_station", "public"),
    office = c("police", "visa", "communal", "sos_childrens_village")
  ),
  professional_services = list(
    leisure = "hackerspace",
    craft = c("it_consulting", "graphic_design"),
    office = c(
      "research", "it", "coworking", "graphic_design", "engineer", "architect",
      "lawyer", "law_firm", "geodesist", "land_surveyors", "civil_engineer",
      "topographer", "web_design",
      "smith_aegis_plc_leading_digital_marketing_advertising_pr_agency",
      "incubator", "consultants", "consulting", "landscape_architects", "designer",
      "engineering", "gis_and_drone_surveying", "notary", "surveyor",
      "private_investigator"
    )
  ),
  business_services = list(
    office = c(
      "advertising_agency", "employment_agency", "printing", "aerial_photographer",
      "property_management", "corporate_cleaning_hygiene_and_pest_control_services",
      "emplyment_agency", "wedo_business_solutions", "publisher", "courier"
    )
  ),
  home_services = list(
    amenity = "crematorium",
    craft = c(
      "caterer", "gardener", "gardening", "cleaning", "building_maintenance",
      "signmaker", "pest_control", "sweep"
    ),
    office = c(
      "event_management", "interior_design", "wedding_planner", "estate_agency",
      "estate_agent", "estate", "security"
    ),
    shop = c("dry_cleaning", "laundry", "funeral_directors")
  ),
  storage = list(
    building = c("hangar", "storage_tank", "silo", "warehouse"),
    landuse = "depot",
    man_made = c("silo", "storage_tank"),
    industrial = c(
      "depot", "storage", "oil_storage", "warehouse", "fuel_depot", "vehicle_depot",
      "container_yard", "empty_container_depot", "grain_storage_centre"
    ),
    office = "depot_de_boisson"
  ),
  communications_network = list(
    telecom = "",
    utility = "telecom",
    communication = c("line", "pole", "mobile", "mobile_phone", "mobile_phone=yes"),
    man_made = c(
      "satellite_dish", "beacon", "antenna", "communication_tower",
      "communications_tower"
    ),
    `tower:type` = c("communication", "radar", "radio_transmitter", "telecommunication", "radio"),
    industrial = c("communication", "telecommunication")
  ),
  communications_other = list(
    amenity = c("telephone", "internet_cafe", "studio"),
    office = c(
      "telecommunication", "telecom", "radio_station", "newspaper",
      "radio_chretienne", "communication_agency", "telecommunications",
      "communication"
    )
  ),
  automotive = list(
    craft = c(
      "motorcycle_repair", "motocycle_repair", "garage_moto", "car_repair",
      "vulcanize", "vulcanizer"
    ),
    amenity = c(
      "parking", "fuel", "vehicle_inspection", "parking_space", "car_wash",
      "car_rental", "motorcycle_parking", "car_sharing", "charging_station",
      "compressed_air", "boat_rental", "parking_entrance", "boat_sharing"
    ),
    industrial = "car_repair",
    shop = c(
      "car_repair", "car_parts", "car", "tyres", "motorcycle", "fuel",
      "motorcycle_repair", "motorcycle_parts"
    )
  ),
  bicycle = list(
    amenity = c("bicycle_parking", "bicycle_repair_station", "bicycle_rental", "bicycle_wash"),
    shop = "bicycle",
    highway = "cycleway"
  ),
  public_transport = list(public_transport = "!no", amenity = "bus_station", office = "public_transport"),
  water_transport = list(
    amenity = "ferry_terminal",
    waterway = c("dam", "weir", "lock_gate", "boatyard", "dock", "fuel", "canal", "river")
  ),
  transport_infrastructure = list(
    aerialway = "!no",
    aeroway = "!no",
    amenity = "grit_bin",
    bridge = "!no",
    building = c("train_station", "bridge"),
    highway = "!no",
    junction = "!no",
    man_made = c("bridge", "goods_conveyor"),
    railway = "!no",
    landuse = "railway",
    industrial = c("intermodal_freight_terminal", "terminal")
  ),
  transport_services = list(
    amenity = "taxi",
    building = "transportation",
    office = c(
      "logistics", "moving_company", "transport", "airline", "transmaritime",
      "shipping_agent", "logistic", "association_de_transport"
    ),
    industrial = "logistics"
  ),
  industrial = list(
    industrial = "",
    man_made = c("kiln", "works"),
    building = c("industrial", "manufacture"),
    landuse = "industrial"
  ),
  wholesale = list(
    office = c("pharmaceutical_products_wholesaler", "office_supplies"),
    shop = c("wholesale", "warehouse"),
    wholesale = "!no"
  ),
  shopping_essential = list(
    craft = "bakery",
    amenity = c("marketplace", "shop"),
    shop = c(
      "convenience", "kiosk", "clothes", "supermarket", "bakery", "butcher",
      "greengrocer", "beverages", "department_store", "shopping_centre", "mall",
      "general", "general_store", "local_shop", "grocery"
    ),
    building = c("supermarket", "kiosk")
  ),
  beauty = list(
    craft = c("wellness", "hairdresser"),
    shop = c("hairdresser", "beauty", "cosmetics")
  ),
  financial = list(
    amenity = c(
      "atm", "bank", "bureau_de_change", "mobile_money", "mobile_money_agent",
      "money_transfer", "payment_terminal", "payment_centre"
    ),
    office = c(
      "insurance", "financial", "accountant", "tax_advisor", "financial_advisor",
      "financial_services", "accounting_firm", "insurance_broker",
      "health_insurance", "tresor_de_mbacke", "finance", "investment", "bank",
      "insurance_company"
    )
  ),
  religion = list(
    amenity = c("funeral_hall", "grave_yard", "monastery", "place_of_mourning", "place_of_worship"),
    building = c(
      "cathedral", "chapel", "church", "kingdom_hall", "monastery", "mosque",
      "presbytery", "shrine", "synagogue", "temple", "religious"
    ),
    office = c("religion", "church", "parish"),
    landuse = c("religious", "cemetery"),
    religion = c("!no", "!none"),
    denomination = ""
  ),
  construction = list(
    building = "construction",
    highway = "construction",
    landuse = "construction",
    construction = "!no"
  ),
  waste = list(
    amenity = c(
      "sanitary_dump_station", "recycling", "waste_basket", "waste_disposal",
      "waste_transfer_station"
    ),
    water = "wastewater",
    man_made = "wastewater_plant",
    waterway = c("sanitary_dump_station", "wastewater"),
    landuse = "landfill"
  ),
  commercial = list(
    office = c("company", "yes", "commercial", "office", "building", "private"),
    building = c("commercial", "office"),
    landuse = "commercial"
  ),
  power_plant_small = list(
    overture = list(V3 = "wind_energy"), 
    foursquares = list(level2_category_name = "Renewable Energy Service")
  ),
  power_other = list(
    overture = list(category = c("energy_company", "electric_utility_provider", 
                                 "electricity_supplier", "energy_equipment_and_solution", 
                                 "solar_installation", "solar_panel_cleaning"))
  ),
  utilities_other = list(
    man_made = c(
      "water_tower", "water_well", "water_works", "water_tap", "water_tank",
      "gasometer", "pipeline", "pump", "pumping_rig", "pumping_station",
      "reservoir_covered", "street_cabinet"
    ),
    water = "reservoir",
    office = "water_utility",
    waterway = c(
      "drain", "spillway", "distribution_tower", "drain_building_drain",
      "drain_inlet", "drain_pipe_inflow", "drain_outflow", "drain_culvert_entrance",
      "drain_bridge", "underground_drain", "drain_junction", "drain_silt_trap"
    ),
    building = c("digester", "service", "water_tower"),
    landuse = "reservoir"
  ),
  craft = list(craft = ""),
  office_other = list(office = "!no"),
  shopping_other = list(shop = c("!no", "!vacant"), building = "retail", landuse = "retail"),
  facilities = list(
    overture = list(V2 = "exhibition_and_trade_center"),
    amenity = c(
      "events_venue", "exhibition_centre", "conference_centre", "public_bath",
      "public_bookcase", "social_centre", "toilets", "refugee_site", "shelter",
      "childcare", "dressing_room", "bbq", "shower", "kitchen", "drinking_water",
      "fountain", "vending_machine", "watering_place", "bench", "water_point",
      "parcel_locker", "clock", "give_box", "photo_booth"
    ),
    leisure = c("picnic_table", "common"),
    building = c("toilets", "civic"),
    office = "event_hall",
    tourism = "picnic_site"
  ),
  residential = list(
    building = c(
      "house", "apartments", "bungalow", "detached", "semidetached_house",
      "terrace", "dormitory", "residential"
    ),
    `building:use` = c("residential", "apartments"),
    landuse = "residential"
  ),
  historic = list(historic = "!no"),
  emergency = list(emergency = "!no")
)
