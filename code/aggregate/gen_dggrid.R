library(dggridR)
library(sf)

# Generate resolution 12 global grid
wld12 <- dgearthgrid(dgconstruct(res = 12))
gc()

table(st_is_valid(wld12))

# Remove cells above water
water <- terra::rast("/Users/sebastiankrantz/Documents/Data/Landcover/Consensus_reduced_class_12_open_water.tif")
water_perc <- exactextractr::exact_extract(water, wld12, fun = "mean")
collapse::descr(water_perc)
wld12 <- collapse::ss(wld12, is.finite(water_perc) & water_perc < 100 - 1e-5)
gc()

qs::qsave(wld12, "data/dggrid/wld12.qs")