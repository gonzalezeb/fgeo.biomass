% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/as_eqn.R
\name{as_eqn}
\alias{as_eqn}
\title{Construct S3 objects of class "eqn".}
\usage{
as_eqn(data)
}
\arguments{
\item{data}{A dataframe with the columns shown in the example.}
}
\value{
A dataframe of subclass "eqn".
}
\description{
Construct S3 objects of class "eqn".
}
\examples{
# `as_eqn()` checks that the structure of your data isn't terriby wrong
try(as_eqn("really bad data"))
try(as_eqn(data.frame(1)))

your_equations <- tibble::tibble(
  equation_id = c("000001"),
  site = c("scbi"),
  sp = c("paulownia tomentosa"),
  eqn = c("exp(-2.48 + 2.4835 * log(dbh))"),
  eqn_type = c("mixed_hardwood"),
  anatomic_relevance = c("total aboveground biomass")
)

class(as_eqn(your_equations))

census <- fgeo.biomass::scbi_tree1
species <- fgeo.biomass::scbi_species
dbh_species <- add_species(
  census, species,
  site = "scbi"
)

# Default equations
allo_find(dbh_species)

# Custom equations
allo_find(dbh_species, custom_eqn = as_eqn(your_equations))

dbh_species \%>\%
  allo_find(custom_eqn = as_eqn(your_equations)) \%>\%
  allo_order() \%>\%
  allo_evaluate()
}
