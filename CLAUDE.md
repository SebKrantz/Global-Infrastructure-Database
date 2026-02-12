# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Global Infrastructure Database covering all low- and middle-income countries. The project aggregates infrastructure data from multiple sources (OSM, Overture Maps, Foursquares, AllThePlaces) and combines it with specialized datasets (power grids, mining, oil/gas, cell towers, etc.).

## Running the Pipeline

This project uses the `targets` R package for workflow management:

```r
# Inspect the pipeline
library(targets)
tar_manifest()
tar_visnetwork()

# Run the full pipeline
tar_make()

# Run specific targets
tar_make(names = c("osm_ctry", "overture_places"))
```

Most targets have `cue = tar_cue(mode = "never")` to prevent automatic re-runs of expensive downloads/processing.

## Code Architecture

### Directory Structure
- `code/fetch/` - Data download functions (OSM, Overture, Foursquares, AllThePlaces)
- `code/process/` - Data processing and transformation
- `code/combine/` - Category harmonization across data sources
- `code/aggregate/` - Grid aggregation (DGGRID hexagonal cells)
- `code/smaller_datasets.R` - Functions for loading auxiliary datasets (OGIM, GMF, GRIP, WPI, OOKLA, SFI, etc.)

### Pipeline Flow (defined in `_targets.R`)
1. **Income classification**: Fetch World Bank income groups, filter to non-HIC countries
2. **OSM data**: Download from Geofabrik -> Convert PBF to GPKG -> Classify points/lines/polygons using `osmclass` package -> Combine per-country files
3. **Overture/Foursquares**: Query S3 parquet files via DuckDB, filter by country
4. **AllThePlaces**: Python scripts fetch and process business location data
5. **Category mapping**: Harmonize categories across OSM, Overture, and Foursquares (see `code/combine/osm_overture_foursquares_mapping.R`)

### Key R Packages
- `fastverse` (includes `collapse` for fast data manipulation)
- `sf`, `s2` - Spatial operations
- `osmclass` - OSM feature classification
- `duckdb` - Query remote parquet files
- `qs` - Fast serialization (`.qs` files)
- `targets` - Pipeline orchestration

### Data Storage
- Raw OSM: `data/OSM/raw/*.osm.pbf`
- Processed OSM: `data/OSM/processed/*-{points,lines,multipolygons}.qs`
- Combined OSM: `data/OSM/{points,lines,multipolygons}.qs`
- Overture/Foursquares: `data/{overture,foursquares}/{places,categories}.qs`
- Auxiliary datasets: `data/{EGM,OGIM,GMF,GRIP,OOKLA,SFI,WPI}/`

### Classification System
OSM features are classified using `osmclass::osm_point_polygon_class_det` and `osmclass::osm_line_class`. The category mapping in `code/combine/` harmonizes ~20 top-level infrastructure categories (accommodation, education, health, power, transport, etc.) across data sources.
