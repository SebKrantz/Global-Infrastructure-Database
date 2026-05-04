

fetch_OCID <- function() {

  dest <- "data/opencellid/cell_towers.csv.gz"
  dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
  if (isTRUE(CUES_MODE == "never") && file.exists(dest)) return(dest)
  download.file(
    "https://opencellid.org/ocid/downloads?token=pk.00ef6e91c8e916e61168597788c6e6e8&type=full&file=cell_towers.csv.gz",
    destfile = dest, mode = "wb", method = "libcurl"
  )

  dest
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

# Open Zone Map: https://www.openzonemap.com/map
load_OZM <- function() {
  
  fread("data/OZM/Open Zone Map raw data - The Adrianople Group - 2023.csv") |> 
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
    ) %>% sf::st_drop_geometry()
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

  download.file(url, destfile = dest, mode = "wb", method = "libcurl")

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

  download.file(url, destfile = dest, mode = "wb", method = "libcurl")

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

# Oil and Gas Infrastructure Mapping (OGIM); latest from Zenodo via fetch_OGIM()
# https://doi.org/10.5281/zenodo.7466757
load_OGIM <- function() {

  path <- ogim_gpkg_path()

  all_layers <- sf::st_layers(path)$name
  layers <- all_layers[!grepl("Basins$|Fields$|Blocks|Pipelines$", all_layers)]

  res <- sapply(layers, function(x) {
    
    d <- sf::st_read(path, layer = x) |> 
      janitor::clean_names() 
    
    if(!any(names(d) %like% "latitude")) {
      d %<>% ss(st_is_valid(.) & vlengths(.$geom) >= 1L) %>% 
        st_centroid() %>% tfm(st_coordinates(.) %>% qDF() %>% set_names(c("longitude", "latitude")))
    }
    
    sf::st_drop_geometry(d) |> get_vars(varying)
    
  }, simplify = FALSE)
  
  res$Data_Catalog <- NULL
  
  res
}

# Internal World Bank Shared Data
load_ITU_nodes <- function() {
  
  geojsonsf::geojson_sf("data/ITU/ITU_Nov_2024/ITU_node_ties.geojson") %>%
    fselect(-lon_, -lat_) %>%
    tfm(st_coordinates(.) %>% qDF() %>% set_names(c("lon", "lat"))) %>% 
    sf::st_drop_geometry()
    
}


