# Update CDCodes in freshwaterfish.csv to match current CDC Species Codes
# Reference: poissonconsulting/fishbc#13
# Updated: 2026-02-06

library(readr)
library(dplyr)

fwf <- read_csv("data-raw/freshwaterfish/freshwaterfish.csv", show_col_types = FALSE)

# CDCode mappings: old -> new (based on Feb 2026 CDC export)
fwf_updated <- fwf |>
  mutate(CDCode = case_when(
    # Taxonomic reclassifications
    CDCode == "F-CAPL" ~ "F-PABO",    # Mountain Sucker: Catostomus -> Pantosteus bondi
    CDCode == "F-ACAL" ~ "F-GIAL",    # Chiselmouth: Acrocheilus -> Gila alutacea
    CDCode == "F-NOHU" ~ "F-HUHU",    # Spottail Shiner: code change
    CDCode == "F-SPSP-01" ~ "F-SPTH-01",  # Pygmy Longfin Smelt
    CDCode == "F-MISA" ~ "F-MINI",    # Largemouth Bass: code change
    CDCode == "F-COSP-02" ~ "F-COAL-01",  # Cultus Lake Sculpin
    CDCode == "F-COSP-04" ~ "F-COSP-09",  # Rocky Mountain Sculpin
    TRUE ~ CDCode
  ))

write_csv(fwf_updated, "data-raw/freshwaterfish/freshwaterfish.csv")
message("Updated 7 CDCodes in freshwaterfish.csv")
