Plot dbh vs. biomass by species
================

``` r
# Setup
library(tidyverse)
#> -- Attaching packages ----------------------------------------- tidyverse 1.2.1 --
#> v ggplot2 3.1.0       v purrr   0.3.1  
#> v tibble  2.0.1       v dplyr   0.8.0.1
#> v tidyr   0.8.3       v stringr 1.4.0  
#> v readr   1.3.1       v forcats 0.4.0
#> -- Conflicts -------------------------------------------- tidyverse_conflicts() --
#> x dplyr::filter() masks stats::filter()
#> x dplyr::lag()    masks stats::lag()
library(fgeo.biomass)
```

-----

The goal is to plot dbh (x) versus biomass (y) by species
([issue](https://github.com/forestgeo/allodb/issues/73)).

Let’s first drop rows with missing `dbh` values as we can’t calculate
biomass for them. For now, let’s work with a sample of the entire data
for a quicker exploration. The main patterns should be the same.

``` r
census <- fgeo.biomass::scbi_tree1 %>% 
  filter(!is.na(dbh)) %>% 
  # Sample a few rows for speed
  sample_n(5000)
```

Let’s find allometric equations in allodb and calculate biomass.

``` r
species <- fgeo.biomass::scbi_species
census_species <- census %>% 
  add_species(species, site = "SCBI")
#> Adding `site`.
#> Overwriting `sp`; it now stores Latin species names.
#> Adding `rowid`.

census_equations <- allo_find(census_species)
#> Assuming `dbh` data in [mm].
#> Joining, by = c("sp", "site")
#> Converting `dbh` based on `dbh_unit`.

biomass <- allo_evaluate(census_equations)
#> Assuming `dbh` units in [cm] (to convert units see `?measurements::conv_unit()`).
#> `biomass` values are given in [kg].
#> Warning: 
#>     `biomass` may be invalid.
#>     We still don't suppor the ability to select dbh-specific equations
#>     (see https://github.com/forestgeo/fgeo.biomass/issues/9).
#> 
biomass
#> # A tibble: 5,000 x 2
#>    rowid  biomass
#>    <int>    <dbl>
#>  1     1  38.5   
#>  2     2 168.    
#>  3     3   0.213 
#>  4     4  28.8   
#>  5     5  32.3   
#>  6     6   7.68  
#>  7     7   0.238 
#>  8     8   7.78  
#>  9     9   0.0968
#> 10    10  64.1   
#> # ... with 4,990 more rows
```

Now let’s plot `dbh` vs. `biomass`.

``` r
census_equations_biomass <- census_equations %>% right_join(biomass)
#> Joining, by = "rowid"

census_equations_biomass %>% 
  ggplot(aes(dbh, biomass)) + 
  geom_point()
#> Warning: Removed 303 rows containing missing values (geom_point).
```

![](dbh-vs-biomass_files/figure-gfm/unnamed-chunk-5-1.png)<!-- -->

A few `biomass` values seem too high.

``` r
census_equations_biomass %>% 
  ggplot(aes(sp, biomass)) +
  geom_boxplot() +
  coord_flip()
#> Warning: Removed 303 rows containing non-finite values (stat_boxplot).
```

![](dbh-vs-biomass_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

The highest `biomass` values come from a few species. Are the allometric
equations for those species correct?

``` r
descending_biomass <- census_equations_biomass %>% 
  select(sp, equation_id, eqn, dbh, biomass) %>% 
  arrange(desc(biomass))

descending_biomass %>% print(n = 30)
#> # A tibble: 5,178 x 5
#>    sp                    equation_id eqn                       dbh  biomass
#>    <chr>                 <chr>       <chr>                   <dbl>    <dbl>
#>  1 nyssa sylvatica       8da09d      1.5416 * (dbh^2)^2.7818 23.5    2.98e7
#>  2 nyssa sylvatica       8da09d      1.5416 * (dbh^2)^2.7818 21.8    1.97e7
#>  3 platanus occidentalis d7f1a6      2.49193 * (dbh^2)^2.77~ 18.0    1.05e7
#>  4 nyssa sylvatica       8da09d      1.5416 * (dbh^2)^2.7818 18.3    7.32e6
#>  5 platanus occidentalis d7f1a6      2.49193 * (dbh^2)^2.77~ 16.2    5.68e6
#>  6 nyssa sylvatica       8da09d      1.5416 * (dbh^2)^2.7818 17.4    5.50e6
#>  7 nyssa sylvatica       8da09d      1.5416 * (dbh^2)^2.7818 16.4    4.08e6
#>  8 platanus occidentalis d7f1a6      2.49193 * (dbh^2)^2.77~ 12.6    1.45e6
#>  9 nyssa sylvatica       8da09d      1.5416 * (dbh^2)^2.7818 12.3    8.18e5
#> 10 nyssa sylvatica       8da09d      1.5416 * (dbh^2)^2.7818 12.0    7.09e5
#> 11 nyssa sylvatica       8da09d      1.5416 * (dbh^2)^2.7818 12.0    6.96e5
#> 12 nyssa sylvatica       8da09d      1.5416 * (dbh^2)^2.7818 11.4    5.35e5
#> 13 nyssa sylvatica       8da09d      1.5416 * (dbh^2)^2.7818 11.2    4.79e5
#> 14 nyssa sylvatica       8da09d      1.5416 * (dbh^2)^2.7818 10.8    3.99e5
#> 15 nyssa sylvatica       8da09d      1.5416 * (dbh^2)^2.7818 10.5    3.34e5
#> 16 nyssa sylvatica       8da09d      1.5416 * (dbh^2)^2.7818 10.4    3.17e5
#> 17 nyssa sylvatica       8da09d      1.5416 * (dbh^2)^2.7818 10.0    2.62e5
#> 18 nyssa sylvatica       8da09d      1.5416 * (dbh^2)^2.7818  9.53   1.96e5
#> 19 nyssa sylvatica       8da09d      1.5416 * (dbh^2)^2.7818  9.44   1.86e5
#> 20 nyssa sylvatica       8da09d      1.5416 * (dbh^2)^2.7818  8.84   1.29e5
#> 21 nyssa sylvatica       8da09d      1.5416 * (dbh^2)^2.7818  8.39   9.66e4
#> 22 nyssa sylvatica       8da09d      1.5416 * (dbh^2)^2.7818  8.29   9.03e4
#> 23 nyssa sylvatica       8da09d      1.5416 * (dbh^2)^2.7818  8.11   8.00e4
#> 24 nyssa sylvatica       8da09d      1.5416 * (dbh^2)^2.7818  8.01   7.44e4
#> 25 nyssa sylvatica       8da09d      1.5416 * (dbh^2)^2.7818  7.93   7.04e4
#> 26 nyssa sylvatica       8da09d      1.5416 * (dbh^2)^2.7818  7.83   6.57e4
#> 27 nyssa sylvatica       8da09d      1.5416 * (dbh^2)^2.7818  7.80   6.42e4
#> 28 nyssa sylvatica       8da09d      1.5416 * (dbh^2)^2.7818  7.79   6.37e4
#> 29 nyssa sylvatica       8da09d      1.5416 * (dbh^2)^2.7818  7.43   4.90e4
#> 30 nyssa sylvatica       8da09d      1.5416 * (dbh^2)^2.7818  7.33   4.54e4
#> # ... with 5,148 more rows
```

To see more detail on the lower `biomass` values, let’s remove the odd
species and plot again.

``` r
odd_species <- descending_biomass %>% 
  slice(1:30) %>% 
  pull(sp) %>% 
  unique()

census_equations_biomass %>% 
  filter(!sp %in% odd_species) %>% 
  ggplot(aes(dbh, biomass)) +
  geom_point() +
  theme(legend.position = "bottom")
#> Warning: Removed 303 rows containing missing values (geom_point).
```

![](dbh-vs-biomass_files/figure-gfm/unnamed-chunk-8-1.png)<!-- -->

This makes more sense.

Let’s use the `agb` values that come with the data as a reference. `agb`
appears to be not in \[kg\] but in \[Ton\], so we need to adjust
accordingly.

``` r
census_equations_biomass %>% 
  filter(!sp %in% odd_species) %>% 
  ggplot(aes(x = dbh)) +
  geom_point(aes(y = agb * 1e3), color = "grey") +
  geom_point(aes(y = biomass), size = 0.3) +
  ylab(" agb [Ton] in grey and biomass [kg] in black")
#> Warning: Removed 303 rows containing missing values (geom_point).

#> Warning: Removed 303 rows containing missing values (geom_point).
```

![](dbh-vs-biomass_files/figure-gfm/unnamed-chunk-9-1.png)<!-- -->

The relationship between `dbh` and `biomass` looks quite similar to that
of `dbh` and `agb`. Some difference is expected, as `agb` was apparently
calculated using allometric equations for tropical species, but SCBI is
in a temperate zone.

Here is a similar comparison, this time by species.

``` r
census_equations_biomass %>% 
  filter(!sp %in% odd_species) %>% 
  ggplot(aes(x = dbh)) +
  geom_point(aes(y = agb * 1e3), color = "grey") +
  geom_point(aes(y = biomass), size = 0.3) +
  facet_wrap("sp", ncol = 4)
#> Warning: Removed 303 rows containing missing values (geom_point).

#> Warning: Removed 303 rows containing missing values (geom_point).
```

![](dbh-vs-biomass_files/figure-gfm/unnamed-chunk-10-1.png)<!-- -->