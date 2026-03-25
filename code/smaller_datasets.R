

fetch_OCID <- function() {

  dest <- "data/opencellid/cell_towers.csv.gz"
  dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
  if (isTRUE(CUES_MODE == "never") && file.exists(dest)) return(dest)
  download.file("https://opencellid.org/ocid/downloads?token=pk.00ef6e91c8e916e61168597788c6e6e8&type=full&file=cell_towers.csv.gz",
                destfile = dest, method = "curl")

  dest
}

load_OCID <- function() {
  
  fread("data/opencellid/cell_towers.csv.gz")
  
}

load_GIP <- function() {
  
  readxl::read_xlsx("data/GEM/Global-Integrated-Power-March-2026.xlsx", sheet = 2) |> 
    janitor::clean_names()
  
}

load_GEM_cement <- function() {
  
  readxl::read_xlsx("data/GEM/Global-Cement-and-Concrete-Tracker_July-2025.xlsx",
                    sheet = "Plant Data") |>
    janitor::clean_names()
  
}

load_GEM_iron_ore <- function() {
  
  readxl::read_xlsx("data/GEM/Global-Iron-Ore-Mines-Tracker-August-2025-V1.xlsx",
                    sheet = "Main Data") |>
    janitor::clean_names() |> get_vars(varying)
  
}

load_GEM_chemicals <- function() {
  
  readxl::read_xlsx("data/GEM/Plant-level-data-Global-Chemicals-Inventory-November-2025-V1.xlsx",
                    sheet = "Plant data") |>
    janitor::clean_names() |> get_vars(varying)
  
}

