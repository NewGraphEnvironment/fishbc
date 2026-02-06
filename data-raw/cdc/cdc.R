# CDC data wrangling script
#
# This script converts a raw CDC Summary Data export into the curated
# `data-raw/cdc/cdc.csv` format required by fishbc.
#
# Usage:
# - Download Summary Data export from https://a100.gov.bc.ca/pub/eswp/
#   (Search: Fish, Freshwater OR Fish, Marine; Sort: Scientific Name Ascending)
# - Save as data-raw/cdc/raw.csv
# - Run this script to regenerate data-raw/cdc/cdc.csv
#
# Reference: poissonconsulting/fishbc#13

library(readr)
library(dplyr)
library(lubridate)
library(stringr)

raw_path <- "data-raw/cdc/raw.csv"
old_path <- "data-raw/cdc/cdc.csv"

if (!file.exists(raw_path)) {

stop("Missing raw CDC export: data-raw/cdc/raw.csv
Download from https://a100.gov.bc.ca/pub/eswp/")
}

message("Reading raw CDC export...")
cdc_raw <- readr::read_csv(raw_path, show_col_types = FALSE)

# Remove trailing metadata rows (CDC export includes search criteria at bottom)
# Filter out rows where Species Code is NA (these are metadata/footer rows)
cdc_raw <- cdc_raw |>
dplyr::filter(!is.na(`Species Code`))

message("Reading existing cdc.csv for column reference...")
cdc_old <- readr::read_csv(old_path, show_col_types = FALSE)

message("Transforming data...")

# === COSEWIC and SARA transformations ===
# Abbreviate status values and combine with dates

cdc_prep <- cdc_raw |>
dplyr::mutate(
  # Abbreviate COSEWIC status
  COSEWIC = case_when(
    COSEWIC == "Special Concern" ~ "SC",
    COSEWIC == "Endangered / Threatened" ~ "E/T",
    COSEWIC == "Endangered" ~ "E",
    COSEWIC == "Threatened" ~ "T",
    COSEWIC == "Not at Risk" ~ "NAR",
    COSEWIC == "Data Deficient" ~ "DD",
    COSEWIC == "Extinct" ~ "X",
    COSEWIC == "Extirpated" ~ "XT",
    COSEWIC == "Not Available" ~ "NA",
    COSEWIC == "Endangered / Threatened / Special Concern / Data Deficient / Not at Risk" ~ "E/T/SC/DD/NAR",
    TRUE ~ COSEWIC
  ),
  # Abbreviate SARA Status
  `SARA Status` = case_when(
    `SARA Status` == "Special Concern" ~ "SC",
    `SARA Status` == "Endangered / Threatened" ~ "E/T",
    `SARA Status` == "Endangered" ~ "E",
    `SARA Status` == "Threatened" ~ "T",
    `SARA Status` == "Not at Risk" ~ "NAR",
    `SARA Status` == "Data Deficient" ~ "DD",
    `SARA Status` == "Extinct" ~ "XX",
    `SARA Status` == "Extirpated" ~ "XT",
    `SARA Status` == "Not Available" ~ "NA",
    TRUE ~ `SARA Status`
  )
) |>
dplyr::mutate(
  # Format dates - handle potential NA/empty values
  `COSEWIC Date` = suppressWarnings(format(lubridate::my(`COSEWIC Date`), "%b %Y")),
  `SARA Date` = suppressWarnings(format(lubridate::my(`SARA Date`), "%b %Y")),
  # Combine COSEWIC with date
  COSEWIC = case_when(
    !is.na(`COSEWIC Date`) & `COSEWIC Date` != "NA NA" ~ paste0(COSEWIC, " (", `COSEWIC Date`, ")"),
    TRUE ~ COSEWIC
  ),
  # Build composite SARA column: Schedule-Status (Date)
  SARA = case_when(
    !is.na(`SARA Schedule`) ~ as.character(`SARA Schedule`),
    TRUE ~ NA_character_
  ),
  SARA = case_when(
    !is.na(`SARA Status`) & !is.na(SARA) ~ paste0(SARA, "-", `SARA Status`),
    !is.na(`SARA Status`) ~ `SARA Status`,
    TRUE ~ SARA
  ),
  SARA = case_when(
    !is.na(`SARA Date`) & `SARA Date` != "NA NA" & !is.na(SARA) ~ paste0(SARA, " (", `SARA Date`, ")"),
    TRUE ~ SARA
  )
)

# === Column renaming ===
# Map new CDC column names to old fishbc column names

# Column rename map: new_name -> old_name
# Only rename if target doesn't already exist
rename_map <- c(
"Ecosections" = "Ecosection",
"ENV Regional Boundaries" = "MOE Region",
"Regional Districts" = "Regional Dist",
"Municipalities" = "Municipality",
"Migratory Bird Convention Act" = "MBCA"
)
# Note: "Name Category" and "CDC Maps" already exist in new export

for (new_name in names(rename_map)) {
old_name <- rename_map[[new_name]]
# Only rename if source exists AND target doesn't already exist
if (new_name %in% names(cdc_prep) && !(old_name %in% names(cdc_prep))) {
  cdc_prep <- cdc_prep |> dplyr::rename(!!old_name := all_of(new_name))
}
}

# Handle Habitat Subtype (has newline in column name)
habitat_col <- grep("Habitats", names(cdc_prep), value = TRUE)
if (length(habitat_col) > 0) {
cdc_prep <- cdc_prep |> dplyr::rename(`Habitat Subtype` = all_of(habitat_col[1]))
}

# === Add missing columns ===
# Species Level might be missing - derive from Classification Level if needed
if (!"Species Level" %in% names(cdc_prep) && "Name Category" %in% names(cdc_prep)) {
# Attempt to derive from Name Category or set NA
cdc_prep <- cdc_prep |> dplyr::mutate(`Species Level` = NA_character_)
}

# === Column selection and ordering ===
# Keep columns from old cdc.csv in the same order

old_cols <- names(cdc_old)
available_cols <- intersect(old_cols, names(cdc_prep))
missing_cols <- setdiff(old_cols, names(cdc_prep))

if (length(missing_cols) > 0) {
message("Note: Missing columns (will be NA): ", paste(missing_cols, collapse = ", "))
for (col in missing_cols) {
  cdc_prep[[col]] <- NA_character_
}
}

# New columns to potentially add at end (per maintainer guidance)
new_cols <- setdiff(names(cdc_prep), old_cols)
# Filter to useful new columns only
keep_new_cols <- intersect(new_cols, c(
"Scientific Name - Concept Reference",
"Taxonomy Comments",
"Provincial FRPA Comments",
"COSEWIC Date",
"SARA Schedule",
"SARA Status", 
"SARA Date"
))

# Select and order columns
cdc_out <- cdc_prep |>
dplyr::select(all_of(old_cols), all_of(keep_new_cols)) |>
dplyr::arrange(`Scientific Name`)

# === Final cleanup ===
# Remove UTF-8 special characters that cause issues
if ("COSEWIC Comments" %in% names(cdc_out)) {
cdc_out$`COSEWIC Comments` <- gsub("†", "", cdc_out$`COSEWIC Comments`)
}

# === Write output ===
message("Writing updated cdc.csv...")
readr::write_csv(cdc_out, "data-raw/cdc/cdc.csv", na = "")

message("Done! cdc.csv regenerated from raw.csv")
message("Species count: ", nrow(cdc_out))
message("Column count: ", ncol(cdc_out))

# === Validation hints ===
message("\nNext steps:")
message("1. Run data-raw/data-raw.R to validate")
message("2. Check chk::chk_join passes for freshwaterfish CDCode")
message("3. Update freshwaterfish.csv if CDCodes changed")
