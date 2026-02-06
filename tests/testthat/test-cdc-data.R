# Tests for CDC data integrity
# Run with devtools::test() or Cmd+Shift+T in RStudio

test_that("CDC data has required columns", {
  cdc <- fishbc::cdc
  required <- c("Scientific Name", "English Name", "Species Code", 
                "BC List", "COSEWIC", "SARA")
  expect_true(all(required %in% names(cdc)))
})

test_that("Species Code is unique key", {
  cdc <- fishbc::cdc
  expect_equal(anyDuplicated(cdc$`Species Code`), 0)
})

test_that("Species codes match correct species names", {
  cdc <- fishbc::cdc
  
  # Bull Trout
  bt <- cdc[cdc$`Species Code` == "F-SACO", ]
  expect_equal(nrow(bt), 1)
  expect_match(bt$`Scientific Name`, "Salvelinus confluentus")
  expect_match(bt$`English Name`, "Bull Trout")
  
  # Rainbow Trout
  rb <- cdc[cdc$`Species Code` == "F-ONMY", ]
  expect_equal(nrow(rb), 1)
  expect_match(rb$`Scientific Name`, "Oncorhynchus mykiss")
  expect_match(rb$`English Name`, "Rainbow")
  
  # White Sturgeon (not Bull Trout!)
  ws <- cdc[cdc$`Species Code` == "F-ACTR", ]
  expect_equal(nrow(ws), 1)
  expect_match(ws$`Scientific Name`, "Acipenser transmontanus")
  expect_match(ws$`English Name`, "Sturgeon")
})

test_that("Conservation statuses are plausible", {
  cdc <- fishbc::cdc
  
  # Rainbow Trout should NOT be Red-listed
  rb <- cdc[cdc$`Species Code` == "F-ONMY", ]
  expect_false(rb$`BC List` == "Red")
  
  # White Sturgeon populations should have some Red listings
  ws_pops <- cdc[grepl("^F-ACTR", cdc$`Species Code`), ]
  expect_true(any(ws_pops$`BC List` == "Red"))
  
  # Bull Trout should be Blue (Special Concern)
  bt <- cdc[cdc$`Species Code` == "F-SACO", ]
  expect_equal(bt$`BC List`, "Blue")
})

test_that("Bull Trout populations have varied COSEWIC statuses", {
  cdc <- fishbc::cdc
  bt_pops <- cdc[grepl("^F-SACO", cdc$`Species Code`), ]
  
  # Should have multiple populations

  expect_gte(nrow(bt_pops), 3)
  
  # Should have varied statuses (not all identical)
  unique_cosewic <- unique(bt_pops$COSEWIC)
  expect_gte(length(unique_cosewic), 2)
})

test_that("Taxonomic hierarchy is consistent", {
  cdc <- fishbc::cdc
  
  # All salmonids should be in Order Salmoniformes
  salmon <- cdc[cdc$Family == "Salmonidae", ]
  expect_true(all(salmon$Order == "Salmoniformes"))
  
  # All sturgeon should be Acipenseriformes
  sturgeon <- cdc[cdc$Family == "Acipenseridae", ]
  expect_true(all(sturgeon$Order == "Acipenseriformes"))
})