load_GEM_steel <- function() {
  
  plants <- readxl::read_xlsx(
    "data/GEM/Plant-level-data-Global-Iron-and-Steel-Tracker-December-2025-V1.xlsx",
    sheet = "Plant data"
  ) |> janitor::clean_names() |> get_vars(varying)
  
  caps <- readxl::read_xlsx(
    "data/GEM/Plant-level-data-Global-Iron-and-Steel-Tracker-December-2025-V1.xlsx",
    sheet = "Plant capacities and status"
  ) |> janitor::clean_names() |> get_vars(varying)
  
  join(plants, caps, on = c("plant_id", "plant_name_english", "plant_name_other_language",
                             "country_area", "start_date"))
  
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


# Open Zone Map: https://www.openzonemap.com/map
load_OZM <- function() {
  
  fread("data/OZM/Open Zone Map raw data - The Adrianople Group - 2023.csv") |> 
    janitor::clean_names() |> 
    get_vars(varying)
  
}

# World Port Index
# https://msi.nga.mil/Publications/WPI
fetch_WPI <- function() {

  dir.create("data/WPI", recursive = TRUE, showWarnings = FALSE)
  download.file("https://msi.nga.mil/api/publications/download?type=view&key=16920959/SFH00000/UpdatedPub150.csv",
                destfile = "data/WPI/WPI.csv", method = "curl")

  "data/WPI/WPI.csv"
}

load_WPI <- function() {
  
  fread("data/WPI/WPI.csv") |> 
    janitor::clean_names() |> 
    get_vars(varying)
  
}

fetch_portswatch <- function() {

  dest <- "data/portswatch/portswatch.csv"
  dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
  if (isTRUE(CUES_MODE == "never") && file.exists(dest)) return(dest)
  imf_pw <- rowbind(
      geojsonsf::geojson_sf("https://services9.arcgis.com/weJ1QsnbMYJlCHdG/arcgis/rest/services/PortWatch_ports_database/FeatureServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=geojson&resultOffset=0"),
      geojsonsf::geojson_sf("https://services9.arcgis.com/weJ1QsnbMYJlCHdG/arcgis/rest/services/PortWatch_ports_database/FeatureServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=geojson&resultOffset=1000"),
      geojsonsf::geojson_sf("https://services9.arcgis.com/weJ1QsnbMYJlCHdG/arcgis/rest/services/PortWatch_ports_database/FeatureServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=geojson&resultOffset=2000")
    ) %>% st_drop_geometry()
    fwrite(imf_pw, dest)

  dest
}
  
load_portswatch <- function() {
  
  fread("data/portswatch/portswatch.csv") |> 
    janitor::clean_names() |> 
    get_vars(varying)
  
}


# Zenodo concept 3369106 -> latest version (gridfinder / predictive global power)
# https://zenodo.org/records/3628142
fetch_EGM_grid <- function() {

  dest <- "data/EGM/grid.gpkg"
  if (isTRUE(CUES_MODE == "never") && file.exists(dest)) return(dest)

  rec <- jsonlite::fromJSON("https://zenodo.org/api/records/3369106/versions/latest")
  row <- rec$files[rec$files$key == "grid.gpkg", , drop = FALSE]
  if (nrow(row) != 1L) {
    stop("Zenodo EGM: expected exactly one grid.gpkg in latest version, found ", nrow(row))
  }
  url <- row$links$self
  if (length(url) != 1L || !nzchar(url)) {
    stop("Zenodo EGM: missing download URL for grid.gpkg")
  }

  dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
  oldopt <- options(timeout = max(10000, getOption("timeout")))
  on.exit(options(oldopt), add = TRUE)

  download.file(url, destfile = dest, mode = "wb", method = "curl")

  dest
}

# Zenodo concept 7466757 -> latest OGIM GeoPackage
# https://doi.org/10.5281/zenodo.7466757
fetch_OGIM <- function() {

  dest <- "data/OGIM/OGIM.gpkg"
  if (isTRUE(CUES_MODE == "never") && file.exists(dest)) return(dest)

  rec <- jsonlite::fromJSON("https://zenodo.org/api/records/7466757/versions/latest")
  is_gpkg <- grepl("\\.gpkg$", rec$files$key, ignore.case = TRUE)
  row <- rec$files[is_gpkg, , drop = FALSE]
  if (nrow(row) != 1L) {
    stop("Zenodo OGIM: expected exactly one .gpkg in latest version, found ", nrow(row))
  }
  url <- row$links$self
  if (length(url) != 1L || !nzchar(url)) {
    stop("Zenodo OGIM: missing download URL for GeoPackage")
  }

  dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
  oldopt <- options(timeout = max(10000, getOption("timeout")))
  on.exit(options(oldopt), add = TRUE)

  download.file(url, destfile = dest, mode = "wb", method = "curl")

  dest
}

ogim_gpkg_path <- function() {
  preferred <- "data/OGIM/OGIM.gpkg"
  if (file.exists(preferred)) {
    return(preferred)
  }
  legacy <- list.files("data/OGIM", pattern = "^OGIM_.*\\.gpkg$", full.names = TRUE)
  if (length(legacy) == 1L) {
    return(legacy)
  }
  stop(
    "OGIM GeoPackage not found at data/OGIM/OGIM.gpkg. ",
    "Run fetch_OGIM() or tar_make(names = ogim_gpkg_file), ",
    "or place exactly one OGIM_*.gpkg in data/OGIM/."
  )
}

# https://gee-community-catalog.org/projects/tzero/
load_solar_assets <- function() {
  
  # fread("data/TZ-SAM_Solar Asset Mapper - Q1 2025/tz-sam-runs_2025-Q1_outputs_external_analysis_polygons.csv")
  fread("data/SAM/TZ-SAM_Solar Asset Mapper - Q4 2025/2025-Q4_analysis_polygons.csv")
  
}

# https://zenodo.org/records/3628142#.YGOrmWhKhPY
# https://github.com/carderne/predictive-mapping-global-power
load_global_power_map <- function() {
  
  sf::st_read("data/EGM/grid.gpkg")
  
} 

# Oil and Gas Infrastructure Mapping (OGIM); latest from Zenodo via fetch_OGIM()
# https://doi.org/10.5281/zenodo.7466757
load_OGIM <- function() {

  path <- ogim_gpkg_path()

  layers <- sf::st_layers(path) |>
        fsubset(!layer_name %like% "Basins$|Fields$|Blocks|Pipelines$")
  
  res <- sapply(layers$name, function(x) {
    
    d <- sf::st_read(path, layer = x) |> 
      janitor::clean_names() 
    
    if(!any(names(d) %like% "latitude")) {
      d %<>% ss(st_is_valid(.) & vlengths(.$geom) >= 1L) %>% 
        st_centroid() %>% tfm(st_coordinates(.) %>% qDF() %>% set_names(c("longitude", "latitude")))
    }
    
    st_drop_geometry(d) |> get_vars(varying)
    
  }, simplify = FALSE)
  
  res$Data_Catalog <- NULL
  
  res
}

# Internal World Bank Shared Data
load_ITU_nodes <- function() {
  
  geojsonsf::geojson_sf("data/ITU/ITU_Nov_2024/ITU_node_ties.geojson") %>%
    fselect(-lon_, -lat_) %>%
    tfm(st_coordinates(.) %>% qDF() %>% set_names(c("lon", "lat"))) %>% 
    st_drop_geometry()
    
}

# Vector data ---------------------------------------------------

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

  dir.create("data/OOKLA", recursive = TRUE, showWarnings = FALSE)
  fixed <- ooklaOpenDataR::get_performance_tiles(service = "fixed", year = year, quarter = quarter)
  fixed$tile <- NULL
  qs::qsave(fixed, file = "data/OOKLA/OOKLA_fixed.qs")

  mobile <- ooklaOpenDataR::get_performance_tiles(service = "mobile", year = year, quarter = quarter)
  mobile$tile <- NULL
  qs::qsave(mobile, file = "data/OOKLA/OOKLA_mobile.qs")

  c("data/OOKLA/OOKLA_fixed.qs", "data/OOKLA/OOKLA_mobile.qs")
}

load_OOKLA <- function() {
  
  list(fixed = qs::qread("data/OOKLA/OOKLA_fixed.qs"), 
       mobile = qs::qread("data/OOKLA/OOKLA_mobile.qs"))
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

