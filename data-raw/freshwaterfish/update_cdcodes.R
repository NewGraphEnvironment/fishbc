# Update CDCodes in freshwaterfish.csv to match new CDC Species Codes
# Reference: poissonconsulting/fishbc#13

library(readr)
library(dplyr)

fwf <- read_csv("data-raw/freshwaterfish/freshwaterfish.csv", show_col_types = FALSE)

# CDCode mappings from old to new (per CDC updates)
# - Catostomus platyrhynchus -> Catostomus bondi
# - Cultus Lake Sculpin -> Cottus aleuticus pop. 1  
# - Rocky Mountain Sculpin -> Cottus sp. 9

fwf_updated <- fwf |>
  mutate(CDCode = case_when(
    CDCode == "F-CAPL" ~ "F-CABO",
    CDCode == "F-COSP-02" ~ "F-COAL-01",
    CDCode == "F-COSP-04" ~ "F-COSP-09",
    TRUE ~ CDCode
  ))

write_csv(fwf_updated, "data-raw/freshwaterfish/freshwaterfish.csv")
message("Updated CDCodes in freshwaterfish.csv")
