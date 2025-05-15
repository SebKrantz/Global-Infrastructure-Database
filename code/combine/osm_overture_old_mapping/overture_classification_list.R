## Improved (more specific) categorization 

places_class <- list(
  
  military = c("armed_forces_branch", "military_surplus_store"),
  
  education_essential = c(
    "campus_building", "college_university", "education", "educational_services",
    "educational_research_institute", "elementary_school", "high_school",
    "medical_school", "middle_school", "private_school", "public_school",
    "religious_school", "school", "vocational_and_technical_school"
  ),
  
  education_other = c(
    "art_school", "bartending_school", "career_counseling", "computer_coaching",
    "cooking_school", "cosmetology_school", "dance_school", "day_care_preschool",
    "driving_school", "educational_camp", "flight_school",
    "language_school", "library", "massage_school", "music_school", "cycling_classes",
    "nursing_school", "preschool", "specialty_school",
    "speech_therapist", "test_preparation", "first_aid_class",
    "traffic_school", "tutoring_center", "book_magazine_distribution",
    "academic_bookstore", "educational_supply_store", "observatory"
  ),
  
  health_essential = c(
    "doctor", "hospital", "pharmacy", "dentist", "general_dentistry",
    "pediatrician", "family_practice", "internal_medicine",
    "physical_therapy", "psychologist", "nutritionist",  
    "veterinarian", "health_department", "medical_supply", 
    "health_and_medical", "medical_center", "women's_health_clinic"
  ),
  
  health_specialized = c(
    "anesthesiologist", "audiologist", "cardiologist", 
    "dermatologist", "dialysis_clinic", "endocrinologist", "gastroenterologist", 
    "nurse_practitioner", "obstetrician_and_gynecologist",
    "occupational_therapy", "oncologist", "optometrist", "oral_surgeon",
    "orthodontist", "orthopedist", "osteopathic_physician", "pediatric_dentist", 
    "plastic_surgeon", "podiatrist", "radiologist", "surgeon", "urologist", 
    "eye_care_clinic", "laser_eye_surgery_lasik", "ear_nose_and_throat", "abortion_clinic",
    "surgical_appliances_and_supplies", "surgical_center",
    "neurologist", "rheumatologist", "pulmonologist", "nephrologist", "neuropathologist",
    "gerontologist", "sports_psychologist", "proctologist", "prosthetics", "prosthodontist",
    "endodontist", "allergist", "periodontist", "health_consultant"
  ),

  health_other = c(
    "abuse_and_addiction_treatment", "acupuncture", "diagnostic_services", # ???
    "alcohol_and_drug_treatment_centers", "ambulance_and_ems_services", # emergency ??
    "aromatherapy", "blood_and_plasma_donation_center", "cannabis_clinic",
    "chiropractor", "counseling_and_mental_health", "naturopathic_holistic", 
    "disability_services_and_support_organization", "fertility", 
    "home_health_care", "massage_therapy", "medical_spa",
    "maternity_centers", "medical_service_organizations", "psychiatrist",
    "meditation_center", "mission", "prenatal_perinatal_care", "psychic",
    "psychotherapist", "senior_citizen_services", 
    "vitamins_and_supplements", "weight_loss_center", "reflexology", "hospice"
  ),
  
  farming = c(
    "agricultural_service", "agriculture", "animal_shelter", "dairy_farm", "farm", "farming_services",
    "fish_farm", "livestock_breeder", "poultry_far", "poultry_farm", "urban_farm", "equestrian_facility"
  ),
  
  mining = "mining",
  
  industrial = c(
    "aircraft_manufacturer", "appliance_manufacturer", "auto_company",
    "auto_manufacturers_and_distributors", "bags_luggage_company",
    "biotechnology_company", "bottled_water_company", "brewery",
    "business_manufacturing_and_supply", "chemical_plant", "clothing_company",
    "commercial_industrial", "commercial_refrigeration", "oil_refiners",
    "computer_hardware_company", "distillery", "glass_manufacturer",
    "industrial_company", "industrial_equipment", "oil_and_gas_field_equipment_and_services",
    "information_technology_company", "iron_and_steel_industry",
    "mattress_manufacturing", "metal_fabricator", "metal_supplier", "metal_plating_service",
    "motorcycle_manufacturer", "pharmaceutical_companies", "plastic_company",
    "plastic_fabrication_company", "plastic_manufacturer", "plastics",
    "tobacco_company", "wood_and_pulp"
  ),
  
  accommodation = c(
    "accommodation", "bed_and_breakfast", "cottage", "holiday_rental_home",
    "hostel", "hotel", "lodge", "rental_service", "resort", "retirement_home",
    "service_apartments", "motel", "inn", "guest_house", "cabin" # alt categories for cabin is mostly hotel
  ),
  
  food = c(
    "afghan_restaurant", "african_restaurant", "american_restaurant",
    "arabian_restaurant", "argentine_restaurant", "armenian_restaurant",
    "asian_fusion_restaurant", "asian_restaurant", "australian_restaurant",
    "austrian_restaurant", "azerbaijani_restaurant", "bagel_shop",
    "bangladeshi_restaurant", "bar_and_grill_restaurant", "barbecue_restaurant",
    "basque_restaurant", "belarusian_restaurant", "belgian_restaurant",
    "belizean_restaurant", "bolivian_restaurant", "brazilian_restaurant",
    "breakfast_and_brunch_restaurant", "british_restaurant", "bubble_tea",
    "buffet_restaurant", "bulgarian_restaurant", "burger_restaurant",
    "burmese_restaurant", "cafe", "cafetaria", "cajun_creole_restaurant",
    "cambodian_restaurant", "canadian_restaurant", "caribbean_restaurant",
    "catalan_restaurant", "chicken_restaurant", "chilean_restaurant",
    "chinese_restaurant", "coffee_shop", "colombian_restaurant",
    "comfort_food_restaurant", "costa_rican_restaurant", "cuban_restaurant",
    "cupcake_shop", "czech_restaurant", "delicatessen", "desserts",
    "dim_sum_restaurant", "diner", "dominican_restaurant", "doner_kebab",
    "donuts", "eastern_european_restaurant", "eat_and_drink",
    "ecuadorian_restaurant", "egyptian_restaurant", "ethiopian_restaurant",
    "european_restaurant", "fast_food_restaurant", "filipino_restaurant",
    "fish_and_chips_restaurant", "fondue_restaurant", "food", "food_banks",
    "food_stand", "food_truck", "french_restaurant", "frozen_yoghurt_shop",
    "gastropub", "gelato", "georgian_restaurant", "german_restaurant",
    "gluten_free_restaurant", "greek_restaurant", "guatemalan_restaurant",
    "haitian_restaurant", "halal_restaurant", "hawaiian_restaurant",
    "health_food_restaurant", "himalayan_nepalese_restaurant",
    "honduran_restaurant", "hong_kong_style_cafe", "hot_dog_restaurant",
    "hungarian_restaurant", "iberian_restaurant", "ice_cream_shop",
    "indian_restaurant", "indo_chinese_restaurant", "indonesian_restaurant",
    "irish_restaurant", "israeli_restaurant", "italian_restaurant",
    "jamaican_restaurant", "japanese_restaurant", "korean_restaurant",
    "kosher_restaurant", "kurdish_restaurant", "latin_american_restaurant",
    "lebanese_restaurant", "live_and_raw_food_restaurant", "malaysian_restaurant",
    "mediterranean_restaurant", "mexican_restaurant", "middle_eastern_restaurant",
    "molecular_gastronomy_restaurant", "mongolian_restaurant",
    "moroccan_restaurant", "nicaraguan_restaurant", "nigerian_restaurant",
    "night_market", "noodles_restaurant", "pakistani_restaurant",
    "panamanian_restaurant", "pancake_house", "persian_iranian_restaurant",
    "peruvian_restaurant", "pizza_restaurant", "polish_restaurant",
    "polynesian_restaurant", "portuguese_restaurant", "puerto_rican_restaurant",
    "restaurant", "romanian_restaurant", "russian_restaurant", "salad_bar",
    "salvadoran_restaurant", "sandwich_shop", "scandinavian_restaurant",
    "scottish_restaurant", "seafood_restaurant", "senegalese_restaurant",
    "shaved_ice_shop", "singaporean_restaurant", "slovakian_restaurant",
    "smoothie_juice_bar", "soul_food", "soup_restaurant",
    "south_african_restaurant", "southern_restaurant", "spanish_restaurant",
    "sri_lankan_restaurant", "steakhouse", "sushi_restaurant", "swiss_restaurant",
    "syrian_restaurant", "taco_restaurant", "taiwanese_restaurant", "tapas_bar",
    "tatar_restaurant", "tea_room", "texmex_restaurant", "thai_restaurant",
    "theme_restaurant", "turkish_restaurant", "ukrainian_restaurant",
    "uruguayan_restaurant", "uzbek_restaurant", "vegetarian_restaurant",
    "venezuelan_restaurant", "vietnamese_restaurant", "poke"
  ),
  
  drinking = c(
    "bar", "beer_bar", "beer_garden", "speakeasy",
    "champagne_bar", "cocktail_bar", "gay_bar", "hookah_bar", 
    "hotel_bar", "irish_pub", "pub", "sake_bar", "sports_bar", 
    "tiki_bar", "whiskey_bar", "wine_bar", "dive_bar"
  ),
  
  institutional = c(
    "agricultural_cooperatives", "central_government_office",
    "charity_organization", "embassy", "organization",
    "environmental_conservation_and_ecological_organizations",
    "environmental_conservation_organization", "labor_union", "social_and_human_services",
    "non_governmental_association", "social_service_organizations", "youth_organizations", # Public service??
    "nonprofits", "political_organization", "political_party_office",
    "private_association", "public_and_government_association"
  ),
  
  public_service = c( # local and state government should be public service?
    "local_and_state_government_offices", "government_services",
    "community_services_non_profits", "courthouse", 
    "fire_department", "fire_protection_service", "housing_authorities",
    "jail_and_prison", "law_enforcement", "passport_and_visa_services",
    "police_department", "post_office", "public_service_and_government",
    "town_hall", "community_center"
  ),
  
  storage = "storage_facility",
  
  communications_other = c(
    "broadcasting_media_production", "internet_cafe", "internet_service_provider",
    "lighthouse", "mass_media", "media_agency", "media_critic",
    "media_news_website", "movie_television_studio", "print_media", "animation_studio",
    "radio_station", "social_media_agency", "telecommunications_company",
    "television_service_providers", "topic_publisher",
    "media_news_company", "social_media_company", "telecommunications"
  ),
  
  automotive = c("gas_station", "auto_body_shop", "auto_customization", "auto_detailing", "auto_glass_service", "automotive", "automotive_dealer", "aircraft_dealer",
                 "automotive_parts_and_accessories", "car_window_tinting", "bicycle_shop", "tire_shop", "used_car_dealer", "parking", "department_of_motor_vehicles",
                 "automotive_repair", "automotive_services_and_repair", "automotive_wheel_polishing_service", "bike_repair_maintenance", "towing_service",
                 "boat_dealer", "boat_service_and_repair", "boat_parts_and_accessories", "car_dealer", "car_rental_agency", "car_stereo_store", "car_wash", "motorcycle_dealer",
                 "motorcycle_rentals", "motorcycle_repair", "recreational_vehicle_dealer", "trailer_dealer", "truck_dealer", "truck_repair", "commercial_vehicle_dealer",
                 "auto_restoration_services", "recreation_vehicle_repair", "automobile_leasing", "automobile_registration_service", "wheel_and_rim_repair", "emissions_inspection",
                 "rv_park", "mobile_home_park", "atv_recreation_park", # Outdoor??
                 "oil_change_station", "tire_dealer_and_repair", "trailer_rentals", "truck_rentals", "atv_rentals_and_tours", "rv_rentals", 
                 "automotive_storage_facility", "auto_parts_and_supply_store"),
  
  transport_other = c("transportation", "aircraft_repair", "airline", "airlines", "airport", "airport_lounge", "airport_shuttles", "airport_terminal", "ride_sharing",
                      "bridge", "bus_station", "ferry_boat_company", "freight_and_cargo_service", "heliports", "movers", "pier", "quay", # could be port category ??
                      "railroad_freight", "seaplane_bases", "shipping_center", "vehicle_shipping", "trains", "taxi_service", "train_station"),

  shopping_essential = c(
    "bakery", "butcher_shop", "cheese_shop", "convenience_store", 
    "farmers_market", "fruits_and_vegetables", "grocery_store",
    "health_food_store", "liquor_store", "organic_grocery_store",
    "specialty_grocery_store", "supermarket", "shopping", 
    "department_store", "discount_store", "clothing_store", "shopping_center",
    "superstore", "retail"
  ),
  
  shopping_other = c(
    "antique_store", "appliance_repair_service", "appliance_store", 
    "aquatic_pet_store", "archery_shop", "audio_visual_equipment_store",
    "avionics_shop", "bookstore", "boutique", "linen", "patio_covers",
    "bridal_shop", "candy_store", "carpet_store", "children's_clothing_store",
    "comic_books_store", "computer_store", "costume_store", "packing_supply",
    "duty_free_shop", "e_cigarette_store", "fishmonger", "beer_wine_and_spirits",
    "electronics", "eyewear_and_optician", "fabric_store", "fair",
    "fashion", "fashion_accessories_store", "firework_retailer", "flea_market", 
    "flowers_and_gifts_shop", "furniture_store", "gift_shop", "gun_and_ammo",
    "hardware_store", "hat_shop", "hobby_shop", "home_and_garden", 
    "home_goods_store", "hunting_and_fishing_supplies", "jewelry_store",
    "lighting_store", "luggage_store", "machine_shop", "mattress_store",
    "men's_clothing_store", "mobile_home_dealer", "mobile_phone_store",
    "motorsports_store", "music_and_dvd_store", "musical_instrument_store",
    "newspaper_and_magazines_store", "office_equipment", "outdoor_gear", 
    "outlet_store", "party_supply", "pawn_shop", "pet_store", "custom_clothing",
    "photography_store_and_services", "pop_up_shop", "printing_services",
    "record_label", "reptile_shop", "shoe_repair", "shoe_store",
    "skate_shop", "ski_and_snowboard_shop", "souvenir_shop", "glass_blowing", "golf_cart_dealer",
    "surf_shop", "swimwear_store", "thrift_store", "maternity_wear", "paint_store",
    "tobacco_shop", "toy_store", "trophy_shop", "uniform_store", "game_publisher",
    "video_game_store", "wig_store", "women's_clothing_store", "used_vintage_and_consignment",
    "home_improvement_store", "home_theater_systems_stores", "lottery_ticket", # could be gaming, but usually can buy other things in those shops
    # Moved from craft
    "arts_and_crafts", "chocolatier", "screen_printing_t_shirt_printing", "korean_grocery_store",
    "sewing_and_alterations", "winery", "jewelry_and_watches_manufacturer", "bedding_and_bath_stores", 
    "cards_and_stationery_store", "security_systems", "battery_store", "kitchen_supply_store"
  ),
  
  construction = c("building_supply_store", "electrical_supply_store", "tile_store", "flooring_store", "carpenter", "construction_services", "contractor", 
                   "countertop_installation", "electrician", "well_drilling", 
                   "furniture_assembly", "home_developer", "key_and_locksmith", "building_contractor",
                   "excavation_service", "fence_and_gate_sales_service", 
                   "glass_and_mirror_sales_service", "garage_door_service", "elevator_service",
                   "granite_supplier", "damage_restoration", "sandblasting_service", "powder_coating_service",
                   "gutter_service", "handyman", "landscaping", "lumber_store", "logging_services", "logging_contractor",
                   "masonry_concrete", "painting", "paving_contractor", "machine_and_tool_rentals",
                   "plumbing", "roofing", "tiling", "windows_installation"),
  
  beauty = c("barber", "beauty_and_spa", "beauty_product_supplier", "beauty_salon", "tanning_salon",
             "cosmetic_and_beauty_supplies", "cosmetic_dentist", "day_spa",
             "hair_extensions", "hair_replacement", "hair_salon", "hair_removal",
             "hair_supply_stores", "laser_hair_removal", "lingerie_store", 
             "makeup_artist", "massage", "nail_salon", "skin_care", "health_spa", 
             "spas", "tattoo_and_piercing", "teeth_whitening", "waxing", "threading_service"),
  
  wholesale = c(
    "b2b_apparel", "b2b_electronic_equipment", "b2b_jewelers",
    "b2b_science_and_technology", "b2b_textiles", "business_to_business",
    "business_to_business_services", "wholesaler",
    "meat_wholesaler", "restaurant_equipment_and_supply", "restaurant_wholesale",
    "shopping_wholesaler", "wholesale_grocer", "wholesale_grocery_store",
    "wholesale_store"
  ),
  
  financial = c(
    "accountant", "atms", "bank_credit_union", "banks", "credit_and_debt_counseling",
    "credit_union", "credit_unions", "currency_exchange", "financial_advising",
    "financial_service", "installment_loans", "insurance_agency", "life_insurance", "investing",
    "mortgage_broker", "trusts", "bank_equipment_service", "bail_bonds_service",
    "real_estate_investment", "collection_agencies"
  ),
  
  religion = c(
    "anglican_church", "baptist_church", "buddhist_temple", "cathedral",
    "catholic_church", "church", "church_cathedral", "convents_and_monasteries",
    "episcopal_church", "evangelical_church", "hindu_temple",
    "jehovahs_witness_kingdom_hall", "mosque", "pentecostal_church",
    "religious_organization", "sikh_temple", "synagogue", "astrologer"
  ),
  
  professional_services = c(
    "architectural_designer", "automation_services", "automotive_consultant",
    "brokers", "business_management_services", "engineering_services",
    "food_consultant", "geological_services", "graphic_designer",
    "image_consultant", "internet_marketing_service",
    "it_service_and_computer_repair", "laboratory_testing", "land_surveying",
    "marketing_agency", "marketing_consultant", "public_relations",
    "medical_research_and_development", "professional_services",
    "software_development", "structural_engineer",
    "translating_and_interpreting_services", "web_designer",
    "lawyer", "legal_services", "notary_public", "private_investigation", "genealogists", "general_litigation",
    "criminal_defense_law", "divorce_and_family_law", "immigration_law", "bankruptcy_law", "contract_law", "entertainment_law",
    "employment_law", "ip_and_internet_law", "personal_injury_law", "tax_law", "real_estate_law", "medical_law", "dui_law",
    "wills_trusts_and_probate" # also a law-related thing 
  ),
  
  business_services = c(
    "advertising_agency", "appraisal_services", "auction_house",
    "business", "business_advertising", "copywriting_service", 
    "employment_agencies", "escrow_services", 
    "food_beverage_service_distribution", "inventory_control_service", 
    "media_restoration_service", 
    "merchandising_service", "music_production",
    "occupational_safety",  
    "secretarial_services", "shredding_services", 
    "telemarketing_services", "vending_machine_supplier", "writing_service",
    "hotel_supply_service", "environmental_and_ecological_services_for_businesses", 
    "sign_making"
  ),
  
  home_services = c(
    "caterer", "bartender", "dry_cleaning", "carpet_cleaning", "janitorial_services", "septic_services",
    "hvac_services", "property_management", "real_estate_service",
    "food_delivery_service", "chimney_sweep", "fireplace_service", 
    "dj_service", "limo_services", "event_planning", # Business service??
    "party_and_event_planning", "event_photography", "photographer", "videographer",   
    "funeral_services_and_cemeteries", "gardener", "home_cleaning", 
    "home_security", "security_services", "home_service", "interior_design", "taxidermist",
    "nanny_services", "nursery_and_gardening", "personal_chef", "home_staging", "home_inspector",
    "pest_control_service", "pet_breeder", "pet_services", "pet_boarding", "pet_sitting", "pet_adoption",
    "pet_groomer", "pets", "pool_cleaning", "water_heater_installation_repair",
    "real_estate_agent", "tree_services", "wedding_planning", "adoption_services", 
    "animal_rescue_service", "crisis_intervention_services", "dog_trainer", "dog_walkers", "horse_trainer",
    "life_coach", "personal_assistant", "art_restoration", "family_counselor",
    "child_protection_service", "marriage_or_relationship_counselor", "sex_therapist",
    "house_sitting", "tv_mounting", "kids_recreation_and_party"
  ),
  
  residential = "real_estate",
  commercial = c("commercial_real_estate", "corporate_office"),
  historic = c("castle", "fort", "landmark_and_historical_building", "palace"),
  
  power = c(
    "electric_utility_provider", "energy_company",
    "energy_equipment_and_solution", "solar_installation"
  ),
  
  utilities_other = c( # No separate waste category
    "recycling_center", "garbage_collection_service", "public_utility_company",
    "water_supplier", "water_treatment_equipment_and_services"
  ),
  
  sport = c(
    "amateur_sports_team", "baseball_stadium", "basketball_court", "baseball_field",
    "basketball_stadium", "boxing_class", "fitness_trainer", "football_stadium", "tai_chi_studio",
    "golf_course", "gym", "boot_camp", "active_life", "gymnastics_center", "martial_arts_club",
    "pilates_studio", "professional_sports_team", "race_track", "rugby_stadium", "professional_sports_league", "amateur_sports_league",
    "school_sports_league", "school_sports_team", "skate_park", "soccer_field", "hockey_field",
    "soccer_stadium", "sporting_goods", "sports_and_fitness_instruction", "esports_team", "disc_golf_course",
    "sports_and_recreation_venue", "sports_club_and_league", "sports_stadium", "rodeo",
    "sports_wear", "squash_court", "stadium_arena", "swimming_pool", "swimming_instructor", "golf_instructor",
    "tennis_court", "tennis_stadium", "track_stadium", "yoga_studio", "ice_skating_rink",
    "shooting_range", "archery_range", 	"cricket_ground", "esports_league", "volleyball_court", "racquetball_court",
    "driving_range", "roller_skating_rink", "badminton_court", "fencing_club", "rugby_pitch", "hockey_arena", "batting_cage"
  ),
  
  museums = c(
    "aquarium", "archaeological_services", "art_museum", "asian_art_museum", 
    "aviation_museum", "cartooning_museum", "children's_museum", 
    "civilisation_museum", "civilization_museum", "community_museum",
    "computer_museum", "contemporary_art_museum", "costume_museum",
    "decorative_arts_museum", "design_museum", "history_museum", 
    "modern_art_museum", "museum", "photography_museum", 
    "science_museum", "sports_museum", "textile_museum", "monument", "art_gallery", "planetarium"
  ),
  
  parks_and_nature = c(
    "botanical_garden", "campground", "dog_park", 
    "national_park", "nature_reserve", "park", 
    "petting_zoo", "playground", "marina",
    "wildlife_sanctuary", "zoo", "water_park", # water park ??
    "natural_hot_springs"
  ),
  
  tours_and_sightseeing = c(
    "boat_tours", "bus_tours", "food_tours", "hot_air_balloons_tour", "historical_tours", "architectural_tours",
    "travel", "attractions_and_activities", "sculpture_statue",
    "sightseeing_tour_agency", "tours", "travel_company", "travel_agents", "travel_services"
  ),
  
  outdoor_activities = c(
    "canoe_and_kayak_hire_service", "diving_center", "paddleboarding_center", "fishing_club", "fishing_charter",
    "hiking_trail", "horse_riding", "horseback_riding_service", "horse_boarding",
    "kiteboarding", "mountain_bike_trails", "rock_climbing_spot", "flyboarding_center", "jet_skis_rental",
    "scuba_diving_center", "scuba_diving_instruction", "hang_gliding_center",
    "sky_diving", "snorkeling", "surfing", "ski_and_snowboard_school", "bike_rentals", "boat_rental_and_training"
  ),
  
  performing_arts = c(
    "arts_and_entertainment", "cinema", "circus", "cultural_center", "choir", "opera_and_ballet",
    "jazz_and_blues", "music_venue", "performing_arts", "theatre", "laser_tag",
    "theatrical_productions", "topic_concert_venue", "theaters_and_performance_venues", "drive_in_theater"
  ),  
  
  # Combine with drinking?
  nightlife = c("adult_entertainment", "casino", "comedy_club", "karaoke", 
                "dance_club", "lounge", "salsa_club"),
  
  # Minigolf and go-kart do not fit well...
  gaming = c("amusement_park", "arcade", "betting_center", "bingo_hall",
             "bowling_alley", "pool_billiards", "go_kart_club", "miniature_golf_course", 
             "paintball"),
  
  beaches_and_resorts = c("beach", "beach_resort", "ski_resort"),
  
  # Combine the two??
  facilities = c("auditorium", "laundromat", "fountain", "recreation", "homeless_shelter",
                 "public_toilet", "self_storage_facility", "public_plaza"),
  emergency = c("emergency_roadside_service", "emergency_room", "escape_rooms")
)

