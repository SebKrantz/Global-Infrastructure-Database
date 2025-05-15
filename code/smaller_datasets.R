

fetch_OCID <- function() {
  
  download.file("https://opencellid.org/ocid/downloads?token=pk.00ef6e91c8e916e61168597788c6e6e8&type=full&file=cell_towers.csv.gz", 
                destfile = "data/opencellid/cell_towers.csv.gz", method = "curl")
  
}

load_OCID <- function() {
  
  fread("data/opencellid/cell_towers.csv.gz")
  
}

load_GIP <- function() {
  
  readxl::read_xlsx("data/GIP/Global-Integrated-Power-March-2025.xlsx", sheet = 2) |> 
    janitor::clean_names()
  
}

# https://gee-community-catalog.org/projects/tzero/
load_solar_assets <- function() {
  
  fread("data/TZ-SAM_Solar Asset Mapper - Q1 2025/tz-sam-runs_2025-Q1_outputs_external_analysis_polygons.csv")
  
}

# https://zenodo.org/records/3628142#.YGOrmWhKhPY
# https://github.com/carderne/predictive-mapping-global-power
load_global_power_map <- function() {
  
  sf::st_read("data/EGM/grid.gpkg")
  
} 

# Oil and Gas Infrastructure Mapping (OGIM) Database (v2.7)
# https://doi.org/10.5281/zenodo.7466757
load_OGIM <- function() {
  
  layers <- sf::st_layers("data/OGIM/OGIM_v2.7.gpkg")
  
  sapply(layers$name, function(x) {
    
    sf::st_read("data/OGIM/OGIM_v2.7.gpkg", layer = x)    
    
  }, simplify = FALSE)
  
}

# Global mining footprint mapped from high-resolution satellite imagery 
# https://zenodo.org/records/7894216 (data/GMF)
load_GMF <- function() {
  
  sf::st_read("data/GMF")
  
}

# Global Roads Inventory Project
# https://www.globio.info/download-grip-dataset
# See also raster data available...
load_GRIP <- function() {
  
  sf::st_read("data/GRIP/GRIP4_global_vector_fgdb/GRIP4_GlobalRoads.gdb")
  
}

# OOKLA Internet Speeds
# https://github.com/teamookla/ookla-open-data
# https://www.speedtest.net/insights/blog/best-ookla-open-data-projects-2021/
# R package: remotes::install_github("teamookla/ooklaOpenDataR")
fetch_OOKLA <- function() {
  
  year <- zoo::as.yearqtr(Sys.Date()) - 0.25 
  quarter <- as.integer(substr(year, 7, 7))
  year <- as.integer(substr(year, 1, 4))
  
  fixed <- ooklaOpenDataR::get_performance_tiles(service = "fixed", year = year, quarter = quarter)
  fixed$tile <- NULL
  qs::qsave(fixed, file = "data/OOKLA/OOKLA_fixed.qs")
  
  mobile <- ooklaOpenDataR::get_performance_tiles(service = "mobile", year = year, quarter = quarter)
  mobile$tile <- NULL
  qs::qsave(mobile, file = "data/OOKLA/OOKLA_mobile.qs")
  
}

load_OOKLA <- function() {
  
  list(fixed = qs::qread("data/OOKLA/OOKLA_fixed.qs"), 
       mobile = qs::qread("data/OOKLA/OOKLA_mobile.qs"))
}


# Spatial Finance Initiative (Global Data on Certain Productive Assets)
# https://www.cgfi.ac.uk/spatial-finance-initiative/geoasset-project/geoasset-databases/
load_SFI <- function() {
  
  list(
    cement = readxl::read_xlsx("data/SFI/SFI-Global-Cement-Database-July-2021.xlsx", 
                               sheet = "SFI_ALD_Cement_Database"),
    paper_pulp = readxl::read_xlsx("data/SFI/SFI_ALD_Pulp_Paper_Database_October_2024.xlsx", 
                                   sheet = "SFI_Pulp_Paper_Database"),
    steel = readxl::read_xlsx("data/SFI/SFI-Global-Steel-Database-July-2021.xlsx", 
                              sheet = "SFI_ALD_Steel_Database"),
    ethylene = readxl::read_xlsx("data/SFI/SFI_ALD_Global_Ethylene_Database_October_2024.xlsx", 
                                 sheet = "Global_Ethylene_Production"),
    beef = readxl::read_xlsx("data/SFI/SFI_ALD_Beef_Abattoirs_Top5_Dec_2022.xlsx", 
                             sheet = "SFI_ALD_Beef_Abattoir_Top5")
  ) |> 
    lapply(function(x) get_vars(x, varying(x)) |> frename(tolower))
  
}
 

# https://gee-community-catalog.org/projects/energy_farms/
# -> Based on OSM data, not updated...
load_global_solar <- function() {
  
  fread("data/global_wind_solar_2020/global_solar_2020_WGS84.csv") |> 
    janitor::clean_names()
  
}
load_global_wind <- function() {
  
  fread("data/global_wind_solar_2020/global_wind_2020_WGS84.csv") |> 
    janitor::clean_names()
  
}

