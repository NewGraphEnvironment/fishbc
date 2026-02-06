# Validation tests for CDC data updates
# Run after cdc.R to verify data integrity
# Reference: poissonconsulting/fishbc#13

library(readr)
library(dplyr)

message("=== CDC Data Validation Tests ===\n")

cdc <- read_csv("data-raw/cdc/cdc.csv", show_col_types = FALSE)
errors <- 0

# === Test 1: Required columns exist ===
required_cols <- c(
  "Scientific Name", "English Name", "Species Code", "Element Code",
  "BC List", "COSEWIC", "SARA", "Global Status", "Prov Status",
  "Kingdom", "Phylum", "Class", "Order", "Family"
)
missing <- setdiff(required_cols, names(cdc))
if (length(missing) == 0) {
  message("✓ Test 1: Required columns exist")
} else {
  message("✗ Test 1 FAILED: Missing columns: ", paste(missing, collapse = ", "))
  errors <- errors + 1
}

# === Test 2: Species Code is unique key ===
dupes <- cdc |> count(`Species Code`) |> filter(n > 1)
if (nrow(dupes) == 0) {
  message("✓ Test 2: Species Code is unique key")
} else {
  message("✗ Test 2 FAILED: Duplicate Species Codes: ", paste(dupes$`Species Code`, collapse = ", "))
  errors <- errors + 1
}

# === Test 3: No empty Species Codes ===
na_count <- sum(is.na(cdc$`Species Code`))
if (na_count == 0) {
  message("✓ Test 3: No NA Species Codes")
} else {
  message("✗ Test 3 FAILED: ", na_count, " NA Species Codes")
  errors <- errors + 1
}

# === Test 4: Known species still present (spot check) ===
key_species <- c(
  "F-ONMY",   # Rainbow Trout
  "F-SACO",   # Bull Trout
  "F-ONTS",   # Chinook Salmon
  "F-ONNE",   # Sockeye Salmon
  "F-ONCL"    # Cutthroat Trout
)
present <- key_species %in% cdc$`Species Code`
if (all(present)) {
  message("✓ Test 4: Key species present (Rainbow, Bull, Chinook, Sockeye, Cutthroat)")
} else {
  message("✗ Test 4 FAILED: Missing species: ", paste(key_species[!present], collapse = ", "))
  errors <- errors + 1
}

# === Test 5: COSEWIC format is correct ===
cosewic_vals <- cdc$COSEWIC[!is.na(cdc$COSEWIC) & cdc$COSEWIC != ""]
valid_pattern <- "^(SC|E|T|E/T|NAR|DD|X|XT|NA|E/T/SC/DD/NAR)( \\([A-Z][a-z]{2} \\d{4}\\))?$"
invalid <- cosewic_vals[!grepl(valid_pattern, cosewic_vals)]
if (length(invalid) == 0) {
  message("✓ Test 5: COSEWIC format valid")
} else {
  message("✗ Test 5 FAILED: Invalid COSEWIC values: ", paste(head(invalid, 3), collapse = ", "))
  errors <- errors + 1
}

# === Test 6: Minimum species count ===
if (nrow(cdc) >= 500 && nrow(cdc) <= 1000) {
  message("✓ Test 6: Species count reasonable (", nrow(cdc), ")")
} else {
  message("✗ Test 6 FAILED: Unexpected species count: ", nrow(cdc))
  errors <- errors + 1
}

# === Test 7: BC List values are valid ===
valid_bc_list <- c("Red", "Blue", "Yellow", "No Status", "Exotic", "Not Reviewed", "Extinct", "Unknown", NA, "")
invalid_bc <- setdiff(unique(cdc$`BC List`), valid_bc_list)
if (length(invalid_bc) == 0) {
  message("✓ Test 7: BC List values valid")
} else {
  message("✗ Test 7 FAILED: Invalid BC List: ", paste(invalid_bc, collapse = ", "))
  errors <- errors + 1
}

# === Test 8: Bull Trout populations have distinct statuses ===
bt <- cdc |> filter(grepl("^F-SACO", `Species Code`))
if (nrow(bt) >= 2) {
  unique_statuses <- bt |> distinct(COSEWIC, `BC List`) |> nrow()
  if (unique_statuses >= 2) {
    message("✓ Test 8: Bull Trout population distinctions preserved (", nrow(bt), " populations)")
  } else {
    message("✗ Test 8 WARNING: Bull Trout populations may have uniform statuses")
  }
} else {
  message("✗ Test 8 FAILED: Missing Bull Trout populations")
  errors <- errors + 1
}

# === Summary ===
message("\n=== ", ifelse(errors == 0, "All tests passed", paste(errors, "test(s) failed")), " ===")
message("Species: ", nrow(cdc))
message("Columns: ", ncol(cdc))

if (errors > 0) quit(status = 1)
