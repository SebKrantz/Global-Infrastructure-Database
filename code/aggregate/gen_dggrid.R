library(dggridR)
library(collapse)
library(sf)

# Generate resolution 12 global grid
wld10kmhex <- dgconstruct(res = 12)
wld12 <- dgearthgrid(wld10kmhex)
gc()

qtable(st_is_valid(wld12))

# Remove cells above water
water <- terra::rast("/Users/sebastiankrantz/Documents/Data/Landcover/Consensus_reduced_class_12_open_water.tif")
water_perc <- exactextractr::exact_extract(water, wld12, fun = "mean")
descr(water_perc)
wld12 <- ss(wld12, is.finite(water_perc) & water_perc < 100 - 1e-5)
gc()

# Adding some variables
setrename(wld12, seqnum = cell)
settransform(wld12, area_m2 = st_area(geometry))
settransform(wld12, dgSEQNUM_to_GEO(wld10kmhex, cell))
data.table::setcolorder(wld12, c("cell", "lon_deg", "lat_deg", "area_m2"))

# Check centroids: takes too long
# with(wld12, descr(vec(st_centroid(geometry) - cbind(lon_deg, lat_deg))))

# Cell sizes
descr(wld12$area_m2)
qtable(unclass(wld12$area_m2) < 95900000)
# mapview::mapview(wld12[unclass(wld12$area_m2) < 95900000, ])

# Saving
qs::qsave(wld12, "data/dggrid/wld12.qs")
