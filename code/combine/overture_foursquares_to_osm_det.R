

overture_foursquares_to_osm_det <- list(
  port = list(
    # industrial = c("port", "port_yard", "harbour", "container_terminal"),
    # office = "harbour_master",
    # `seamark:type` = "harbour",
    # landuse = "port"
    foursquares = list(level2_category_name = "Port") # add "Harbor or Marina"? also in overture "marina"
  ),
  military = list(
    # military = "",
    # building = c("military", "barracks", "bunker"),
    # landuse = "military"
    overture = list(category = c("armed_forces_branch", "military_surplus_store")),
    foursquares = list(level3_category_name = "Military")
  ),
  power_plant_large = list(
    # power = "plant"
    overture = list(V3 = c("energy_company", "electric_utility_provider", "electricity_supplier", "energy_equipment_and_solution", "power_plants_and_power_plant_service", "wind_energy")), 
    foursquares = list(level2_category_name = c("Power Plant", "Renewable Energy Service"))
  ),
  education_essential = list(
    # amenity = c("college", "school", "university"),
    # building = c("college", "school", "university")
    overture = list(V2 = c("college_university", "school")), # "adult_education"?
    foursquares = list(category_name = c("Private School", "Religious School"),
      level3_category_name = c("College and University", "Primary and Secondary School"))
  ),
  accommodation = list(
    # tourism = c(
    #   "hotel", "guest_house", "motel", "hostel", "chalet", "apartment",
    #   "wilderness_hut", "alpine_hut", "lodge", "cabin", "house", "apartments",
    #   "hunting_lodge", "batiment", "guest_house_hotel", "apartment_hotel",
    #   "hotel_apartment", "luxury_lodge", "holiday_home"
    # ),
    # building = "hotel"
    overture = list(V1 = "accommodation"),
    foursquares = list(category_name = "Mountain Hut",
      level2_category_name = "Lodging")
  ),
  food = list(
    # amenity = c("fast_food", "food_court", "cafe", "ice_cream", "restaurant"),
    # tourism = "restaurant",
    # shop = c("restaurant", "ice_cream")
    overture = list(V2 = "restaurant"),
    foursquares = list(category_name = c("Bagel Shop", "Street Food Gathering", "Airport Food Court"),
      level2_category_name = c("Restaurant", "Dessert Shop", "Breakfast Spot", "Cafeteria", "Creperie", 
                               "Night Market", "Food Truck", "Food Stand", "Food Court", "Donut Shop", "Snack Place"))
  ),
  drinking = list(
    # amenity = c("bar", "pub")
    overture = list(V1 = "eat_and_drink"), # Any other items
    foursquares = list(level1_category_name = "Dining and Drinking") # Any other items
  ),
  health_essential = list(
    # amenity = c("clinic", "dentist", "doctors", "hospital", "pharmacy"),
    # building = "hospital",
    # healthcare = c(
    #   "clinic", "centre", "primary", "yes", "hospital", "nurse", "centre_de_sante",
    #   "pharmacy", "doctor", "birthing_centre", "health_center", "hospital_doctor",
    #   "hospital_pharmacy", "doctor_laboratory_pharmacy", "clinic_doctor_laboratory",
    #   "psychiatry", "paediatrics", "dentist_p", "health_care",
    #   "centre_de_sante_integre", "birthing_center", "vaccination_centre",
    #   "doctor_pharmacy_birthing_center", "center", "pharmacy_doctor", "midwife",
    #   "dentist", "hospital_clinic", "public", "general_practitioner", "health_post",
    #   "poste_dev_sante", "poste_de_sante", "health_outpost",
    #   "community_health_post", "community_health_worker", "community_health_work"
    # ),
    # office = c("physician", "healthcare", "health_care")
    overture = list(V2 = c("doctor", "dentist", "medical_center", "hospital", "childrens_hospital", "pharmacy", 
                           "community_health_center", "public_health_clinic", "women's_health_clinic")),
    foursquares = list(level2_category_name = c("Physician", "Urgent Care Center", "Medical Center", "Hospital", 
                                                "Healthcare Clinic", "Emergency Service", "Dentist", 
                                                "Maternity Clinic", "Women's Health Clinic", "Pharmacy", 
                                                "Nurse"))
  ),
  pets = list(
    # amenity = c("veterinary", "dog_toilet"), 
    # leisure = "dog_park"
    overture = list(V1 = "pets", V3 = c("pet_store", "dog_park")),
    foursquares = list(category_name = "Animal Shelter",
      level2_category_name = c("Pet Service", "Pet Supplies Store", "Veterinarian", "Dog Park")) # Needs to be before health_other
  ),
  education_other = list(
    # amenity = c(
    #   "driving_school", "kindergarten", "language_school", "library", "training",
    #   "music_school", "research_institute"
    # ),
    # office = c("educational_institution", "tutoring", "computer_training_school"),
    # building = "kindergarten",
    # landuse = "education"
    overture = list(V1 = "education"), # Any other features
    foursquares = list(category_name = c("Library", "Tutoring Service", "Samba School"), 
                       level2_category_name = "Education") # Anything else...
  ),
  health_other = list(
    # amenity = c("nursing_home", "baby_hatch", "social_facility"),
    # craft = "dental_technician",
    # healthcare = "!no",
    # office = c("medical", "therapist", "skin_care_clinic", "skincare")
    overture = list(V1 = "health_and_medical"), # Any other features
    foursquares = list(
      level1_category_name = "Health and Medicine") # Any other features
  ),
  mining = list(
    # man_made = c("tailings_pond", "adit", "petroleum_well", "mineshaft"),
    # industrial = c("mine", "salt_ponds", "salt_pond", "hydrocarbon_field"),
    # landuse = c("quarry", "salt_pond")
    overture = list(category = c("mining", "b2b_energy_mining"))
  ),
  farming = list(
    # place = "farm",
    # man_made = "beehive",
    # building = c(
    #   "farm", "barn", "cowshed", "farm_auxiliary", "greenhouse", "slurry_tank",
    #   "stable", "sty"
    # ),
    # landuse = c(
    #   "farmland", "farmyard", "orchard", "vineyard", "aquaculture",
    #   "greenhouse_horticulture", "plant_nursery"
    # )
    overture = list(V2 = c("b2b_agriculture_and_food", "farm_equipment_repair_service"), 
                    V3 = c("agricultural_production", "agricultural_seed_store", "farming_equipment_store", "poultry_farm")),
    foursquares = list(category_name = c("Farm", "Agriculture and Forestry Service", "Stable", "Vineyard"))
  ),
  museums = list(
    # amenity = "planetarium",
    # tourism = c("museum", "gallery", "art_gallery", "aquarium", "monument", "gallery_museum")
    overture = list(V2 = c("museum", "art_gallery", "planetarium")),
    foursquares = list(category_name = c("Exhibit", "Fair", "Aquarium"),
                       level2_category_name = c("Museum", "Art Gallery", "Public Art", "Planetarium"))
  ),
  parks_and_nature = list(
    # leisure = c(
    #   "nature_reserve", "park", "water_park", "garden", "playground", "marina",
    #   "recreation_ground", "schoolyard"
    # ),
    # tourism = c(
    #   "nature", "theme_park", "zoo", "bird_watching_and_fishing", "wetland",
    #   "bird_sanctuary"
    # ),
    # landuse = "recreation_ground"
    overture = list(V2 = "park",
                    category = c("botanical_garden", "campground",  
                                 "national_park", "nature_reserve", "park", 
                                 "petting_zoo", "playground", "marina",
                                 "wildlife_sanctuary", "zoo", "water_park", # water park ??
                                 "natural_hot_springs")),
    foursquares = list(category_name = c("Summer Camp", "Trailer Park", "Campground", "RV Park", "Rest Area",
                                         "Bay", "Bathing Area", "Cave", # Tours and Sightseeing?
                                         "Island", "Lake", "Hill", "Mountain", "Forest", "Field"), # Farming?
      level2_category_name = c("Park", "Botanical Garden", "Garden", "Water Park", "Harbor or Marina",
                               "Hiking Trail", "Hot Spring", "Nature Preserve", "Zoo"), 
      level1_category_name = "Landmarks and Outdoors") # Anything else, but remove States and Municipalities!!!
  ),
  beaches_and_resorts = list(
    # leisure = c("beach_resort", "resort"),
    # tourism = c("resort", "beach", "spa_resort", "holiday_resort")
    overture = list(category = c("beach", "beach_resort", "resort", "ski_resort")),
    foursquares = list(category_name = c("Ski Resort and Area", "Resort", "Beach", "Nudist Beach", "Country Club", 
                                         "Ski Chalet", "Ski Lodge")) # Resort also in Lodging (= accommodation)
  ),
  outdoor_activities = list(
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
    overture = list(category = c("canoe_and_kayak_hire_service", "diving_center", "paddleboarding_center", "fishing_club", "fishing_charter",
                                 "hiking_trail", "horse_riding", "horseback_riding_service", "horse_boarding",
                                 "kiteboarding", "mountain_bike_trails", "rock_climbing_spot", "flyboarding_center", "jet_skis_rental",
                                 "scuba_diving_center", "scuba_diving_instruction", "hang_gliding_center",
                                 "sky_diving", "snorkeling", "surfing", "ski_and_snowboard_school", "bike_rentals", "boat_rental_and_training")),
    foursquares = list(category_name = c("Sailing Club", "Dive Spot", "Scuba Diving Instructor", "Rafting Spot", "Water Sports",
                                         "Canoe and Kayak Rental", "Surfing", "Rafting Outfitter", "Skydiving Center", # Stores??
                                         "Skydiving Drop Zone", "Surf Spot", "Surf Store", "Disc Golf", "Disc Golf Course", # Disc Golf could be sports??
                                         "Bike Trail", "Rock Climbing Spot", "Hunting Area", "Ski Chairlift", "Ski Trail", 
                                         "Bike Rental", "Boat Rental")) 
  ),
  performing_arts = list(
    # amenity = c("arts_centre", "theatre", "cinema"), 
    # leisure = "bandstand"
    overture = list(category = c("arts_and_entertainment", "cinema", "circus", "cultural_center", "choir", "opera_and_ballet",
      "jazz_and_blues", "music_venue", "performing_arts", "theatre", "laser_tag", "marching_band", "comedy_club", "eatertainment",
      "theatrical_productions", "topic_concert_venue", "theaters_and_performance_venues", "drive_in_theater"), 
      V2 = c("cinema", "festival")),
    foursquares = list(category_name = c("Cultural Center", "Carnival", "Circus", "Escape Room", "General Entertainment"), # public_service?
                       level3_category_name = c("Festival", "Music Festival", "Parade"),
                       level2_category_name = c("Performing Arts Venue", "Movie Theater", "Entertainment Event"))
                       # Arts and Entertainment - anything else?

  ),
  nightlife = list(
    # amenity = c(
    #   "casino", "love_hotel", "nightclub", "gambling", "brothel", "stripclub",
    #   "swingerclub"
    # ),
    # leisure = "dance"
    overture = list(category = c("adult_entertainment", "casino", "comedy_club", "karaoke", "dance_club", "lounge", "salsa_club")),
    foursquares = list(level1_category_name = "Nightlife Spot",
                       level2_category_name = c("Dance Hall", "Strip Club", "Karaoke Box", "Country Dance Club", "Party Center", 
                                                "Salsa Club", "Night Club", "Casino", "Comedy Club")) # Comedy Club not performing arts?
  ),
  gaming = list(
    # craft = "amusement_arcade",
    # leisure = c("amusement_arcade", "adult_gaming_centre", "miniature_golf"),
    # sport = c(
    #   "10_pin_bowling", "bowls", "bowling", "10pin_9pin", "archery", "10pin",
    #   "gaelic_games", "bullfighting", "miniature_golf", "9pin", "billiards",
    #   "snooker", "10pin_billiards", "table_soccer_darts_billiards",
    #   "billiards_snooker_soccer"
    # )
    overture = list(category = c("amusement_park", "arcade", "betting_center", "bingo_hall", "bowling_alley", 
                                 "pool_billiards", "go_kart_club", "miniature_golf_course", "paintball")),
    foursquares = list(category_name = c("Gaming Cafe", "VR Cafe", "Arcade", "Bingo Center", "Betting Shop", "Bowling Alley", 
                                         "Pool Hall", "Mini Golf Course", "Go Kart Track", "Laser Tag Center", "Pachinko Parlor"), 
                       level2_category_name = "Amusement Park")
  ),
  tours_and_sightseeing = list(
    # tourism = c("!no", "!picnic_site"),
    # shop = "travel_agency",
    # office = c("travel_agency", "tourism", "travel_agent", "guide")
    overture = list(V2 = c("tours", "travel_services", "agriturismo")), 
    foursquares = list(category_name = c("Scenic Lookout", "Sculpture Garden"),
      level2_category_name = c("Tourist Information and Service", "Travel Agency", "General Travel", "Cruise", 
                               "Hot Air Balloon Tour Agency"))
  ),
  sports = list(
    # building = c("stadium", "grandstand", "pavilion", "sports_hall", "riding_hall", "sports_centre"),
    # leisure = c(
    #   "stadium", "sports_centre", "pitch", "track", "swimming_pool",
    #   "fitness_centre", "fitness_station", "golf_course", "sports_hall"
    # ),
    # office = "sports",
    # shop = "sports",
    # sport = "!no"
    overture = list(V1 = "active_life"),
    foursquares = list(category_name = "Sporting Event",
                       level1_category_name = "Sports and Recreation", # Sensible?
                       level2_category_name = "Stadium")
  ),
  institutional = list(
    # office = c(
    #   "government", "ngo", "association", "diplomatic", "political_party",
    #   "red_cross", "ministry_of_labour", "administrative",
    #   "international_organization", "charity", "union",
    #   "monuments_and_relics_commission", "organisation_de_la_societe_civile",
    #   "association_cooperative", "cooperative", "association_political_party",
    #   "igo", "un", "unhcr_office", "foundation", "labour_union", "municipality",
    #   "tax", "taxe", "goverment", "immigration", "development_agency_office",
    #   "non_government_association", "foreign_national_agency", "politique",
    #   "student", "student_union", "humanitarian", "party", "intenational_ngo",
    #   "international_ngo", "ingo", "association_ngo", "ecowas_institution",
    #   "gouvernement", "asociation", "institute", "company_government", "politician",
    #   "quango", "qquango", "forestry", "administration"
    # ),
    # building = "government",
    # landuse = "institutional"
    overture = list(category = c("law_enforcement", "central_government_office", "federal_government_offices", 
                                 "local_and_state_government_offices", "embassy", "chambers_of_commerce", 
                                 "national_security_services", "political_party_office"), 
                    V2 = "organization"),
    foursquares = list(category_name = "Government Lobbyist",
      level2_category_name = c("Government Building", "Organization")) # Match after public_service (everything else)
  ),
  public_service = list(
    # amenity = c(
    #   "community_centre", "courthouse", "fire_station", "police", "post_box",
    #   "post_depot", "post_office", "prison", "ranger_station", "townhall",
    #   "public_building"
    # ),
    # building = c("fire_station", "public"),
    # office = c("police", "visa", "communal", "sos_childrens_village")
    foursquares = list(category_name = c("Prison", "Public and Social Service", "Town Hall", 
                                         "Senior Citizen Service", "Social Club", "Polling Place", 
                                         "Homeless Shelter", "Observatory", "Rehabilitation Center", # Health Other (Reha-Klinik?)
                                         "Public Bathroom", "Fire Station", "Domestic Abuse Treatment Center", "Addiction Treatment Center",
                                         "Community Center", "Retirement Home", # Residential?
                                         "Probation Office", "Courthouse", "Post Office", "Police Station",
                                         "Law Enforcement and Public Safety", "Disabled Persons Service", "Dump"), 
                       level1_category_name = "Community and Government") # Anything else
                                         
  ),
  professional_services = list(
    # leisure = "hackerspace",
    # craft = c("it_consulting", "graphic_design"),
    # office = c(
    #   "research", "it", "coworking", "graphic_design", "engineer", "architect",
    #   "lawyer", "law_firm", "geodesist", "land_surveyors", "civil_engineer",
    #   "topographer", "web_design",
    #   "smith_aegis_plc_leading_digital_marketing_advertising_pr_agency",
    #   "incubator", "consultants", "consulting", "landscape_architects", "designer",
    #   "engineering", "gis_and_drone_surveying", "notary", "surveyor",
    #   "private_investigator"
    # )
    foursquares = list(category_name = c("Agriculture and Forestry Service", 
                                         "Appraiser", "Architecture Firm", "Art Restoration Service", 
                                         "Art Studio", "Audiovisual Service", "Career Counselor",
                                         "Computer Repair Service", "Construction", "Creative Service",
                                         "Design Studio", "Engineer", "Film Studio", "Geological Service",
                                         "Laboratory", "Management Consultant", "Market Research and Consulting Service",
                                         "Business and Strategy Consulting Office", "Coworking Space",
                                         "Building and Land Surveyor", "Real Estate Appraiser", 
                                         "Research Laboratory", "Research Station", "Software Company",
                                         "Website Designer", "Technology Business", "IT Service",
                                         "Translation Service", "Writing, Copywriting and Technical Writing Service"), # "Tech Startup"?
                       level2_category_name = "Legal Service") # level1_category_name = "Business and Professional Services" -> includes all services but also storage facilities etc. 
  ),
  business_services = list(
    # office = c(
    #   "advertising_agency", "employment_agency", "printing", "aerial_photographer",
    #   "property_management", "corporate_cleaning_hygiene_and_pest_control_services",
    #   "emplyment_agency", "wedo_business_solutions", "publisher", "courier"
    # )
    foursquares = list(category_name = c("Advertising Agency", "Automation and Control System", 
                                         "Business Service", "Direct Mail and Email Marketing Service", 
                                         "Search Engine Marketing and Optimization Service",
                                         "Employment Agency", "Equipment Rental Service", # Wholesale?
                                         "Human Resources Agency", "Import and Export Service", 
                                         "Logging Service", "Online Advertising Service", 
                                         "Print, TV, Radio and Outdoor Advertising Service",
                                         "Promotional Item Service", "Public Relations Firm",
                                         "Publisher", "Real Estate Development and Title Company", 
                                         "Commercial Real Estate Developer", # "Property Management Office" ?
                                         "Business and Professional Services"), 
                       level2_category_name = "Photography Service") 
  ),
  home_services = list(
    # amenity = c("childcare", "crematorium"),
    # craft = c(
    #   "caterer", "gardener", "gardening", "cleaning", "building_maintenance",
    #   "signmaker", "pest_control", "sweep", 
    # ),
    # office = c(
    #   "event_management", "interior_design", "wedding_planner", "estate_agency",
    #   "estate_agent", "estate", "security"
    # ),
    # shop = c("dry_cleaning", "laundry", "funeral_directors")
    overture = list(category = "child_care_and_day_care"),
    foursquares = list(category_name = c("Laundromat", "Laundry Service", "Property Management Office", # facilities?
                                         "Real Estate Agency", "Real Estate Service", "Rental Service", 
                                         "Repair Service", "Shoe Repair Service", "Security and Safety", "Assisted Living"),
      level2_category_name = c("Home Improvement Service", "Child Care Service", 
                                                "Entertainment Agency", "Entertainment Service", "Event Service", 
                                                "Food and Beverage Service", "Funeral Home"))
  ),
  storage = list(
    # building = c("hangar", "storage_tank", "silo", "warehouse"),
    # landuse = "depot",
    # man_made = c("silo", "storage_tank"),
    # industrial = c(
    #   "depot", "storage", "oil_storage", "warehouse", "fuel_depot", "vehicle_depot",
    #   "container_yard", "empty_container_depot", "grain_storage_centre"
    # ),
    # office = "depot_de_boisson"
    foursquares = list(category_name = c("Storage Facility", "Distribution Center"))
  ),
  communications_network = list(
    # telecom = "",
    # utility = "telecom",
    # communication = c("line", "pole", "mobile", "mobile_phone", "mobile_phone=yes"),
    # man_made = c(
    #   "satellite_dish", "beacon", "antenna", "communication_tower",
    #   "communications_tower"
    # ),
    # `tower:type` = c("communication", "radar", "radio_transmitter", "telecommunication", "radio"),
    # industrial = c("communication", "telecommunication")
  ),
  communications_other = list(
    # amenity = c("telephone", "internet_cafe", "studio"),
    # office = c(
    #   "telecommunication", "telecom", "radio_station", "newspaper",
    #   "radio_chretienne", "communication_agency", "telecommunications",
    #   "communication"
    # )
    foursquares = list(category_name = c("Media Agency", "Mobile Company", "Radio Station", "Recording Studio", 
                                         "TV Station", "Telecommunication Service", "Internet Cafe", "Lighthouse"))
  ),
  automotive = list(
    # craft = c(
    #   "motorcycle_repair", "motocycle_repair", "garage_moto", "car_repair",
    #   "vulcanize", "vulcanizer"
    # ),
    # amenity = c(
    #   "parking", "fuel", "vehicle_inspection", "parking_space", "car_wash",
    #   "car_rental", "motorcycle_parking", "car_sharing", "charging_station",
    #   "compressed_air", "boat_rental", "parking_entrance", "boat_sharing"
    # ),
    # industrial = "car_repair",
    # shop = c(
    #   "car_repair", "car_parts", "car", "tyres", "motorcycle", "fuel",
    #   "motorcycle_repair", "motorcycle_parts"
    # )
    foursquares = list(category_name = c("Auto Workshop", "Automotive Shop", "Electric Vehicle Charging Station", 
                                         "Fuel Station", "Parking", "Rental Car Location"), # Transport service?
      level2_category_name = c("Automotive Retail", "Automotive Service"))
  ),
  bicycle = list(
    # amenity = c("bicycle_parking", "bicycle_repair_station", "bicycle_rental", "bicycle_wash"),
    # shop = "bicycle",
    # highway = "cycleway"
    foursquares = list(category_name = "Bicycle Store")
  ),
  public_transport = list(
    # public_transport = "!no", 
    # amenity = "bus_station", 
    # office = "public_transport"
    foursquares = list(category_name = c("Platform", "Bus Station", "Bus Stop", "Light Rail Station", "Metro Station", "Tram Station"),
                       level3_category_name = "Public Transportation") # Under transport service?
  ),
  water_transport = list(
    # amenity = "ferry_terminal",
    # waterway = c("dam", "weir", "lock_gate", "boatyard", "dock", "fuel", "canal", "river")
    foursquares = list(category_name = c("Boat Launch", "Canal", "Canal Lock", "Dam", "River", "Boat or Ferry", "Pier"))
  ),
  transport_infrastructure = list(
    # aerialway = "!no",
    # aeroway = "!no",
    # amenity = "grit_bin",
    # bridge = "!no",
    # building = c("train_station", "bridge"),
    # highway = "!no",
    # junction = "!no",
    # man_made = c("bridge", "goods_conveyor"),
    # railway = "!no",
    # landuse = "railway",
    # industrial = c("intermodal_freight_terminal", "terminal")
    foursquares = list(category_name = c("Bridge", "Tunnel", "Cable Car", "Toll Booth", "Toll Plaza", "Train", "Truck Stop"),
                       level2_category_name = c("Transport Hub", "Road", "Street"))
  ),
  transport_services = list(
    # amenity = "taxi",
    # building = "transportation",
    # office = c(
    #   "logistics", "moving_company", "transport", "airline", "transmaritime",
    #   "shipping_agent", "logistic", "association_de_transport"
    # ),
    # industrial = "logistics"
    foursquares = list(category_name = c("Shipping, Freight, and Material Transportation Service", 
                                         "Airport Service", "Airport Lounge", "Travel Lounge"),
                       level2_category_name = "Transportation Service",
                       level1_category_name = "Travel and Transportation") # Anything else 
  ),
  industrial = list(
    # industrial = "",
    # man_made = c("kiln", "works"),
    # building = c("industrial", "manufacture"),
    # landuse = "industrial"
    foursquares = list(category_name = c("Factory", "Manufacturer", "Chemicals and Gasses Manufacturer", # Craft?
                                         "Industrial Estate", "Brewery"))
  ),
  wholesale = list(
    # office = c("pharmaceutical_products_wholesaler", "office_supplies"),
    # shop = c("wholesale", "warehouse"),
    # wholesale = "!no"
    foursquares = list(category_name = c("Electrical Equipment Supplier", "Industrial Equipment Supplier", "Leather Supplier", 
                                         "Metals Supplier", "Paper Supplier", "Plastics Supplier", "Petroleum Supplier", 
                                         "Refrigeration and Ice Supplier", "Rubber Supplier", "Salvage Yard",
                                         "Scientific Equipment Supplier", "Warehouse", "Wholesaler", "Warehouse or Wholesale Store")) # Business Services?
  ),
  shopping_essential = list(
    # craft = "bakery",
    # amenity = c("marketplace", "shop"),
    # shop = c(
    #   "convenience", "kiosk", "clothes", "supermarket", "bakery", "butcher", "cheese_shop", "cheese", "dairy", "farm", "food",
    #   "greengrocer", "beverages", "department_store", "shopping_centre", "mall",
    #   "general", "general_store", "local_shop", "grocery", "drug_store", "drugstore"
    # ),
    # building = c("supermarket", "kiosk")
    foursquares = list(category_name = c("Bakery", "Convenience Store", "Department Store", # NOTE: Convenience Store could be shopping_other, but it's a debate...
                                         "Discount Store", "Butcher", "Drugstore", "Cheese Store", # "Duty-free Store"
                                         "Dairy Store", "Farmers Market", "Fish Market", "Fruit and Vegetable Store",
                                         "Meat and Seafood Store", "Sausage Store", "Supermarket", "Market",
                                         "Shopping Mall", "Shopping Plaza"), 
                       level3_category_name = "Grocery Store")
  ),
  beauty = list(
    # craft = c("wellness", "hairdresser"),
    # shop = c("hairdresser", "beauty", "cosmetics")
    foursquares = list(level2_category_name = "Health and Beauty Service")
  ),
  financial = list(
    # amenity = c(
    #   "atm", "bank", "bureau_de_change", "mobile_money", "mobile_money_agent",
    #   "money_transfer", "payment_terminal", "payment_centre"
    # ),
    # office = c(
    #   "insurance", "financial", "accountant", "tax_advisor", "financial_advisor",
    #   "financial_services", "accounting_firm", "insurance_broker",
    #   "health_insurance", "tresor_de_mbacke", "finance", "investment", "bank",
    #   "insurance_company"
    # )
    foursquares = list(category_name = "Insurance Agency",
      level2_category_name = "Financial Service")
  ),
  religion = list(
    # amenity = c("funeral_hall", "grave_yard", "monastery", "place_of_mourning", "place_of_worship"),
    # building = c(
    #   "cathedral", "chapel", "church", "kingdom_hall", "monastery", "mosque",
    #   "presbytery", "shrine", "synagogue", "temple", "religious"
    # ),
    # office = c("religion", "church", "parish"),
    # landuse = c("religious", "cemetery"),
    # religion = c("!no", "!none"),
    # denomination = ""
    foursquares = list(category_name = "Cemetery",
      level2_category_name = c("Spiritual Center", "Psychic and Astrologer"))
  ),
  construction = list(
    # building = "construction",
    # highway = "construction",
    # landuse = "construction",
    # construction = "!no"
  ),
  waste = list(
    # amenity = c(
    #   "sanitary_dump_station", "recycling", "waste_basket", "waste_disposal",
    #   "waste_transfer_station"
    # ),
    # water = "wastewater",
    # man_made = "wastewater_plant",
    # waterway = c("sanitary_dump_station", "wastewater"),
    # landuse = "landfill"
    foursquares = list(category_name = c("Waste Management Service", "Recycling Facility", 
                                         "Water Treatment Service"))
  ),
  commercial = list(
    # office = c("company", "yes", "commercial", "office", "building", "private"),
    # building = c("commercial", "office"),
    # landuse = "commercial"
    foursquares = list(level2_category_name = "Office")
  ),
  power_plant_small = list(
    # power = c("generator", "solar", "solar_panels", "wind", "wind_turbine")
    overture = list(V3 = "wind_energy"), 
    foursquares = list(category_name = "Windmill") # Could be historic, but the mode feature is a wind turbine. 
  ),
  power_other = list(
    # power = "",
    # utility = "power",
    # building = "transformer_tower",
    # `tower:type` = "power"
    overture = list(category = c("energy_company", "electric_utility_provider", 
                                 "electricity_supplier", "energy_equipment_and_solution", 
                                 "solar_installation", "solar_panel_cleaning")),
    foursquares = list(category_name = "Renewable Energy Service")
  ),
  utilities_other = list(
    # man_made = c(
    #   "water_tower", "water_well", "water_works", "water_tap", "water_tank",
    #   "gasometer", "pipeline", "pump", "pumping_rig", "pumping_station",
    #   "reservoir_covered", "street_cabinet"
    # ),
    # water = "reservoir",
    # office = "water_utility",
    # waterway = c(
    #   "drain", "spillway", "distribution_tower", "drain_building_drain",
    #   "drain_inlet", "drain_pipe_inflow", "drain_outflow", "drain_culvert_entrance",
    #   "drain_bridge", "underground_drain", "drain_junction", "drain_silt_trap"
    # ),
    # building = c("digester", "service", "water_tower"),
    # landuse = "reservoir"
    foursquares = list(category_name = c("Utility Company", "Reservoir", "Well"))
  ),
  craft = list(
    # craft = ""
    # shop = "locksmith"
    foursquares = list(category_name = c("Locksmith", "Tailor", "Welding Service", # "Welding Service" = business_services ? 
                                         "Cidery", "Winery", "Distillery", "Meadery"))
                                         
  ),
  office_other = list(
    # office = "!no"
  ),
  shopping_other = list(
    # shop = c("!no", "!vacant"), 
    # building = "retail", 
    # landuse = "retail"
    foursquares = list(category_name = c("Lottery Retailer", "Ticket Seller", "Machine Shop"), 
                       level2_category_name = "Marketplace", 
                       level1_category_name = "Retail") # Everything else
  ),
  facilities = list(
    # amenity = c(
    #   "events_venue", "exhibition_centre", "conference_centre", "public_bath",
    #   "public_bookcase", "social_centre", "toilets", "refugee_site", "shelter",
    #   "dressing_room", "bbq", "shower", "kitchen", "drinking_water",
    #   "fountain", "vending_machine", "watering_place", "bench", "water_point",
    #   "parcel_locker", "clock", "give_box", "photo_booth"
    # ),
    # leisure = c("picnic_table", "common"),
    # building = c("toilets", "civic"),
    # office = "event_hall",
    # tourism = "picnic_site"
    overture = list(V2 = "exhibition_and_trade_center"),
    foursquares = list(category_name = c("Auditorium", "Ballroom", "Business Center", # commercial?
                                         "Convention", "Convention Center", "Conference", "Conference Room", 
                                         "Event Space", "Outdoor Event Space", "Wedding Hall", "Fountain", 
                                         "Picnic Area", "Picnic Shelter", "Plaza", "Pedestrian Plaza", 
                                         "Roof Deck", "Structure", "Baggage Locker"), 
                       level1_category_name = "Event") # Anything else. 
  ),
  residential = list(
    # building = c(
    #   "house", "apartments", "bungalow", "detached", "semidetached_house",
    #   "terrace", "dormitory", "residential"
    # ),
    # `building:use` = c("residential", "apartments"),
    # landuse = "residential"
    foursquares = list(category_name = c("Housing Development", "Housing Authority"),
                       level2_category_name = "Residential Building")
  ),
  historic = list(
    # historic = "!no"
    foursquares = list(category_name = c("Castle", "Palace", "Memorial Site", "Monument"), 
                       level2_category_name = "Historic and Protected Site")
  ),
  emergency = list(
    # emergency = "!no"
    foursquares = list(level2_category_name = "Emergency Service")
  )
)
