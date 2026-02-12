########################################
# Test Overture Classification
########################################

library(collapse)
library(qs)

# Load overture categories
overture_cat <- qread("data/overture/categories.qs")
cat("Total overture categories:", nrow(overture_cat), "\n\n")

# Load the mapping
source("code/combine/overture_foursquares_to_osm_det.R")

# Apply classification in order (earlier categories take precedence)
remaining <- overture_cat
results <- list()

for (osm_cat in names(overture_foursquares_to_osm_det)) {
  ovr <- overture_foursquares_to_osm_det[[osm_cat]]$overture
  if (is.null(ovr)) next

  matched <- rep(FALSE, nrow(remaining))
  for (col_name in names(ovr)) {
    matched <- matched | (remaining[[col_name]] %in% ovr[[col_name]])
  }

  if (any(matched)) {
    results[[osm_cat]] <- remaining[matched, ]
    remaining <- remaining[!matched, ]
  }
}

# Print results
cat("=== OVERTURE CLASSIFICATION RESULTS ===\n\n")

for (osm_cat in names(results)) {
  cats <- results[[osm_cat]]$category
  cat(sprintf("--- %s (%d) ---\n", toupper(osm_cat), length(cats)))
  cat(paste(cats, collapse = ", "), "\n\n")
}

# OSM categories with no overture mapping or zero matches
no_overture <- setdiff(
  names(overture_foursquares_to_osm_det), names(results)
)
if (length(no_overture) > 0) {
  has_field <- vapply(no_overture, function(x) {
    !is.null(overture_foursquares_to_osm_det[[x]]$overture)
  }, logical(1L))
  cat("=== OSM CATEGORIES WITH ZERO MATCHES ===\n")
  cat("No overture field:",
      paste(no_overture[!has_field], collapse = ", "), "\n")
  cat("Has field, 0 matches:",
      paste(no_overture[has_field], collapse = ", "), "\n\n")
}

# Dead references: mapping values not found in data
cat("=== DEAD REFERENCES IN MAPPING ===\n")
for (osm_cat in names(overture_foursquares_to_osm_det)) {
  ovr <- overture_foursquares_to_osm_det[[osm_cat]]$overture
  if (is.null(ovr)) next
  for (col_name in names(ovr)) {
    missing <- setdiff(ovr[[col_name]], overture_cat[[col_name]])
    if (length(missing) > 0) {
      cat(sprintf("  %s -> %s: %s\n", osm_cat, col_name,
                  paste(missing, collapse = ", ")))
    }
  }
}

# Unmatched by V1
cat(sprintf("\n=== UNMATCHED (%d categories) ===\n", nrow(remaining)))
if (nrow(remaining) > 0) {
  unmatched_by_v1 <- split(remaining$category, remaining$V1)
  for (v1 in names(unmatched_by_v1)) {
    cats <- unmatched_by_v1[[v1]]
    cat(sprintf("  [V1=%s] (%d): %s\n", v1, length(cats),
                paste(cats, collapse = ", ")))
  }
}

# Summary
total_matched <- sum(vapply(results, nrow, 1L))
cat(sprintf(
  "\n=== SUMMARY ===\nMatched: %d / %d (%.1f%%)\n\
Unmatched: %d\nOSM categories used: %d / %d\n",
  total_matched, nrow(overture_cat),
  100 * total_matched / nrow(overture_cat),
  nrow(remaining),
  length(results), length(overture_foursquares_to_osm_det)
))
