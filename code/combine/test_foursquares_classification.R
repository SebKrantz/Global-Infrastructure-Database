########################################
# Test Foursquares Classification
########################################

library(collapse)
library(qs)

# Load foursquares categories
fsq_cat <- qread("data/foursquares/categories.qs")
cat("Total foursquares categories:", nrow(fsq_cat), "\n\n")

# Load the mapping
source("code/combine/overture_foursquares_to_osm_det.R")

# Apply classification in order (earlier categories take precedence)
remaining <- fsq_cat
results <- list()

for (osm_cat in names(overture_foursquares_to_osm_det)) {
  fsq <- overture_foursquares_to_osm_det[[osm_cat]]$foursquares
  if (is.null(fsq)) next

  matched <- rep(FALSE, nrow(remaining))
  for (col_name in names(fsq)) {
    matched <- matched | (remaining[[col_name]] %in% fsq[[col_name]])
  }

  if (any(matched)) {
    results[[osm_cat]] <- remaining[matched, ]
    remaining <- remaining[!matched, ]
  }
}

# Print results
cat("=== FOURSQUARES CLASSIFICATION RESULTS ===\n\n")

for (osm_cat in names(results)) {
  cats <- results[[osm_cat]]$category_name
  cat(sprintf("--- %s (%d) ---\n", toupper(osm_cat), length(cats)))
  cat(paste(cats, collapse = ", "), "\n\n")
}

# OSM categories with no foursquares mapping or zero matches
no_fsq <- setdiff(
  names(overture_foursquares_to_osm_det), names(results)
)
if (length(no_fsq) > 0) {
  has_field <- vapply(no_fsq, function(x) {
    !is.null(overture_foursquares_to_osm_det[[x]]$foursquares)
  }, logical(1L))
  cat("=== OSM CATEGORIES WITH ZERO MATCHES ===\n")
  cat("No foursquares field:",
      paste(no_fsq[!has_field], collapse = ", "), "\n")
  cat("Has field, 0 matches:",
      paste(no_fsq[has_field], collapse = ", "), "\n\n")
}

# Dead references: mapping values not found in data
cat("=== DEAD REFERENCES IN MAPPING ===\n")
for (osm_cat in names(overture_foursquares_to_osm_det)) {
  fsq <- overture_foursquares_to_osm_det[[osm_cat]]$foursquares
  if (is.null(fsq)) next
  for (col_name in names(fsq)) {
    missing <- setdiff(fsq[[col_name]], fsq_cat[[col_name]])
    if (length(missing) > 0) {
      cat(sprintf("  %s -> %s: %s\n", osm_cat, col_name,
                  paste(missing, collapse = ", ")))
    }
  }
}

# Unmatched by level1
cat(sprintf("\n=== UNMATCHED (%d categories) ===\n", nrow(remaining)))
if (nrow(remaining) > 0) {
  unmatched_by_l1 <- split(remaining$category_name, remaining$level1_category_name)
  for (l1 in names(unmatched_by_l1)) {
    cats <- unmatched_by_l1[[l1]]
    cat(sprintf("  [%s] (%d): %s\n", l1, length(cats),
                paste(cats, collapse = ", ")))
  }
}

# Summary
total_matched <- sum(vapply(results, nrow, 1L))
cat(sprintf(
  "\n=== SUMMARY ===\nMatched: %d / %d (%.1f%%)\n\
Unmatched: %d\nOSM categories used: %d / %d\n",
  total_matched, nrow(fsq_cat),
  100 * total_matched / nrow(fsq_cat),
  nrow(remaining),
  length(results), length(overture_foursquares_to_osm_det)
))
