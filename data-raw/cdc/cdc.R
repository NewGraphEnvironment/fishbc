# CDC data wrangling script
#
# Converts CDC Summary Data export to fishbc cdc.csv format.
#
# Usage:
# 1. Export Summary Data from https://a100.gov.bc.ca/pub/eswp/
#    (Groups: Fish, Freshwater + Fish, Marine)
# 2. Save as data-raw/cdc/summaryExport.xls
# 3. Run this script
#
# Reference: poissonconsulting/fishbc#13

library(rvest)
library(readr)
library(dplyr)
library(lubridate)

# === Convert XLS (HTML) to CSV ===
message("Converting summaryExport.xls to CSV...")
html <- read_html("data-raw/cdc/summaryExport.xls")
tables <- html_table(html, fill = TRUE)
cdc_raw <- tables[[1]]

# Remove trailing metadata rows (search criteria)
cdc_raw <- cdc_raw |> filter(!is.na(`Species Code`))

message("Raw data: ", nrow(cdc_raw), " species, ", ncol(cdc_raw), " columns")

# Save intermediate CSV
write_csv(cdc_raw, "data-raw/cdc/cdc_summary_export.csv")

# === Load reference (old cdc.csv) ===
cdc_old <- read_csv("data-raw/cdc/cdc.csv", show_col_types = FALSE)

# === Transform COSEWIC and SARA ===
message("Transforming COSEWIC/SARA columns...")

cdc_prep <- cdc_raw |>
  mutate(
    COSEWIC = case_when(
      COSEWIC == "Special Concern" ~ "SC",
      COSEWIC == "Endangered / Threatened" ~ "E/T",
      COSEWIC == "Endangered" ~ "E",
      COSEWIC == "Threatened" ~ "T",
      COSEWIC == "Not at Risk" ~ "NAR",
      COSEWIC == "Data Deficient" ~ "DD",
      COSEWIC == "Extinct" ~ "X",
      COSEWIC == "Extirpated" ~ "XT",
      TRUE ~ COSEWIC
    ),
    `SARA Status` = case_when(
      `SARA Status` == "Special Concern" ~ "SC",
      `SARA Status` == "Endangered / Threatened" ~ "E/T",
      `SARA Status` == "Endangered" ~ "E",
      `SARA Status` == "Threatened" ~ "T",
      `SARA Status` == "Not at Risk" ~ "NAR",
      `SARA Status` == "Data Deficient" ~ "DD",
      `SARA Status` == "Extirpated" ~ "XT",
      TRUE ~ `SARA Status`
    )
  ) |>
  mutate(
    `COSEWIC Date` = suppressWarnings(format(my(`COSEWIC Date`), "%b %Y")),
    `SARA Date` = suppressWarnings(format(my(`SARA Date`), "%b %Y")),
    COSEWIC = case_when(
      !is.na(`COSEWIC Date`) & `COSEWIC Date` != "NA NA" ~ paste0(COSEWIC, " (", `COSEWIC Date`, ")"),
      TRUE ~ COSEWIC
    ),
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

# === Rename columns to match old format ===
message("Renaming columns...")

rename_map <- c(
  "Ecosections" = "Ecosection",
  "ENV Regional Boundaries" = "MOE Region",
  "Regional Districts" = "Regional Dist",
  "Municipalities" = "Municipality",
  "Migratory Bird Convention Act" = "MBCA"
)

for (new_name in names(rename_map)) {
  old_name <- rename_map[[new_name]]
  if (new_name %in% names(cdc_prep) && !(old_name %in% names(cdc_prep))) {
    cdc_prep <- cdc_prep |> rename(!!old_name := all_of(new_name))
  }
}

# Handle Habitat Subtype column name
habitat_col <- grep("Habitats", names(cdc_prep), value = TRUE)
if (length(habitat_col) > 0 && !("Habitat Subtype" %in% names(cdc_prep))) {
  cdc_prep <- cdc_prep |> rename(`Habitat Subtype` = all_of(habitat_col[1]))
}

# === Select and order columns ===
old_cols <- names(cdc_old)
available_cols <- intersect(old_cols, names(cdc_prep))
missing_cols <- setdiff(old_cols, names(cdc_prep))

if (length(missing_cols) > 0) {
  message("Note: Missing columns (will be NA): ", paste(missing_cols, collapse = ", "))
  for (col in missing_cols) {
    cdc_prep[[col]] <- NA_character_
  }
}

cdc_out <- cdc_prep |>
  select(all_of(old_cols)) |>
  arrange(`Scientific Name`)

# === Cleanup ===
if ("COSEWIC Comments" %in% names(cdc_out)) {
  cdc_out$`COSEWIC Comments` <- gsub("†", "", cdc_out$`COSEWIC Comments`)
}

# === Write output ===
message("Writing cdc.csv...")
write_csv(cdc_out, "data-raw/cdc/cdc.csv", na = "")

message("Done! ", nrow(cdc_out), " species, ", ncol(cdc_out), " columns")
message("\nNext: Run data-raw/data-raw.R to validate and rebuild .rda files")
