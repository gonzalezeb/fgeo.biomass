#' Get default equations of each type.
#'
#' @param dbh_species A dataframe as those created with [add_species()].
#'
#' @family functions to manipulate equations
#'
#' @return A nested dataframe with each row containing the data of an equation
#'   type.
#' @export
#'
#' @examples
#' census <- allodb::scbi_tree1
#' species <- allodb::scbi_species
#' dbh_species <- add_species(
#'   census, species,
#'   site = "scbi"
#' )
#'
#' allo_find(dbh_species)
allo_find <- function(dbh_species) {
  .default_eqn %>%
    dplyr::filter(!is.na(.data$eqn_type)) %>%
    dplyr::group_by(.data$eqn_type) %>%
    tidyr::nest() %>%
    dplyr::mutate(
      data = purrr::map(.data$data, ~get_this_eqn(.x, dbh_species))
    )
  # %>%
  # FIXME: Moves to pick_eqn?
  #   add_eqn_type()
}

get_this_eqn <- function(.type, dbh_species) {
  dplyr::inner_join(dbh_species, .type, by = c("sp", "site")) %>%
    dplyr::filter(!is.na(.data$dbh), !is.na(.data$eqn))
}

add_eqn_type <- function(type_data) {
  types <- type_data$eqn_type
  dplyr::mutate(
    type_data,
    data = purrr::map2(
      .data$data, types,
      ~tibble::add_column(.x, eqn_type = .y)
    )
  )
}
