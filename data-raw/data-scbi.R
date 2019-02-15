library(tibble)

# Source: https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/tree/master/tree_main_census/data

"data-raw/data-scbi" %>%
  fgeo.tool::rdata_list() %>%
  purrr::map(as_tibble) %>%
  list2env(.GlobalEnv)

# Rename to follow guidelines to documenting ForestGEO datasets:
# https://forestgeo.github.io/fgeo.data/articles/document_data.html
scbi_tree1 <- scbi.full1
scbi_species <- scbi.spptable

use_data(
  scbi_tree1,scbi_species,
  overwrite = TRUE
)