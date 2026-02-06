# Regression tests - validate new CDC data against archived reference
# Catches unexpected species removals or status changes

ref_path <- system.file("extdata", "cdc_2020_reference.csv", package = "fishbc")
if (ref_path == "") {
  # Fallback for dev environment
  ref_path <- "data-raw/cdc/archive/cdc_2020_reference.csv"
}

test_that("Key freshwater fish from 2020 reference still present", {
  cdc <- fishbc::cdc
  
  # Key freshwater species codes that should persist
  key_species <- c(
    "F-ONMY",  # Rainbow Trout
    "F-SACO",  # Bull Trout
    "F-ONTS",  # Chinook Salmon
    "F-ONNE",  # Sockeye Salmon
    "F-ONCL",  # Cutthroat Trout
    "F-SAFO",  # Brook Trout
    "F-SANA",  # Lake Trout
    "F-PRWI",  # Mountain Whitefish
    "F-ACTR"   # White Sturgeon
  )
  
  # All key species should be present
  missing <- setdiff(key_species, cdc$`Species Code`)
  expect_length(missing, 0)
})

test_that("BC List statuses are correct for well-known species", {
  cdc <- fishbc::cdc
  
  # Species with well-established statuses
  expect_equal(cdc$`BC List`[cdc$`Species Code` == "F-SACO"], "Blue")     # Bull Trout
  expect_equal(cdc$`BC List`[cdc$`Species Code` == "F-SAFO"], "Exotic")   # Brook Trout
  
  # Rainbow Trout should not be Red or Blue
  rb_status <- cdc$`BC List`[cdc$`Species Code` == "F-ONMY"]
  expect_true(rb_status %in% c("Yellow", "No Status", "Not Reviewed"))
})

test_that("White Sturgeon populations include Red-listed entries", {
  cdc <- fishbc::cdc
  ws_pops <- cdc[grepl("^F-ACTR", cdc$`Species Code`), ]
  
  expect_gte(nrow(ws_pops), 3)  # Should have multiple populations
  expect_true(any(ws_pops$`BC List` == "Red"))  # Some are endangered
})

test_that("Species count is reasonable vs 2020 baseline", {
  cdc <- fishbc::cdc
  
  # 2020 had 550 species, should have at least 500 now
  expect_gte(nrow(cdc), 500)
  # And not more than 700 (catch accidental duplicates)
  expect_lte(nrow(cdc), 700)
})
