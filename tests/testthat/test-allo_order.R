context("allo_order")

library(dplyr)

toy_equations <- tibble::tribble(
  ~eqn,       ~dbh,  ~eqn_type, ~rowid, ~where,
  "dbh + 1",    10,  "species",      1, "rowid only in species",
  "dbh + 1",    10,  "species",      3, "rowid in both: lhs overwrites rhs",

  "dbh + 2",    10,  "genus",        2, "rowid only in genus",
  "dbh + 2",    10,  "genus",        3, "rowid in both: lhs overwrites rhs",
)

toy_nested <- tidyr::nest(toy_equations, -eqn_type)

test_that("is sensitive to `order`", {
  species_genus <- allo_order(toy_nested, order = c("species", "genus"))
  expect_equal(nrow(species_genus), 3)
  n_type <- dplyr::count(species_genus, eqn_type)
  expect_equal(filter(n_type, eqn_type == "species")$n, 2)
  expect_equal(filter(n_type, eqn_type == "genus")$n, 1)

  genus_species <- allo_order(toy_nested, order = c("genus", "species"))
  expect_equal(nrow(genus_species), 3)
  n_type <- dplyr::count(genus_species, eqn_type)
  expect_equal(filter(n_type, eqn_type == "genus")$n, 2)
  expect_equal(filter(n_type, eqn_type == "species")$n, 1)

  expect_false(identical(species_genus, genus_species))
})

test_that("returns the expected data structure", {
  out <- allo_order(toy_nested)
  nms <- c("eqn_type", "eqn", "dbh", "rowid", "where")
  expect_named(out, nms)

  # With real data
  eqn <- fgeo.biomass::scbi_tree1 %>%
    add_species(fgeo.biomass::scbi_species, "scbi") %>%
    allo_find()
  best <- allo_order(eqn)
  nms <- c(
      "eqn_type",
      "rowid",
      "site",
      "sp",
      "dbh",
      "equation_id",
      "eqn",
      "eqn_source",
      "anatomic_relevance"
    )
  expect_named(best, nms, ignore.order = TRUE)
})

test_that("errs with informative message", {
  expect_error(allo_order(1), "must be a dataframe")
  expect_error(allo_order(data.frame(1)), "Ensure your data")
})

