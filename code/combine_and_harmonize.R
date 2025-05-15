########################################
# Combine OSM, Overture, and Foursquares
########################################

osm_data <- list(points = qread("data/osm/points.qs") |> 
                   fcount(main_cat, main_tag, main_tag_value),
                 multipolygons = qread("data/osm/multipolygons.qs") |> 
                   fcount(main_cat, main_tag, main_tag_value)) |>
              rowbind(idcol = "source") |> roworder(-N)
osm_cat <- fcount(osm_data, main_cat, w = N) |> roworder(-N)

overture_cat <- qread("data/overture/categories.qs")
fndistinct(overture_cat)
overture_cat |> fcount(V1)

foursquares_cat <- qread("data/foursquares/categories.qs")
fndistinct(foursquares_cat)
foursquares_cat |> fcount(level1_category_name)

# intersect(osm_cat$main_cat, overture_cat$V1)


# Top-level correspondence
top_level_correspondence <- list(
  accommodation = list(osm = list(main_cat = "accommodation"), 
                       overture = list(V1 = "accommodation"), 
                       foursquares = list(level2_category_name = "Lodging")),
  education = list(osm = "education", 
                   overture = "education", 
                   foursquares = list(level2_category_name = "Education")),
  health = list(osm = list(main_cat = "health"),
                overture = list(V1 = "health_and_medical"),
                foursquares = list(level1_category_name = "Health and Medicine")),
  financial = list(osm = list(main_cat = "financial"), 
                   overture = list(V1 = "financial_service"), 
                   foursquares = list(level2_category_name = "Financial Service")),
  industrial = list(osm = list(main_cat = "industrial"), 
                    overture = list(V2 = c("business_manufacturing_and_supply", "auto_company", "motorcycle_manufacturer"),# b2b_energy_and_mining? # Otherwise automotive
                                    V3 = c("industrial_company", "pharmaceutical_companies", "biotechnology_company", "b2b_rubber_and_plastics")),
                    foursquares = list(level2_category_name = c("Industrial Estate", "Manufacturer", "Chemicals and Gasses Manufacturer"))),
  automotive = list(osm = list(category = c("transport", "craft", "industrial", "shopping"),
                               craft = c("motorcycle_repair", "motocycle_repair", "garage_moto", "car_repair",
                                         "vulcanize", "vulcanizer"),
                               amenity = c("parking", "fuel", "vehicle_inspection", "parking_space", "car_wash",
                                           "car_rental", "bicycle_parking", "motorcycle_parking", "car_sharing",
                                           "charging_station", "compressed_air", "bicycle_repair_station", "boat_rental",
                                           "bicycle_rental", "parking_entrance", "boat_sharing"), 
                               industrial = "car_repair",
                               shop = c("car_repair", "car_parts", "car", "tyres", "motorcycle", "bicycle", 
                                        "fuel", "motorcycle_repair", "motorcycle_parts")), 
                    overture = list(V1 = "automotive", V2 = "auto_parts_and_supply_store"), 
                    foursquares = list(level2_category_name = c("Automotive Service", "Automotive Retail"))),
  transport_other = list(osm = list(main_cat = "transport"), 
                         overture = list(V2 = "transportation"), 
                         foursquares = list(level2_category_name = c("Transport Hub", "Transportation Service", "Boat or Ferry", "Road", 
                                                                     "Port", "Truck Stop", "Toll Booth", "Toll Plaza", "Platform", "Parking", "RV Park", 
                                                                     "Fuel Station", "Electric Vehicle Charging Station", "Bike Rental", "Boat Rental", 
                                                                     "Cruise", "Train")),
  power = list(osm = list(main_cat = "power"), 
                          overture = list(V3 = c("energy_company", "electric_utility_provider", "electricity_supplier", "energy_equipment_and_solution", "power_plants_and_power_plant_service", "wind_energy")), 
                          foursquares = list(level2_category_name = c("Power Plant", "Renewable Energy Service"))),
  utilities_other = list(osm = list(main_cat = "utilities_other"), 
                         overture = list(V2 = c("public_utility_company", "utility_service", "recycling_center")), # hazardous_waste_disposal, V4 = b2b_cleaning_and_waste_management
                         foursquares = list(level2_category_name = "Utility Company")), # Waste Management Service, Water Treatment Service
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
  = list(osm = list(main_cat = ""), 
         overture = list(V1 = ""), 
         foursquares = list(level2_category_name = ""))
)

