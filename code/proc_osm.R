
proc_osm <- function(path = "data/OSM/raw") {
  
  files <- list.files(path, pattern = "osm.pbf", full.names = TRUE)
  
  if(length(files) == 0) {
    stop("No files found in ", path)
  }
  
  for (file in files) { 
    tryCatch({
    
    message("Processing: ", file)     
    file_gpkg <- sub("osm.pbf", "gpkg", file)
    sf::gdal_utils("vectortranslate", file, file_gpkg)
    print(sf::st_layers(file_gpkg))
    
    
    ### Processing Points -----------------------------------------
    
    points <- sf::st_read(file_gpkg, layer = "points", quiet = TRUE)
    message("Points Size: ", format(object.size(points), "Mb"))

    # Removing geometry column, creating data.table
    points %<>%
      fsubset(is.na(barrier), -barrier) %>% 
      ftransform(mctl(sf::st_coordinates(geom), names = TRUE)) %>% 
      frename(X = lon, Y = lat) %>% 
      fmutate(geom = NULL) %>% qDT()
    
    gc()
    
    # Classifying
    points_classification <- osmclass::osm_classify(points, osmclass::osm_point_polygon_class)

    # Adding classification, removing unclassificed, and some final transformations
    points %<>% ss(points_classification$classified) %>%
      fmutate(description = osmclass::osm_tags_df(., "description")[[1]] %||% NA_character_) %>% 
      fselect(osm_id, ref, name, description, lon, lat) %>% 
      fmutate(osm_id = as.numeric(osm_id))
    
    add_vars(points, 5:9) <- points_classification |> fsubset(classified, -classified)
    points %<>% fsubset(is.finite(osm_id)) %>% tfmv(is_categorical, qF)
    
    # Saving
    qs::qsave(points, paste0("data/OSM/processed/", sub(".osm.pbf", "-points.qs", basename(file))))
    
    print(fnrow(points))
    message("Points Final Size: ", format(object.size(points), "Mb"))
    rm(points, points_classification); gc()
    
    ### Processing Lines -----------------------------------------
    
    lines <- sf::st_read(file_gpkg, layer = "lines", quiet = TRUE)
    message("Lines Size: ", format(object.size(lines), "Mb"))
    
    lines %<>% fsubset(is.na(highway) | highway %chin% osmclass::osm_line_class$road$highway)
      
    lines_class <- osmclass::osm_classify(lines, osmclass::osm_line_class)
    cl <- which(lines_class$classified)
    lines %<>% ss(cl, check = FALSE)
    lines_class %<>% ss(cl, check = FALSE)
      
    categories <- gsplit(g = lines_class$main_cat, use.g.names = TRUE)
    lines_list <- list()
      
    for (cat in names(categories)) {
      ind <- categories[[cat]]
      lines_cat <- ss(lines, ind, check = FALSE)
      res <- fselect(lines_cat, osm_id)
      add_vars(res, 2:5) <- ss(lines_class, ind, 3:6, check = FALSE)
      if(length(tags <- osmclass::osm_line_info_tags[[cat]])) {
        cat_tags_df <- osmclass::osm_tags_df(lines_cat, tags, na.prop = 0.001)
        if(length(cat_tags_df)) add_vars(res, 6:(fncol(cat_tags_df) + 5)) <- cat_tags_df
      }
      lines_list[[cat]] <- colorder(res, geom, pos = "end")
    }
    rm(lines, lines_class, res, ind, tags, cat_tags_df, cl, categories); gc()

    # Removing non-informative columns
    lines_list %<>% lapply(function(x) get_vars(x, fnobs(x) > 0.001 * fnrow(x)))
    lines_list |> sapply(fnrow) |> print()
    # lines_list |> lapply(function(x) fndistinct(atomic_elem(x)))
    
    # Too many streams... needs to be here!!
    lines_list$waterway %<>% fsubset(main_tag_value %!=% "stream")
    
    # # Removing main tag column in only one
    # lines_list %<>% lapply(function(x) {
    #   if(fndistinct(x$main_tag) == 1L) {
    #     main_tag = x$main_tag[1L]
    #     x$main_tag <- NULL
    #     if(anyv(names(x), main_tag)) {
    #       if(anyv(names(x), "main_tag_value")) x$main_tag_value <- NULL
    #     } else {
    #       setnames(x, "main_tag_value", main_tag)
    #     }
    #     setcolorder(x, c("osm_id", main_tag))
    #   }
    #   return(x)
    # })
    
    setv(names(lines_list), "boundary", "protected_area")
    
    # Saving
    qs::qsave(lines_list, paste0("data/OSM/processed/", sub(".osm.pbf", "-lines.qs", basename(file))))
    
    message("Lines Final Size: ", format(object.size(lines_list), "Mb"))
    rm(lines_list); gc()
    
    
    ### Processing Multipolygons -----------------------------------------
    
    layers <- sf::st_layers(file_gpkg)
    N <- layers$features[layers$name == "multipolygons"]
    int <- seq(0L, N, 1e7L)
    multipolygons <- vector("list", length(int))
    
    for (i in seq_along(int)) {
      
      cat("\nReading Multipolygons Chunk", i, "\n")
      if(length(int) > 1) {
        temp <- sf::st_read(file_gpkg, 
                        query = paste("SELECT * FROM multipolygons LIMIT 10000000 OFFSET", int[i])) 
        print(fnrow(temp))
        gc()
      } else {
        temp <- sf::st_read(file_gpkg, layer = "multipolygons", quiet = TRUE)
      }
      message("Multipolygons Size: ", format(object.size(temp), "Mb"))
    
      # Removing Administrative or natural features...
      temp %<>% 
        ftransformv(c(osm_id, osm_way_id), as.double) %>%
        fsubset(boundary %!in% c("administrative", "municipality", "political") & 
                is.na(natural) & is.na(geological) & !(is.na(osm_id) & is.na(osm_way_id)))
        
      # Classifying 
      temp_class <- osmclass::osm_classify(temp, osmclass::osm_point_polygon_class)
      cl <- which(temp_class$classified)
      # # Classification conflicts
      # temp_class |> ss(cl, check = FALSE) |> 
      #   fsubset(!is.na(alt_cats) & main_cat != alt_cats) |> fcount() |> roworder(-N) # |> View()
      temp %<>% ss(cl, check = FALSE)
      temp_class %<>% ss(cl, 2:fncol(temp_class), check = FALSE)
  
      # Other tags...
      save_tags <- .c(ref, name, description, operator, capacity, access, opening_hours, start_date)
      temp_tags <- osmclass::osm_tags_df(temp, save_tags, na.prop = 0)
      temp %<>% fselect(osm_id, osm_way_id) %>% 
        add_vars(temp_class, temp_tags)
      
      # Ensuring valid geometries
      tryCatch(temp %<>% sf::st_make_valid(), error = function(e) warning("failure to make valid"))
      tryCatch(temp %<>% ss(sf::st_is_valid(.)), error = function(e) warning("failure to sort out invalid"))
      settransform(temp, geom = sf::st_as_sfc(unclass(geom)))
      if(sf::st_crs(temp)$input != "WGS 84") sf::st_crs(temp) <- sf::st_crs(4326) # Making WGS 84
      
      # Computing area
      temp <- tryCatch(fmutate(temp, area = sf::st_area(geom)), error = function(e) warning("failed to compute area"))
      
      # Computing centroid
      temp <- tryCatch({
        
          temp |> sf::st_centroid() |>
            ftransform(mctl(sf::st_coordinates(geom), names = TRUE)) |> 
            frename(X = lon, Y = lat) |> 
            fmutate(geom = NULL) |> qDT()
        
        }, error = function(e) {
          warning("manually computing centroid")
          
          # Simple centroid function in case st_centroid fails
          simp_centroid <- function(x) {
            if(!is.list(x) || length(x) == 0L) return(if(is.numeric(x) && length(x) == 2L) x else NULL) else 
              if(all(vapply(x, is.matrix, TRUE)) && all(vapply(x, ncol, 1L) == 2L)) 
                return(pmean(lapply(x, fmean.matrix))) else simp_centroid(x[[1L]])
          }
          
          temp |> 
            fmutate(geom = lapply(geom, simp_centroid)) |> 
            fsubset(vlengths(geom) == 2L) |> 
            ftransform(setNames(transpose(geom), c("lon", "lat"))) |> 
            fmutate(geom = NULL) |> qDT()
        })
      
      multipolygons[[i]] <- tfmv(temp, is_categorical, qF)
    }
    
    rm(temp, temp_class, temp_tags); gc()
    multipolygons <- if(length(int) == 1L) multipolygons[[1]] else rowbind(multipolygons)
    
    # Saving
    qs::qsave(multipolygons, paste0("data/OSM/processed/", sub(".osm.pbf", "-multipolygons.qs", basename(file))))

    print(fnrow(multipolygons))
    message("Multipolygons Final Size: ", format(object.size(multipolygons), "Mb"))
    file.remove(file_gpkg); 
    rm(multipolygons); gc()
    

    }, error = function(e) warning("Error: ", e$message))
   
  }
  "data/OSM/processed"
}