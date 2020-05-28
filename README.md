
<!-- README.md is generated from README.Rmd. Please edit that file -->

# fishbc

<!-- badges: start -->

[![Lifecycle:
maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
[![R build
status](https://github.com/poissonconsulting/fishbc/workflows/R-CMD-check/badge.svg)](https://github.com/poissonconsulting/fishbc/actions)
[![License:
CC0](https://img.shields.io/badge/License-CC0-green.svg)](https://tldrlegal.com/license/creative-commons-cc0-1.0-universal)
<!-- badges: end -->

## Introduction

`fishbc` is an R package that provides provides raw and curated data on
the codes, classification and conservation status of freshwater fishes
in British Columbia. Marine fishes will be added in a future release.

## Installation

To install the latest development version from
[GitHub](https://github.com/poissonconsulting/fishbc)

``` r
# install.packages("remotes")
remotes::install_github("poissonconsulting/fishbc")
```

## Demonstration

``` r
library(tibble) # for tidy printing
fishbc::freshwaterfish
#> # A tibble: 161 x 16
#>    Code  CommonName Class Order Family Genus Species Subspecies Species2 Extant
#>    <chr> <chr>      <chr> <chr> <chr>  <chr> <chr>   <chr>      <chr>    <lgl> 
#>  1 AF    All Fish   <NA>  <NA>  <NA>   <NA>  <NA>    <NA>       <NA>     TRUE  
#>  2 SP    Fish Unid… <NA>  <NA>  <NA>   <NA>  <NA>    <NA>       <NA>     TRUE  
#>  3 SG    Sturgeon … Acti… Acip… Acipe… Acip… <NA>    <NA>       <NA>     TRUE  
#>  4 GSG   Green Stu… Acti… Acip… Acipe… Acip… mediro… <NA>       <NA>     TRUE  
#>  5 WSG   White Stu… Acti… Acip… Acipe… Acip… transm… <NA>       <NA>     TRUE  
#>  6 SH    American … Acti… Clup… Clupe… Alosa sapidi… <NA>       <NA>     TRUE  
#>  7 SU    Sucker (G… Acti… Cypr… Catos… <NA>  <NA>    <NA>       <NA>     TRUE  
#>  8 LSU   Longnose … Acti… Cypr… Catos… Cato… catost… <NA>       <NA>     TRUE  
#>  9 BSU   Bridgelip… Acti… Cypr… Catos… Cato… columb… <NA>       <NA>     TRUE  
#> 10 WSU   White Suc… Acti… Cypr… Catos… Cato… commer… <NA>       <NA>     TRUE  
#> # … with 151 more rows, and 6 more variables: Native <lgl>, Marine <lgl>,
#> #   Yellow <lgl>, Blue <lgl>, Red <lgl>, CDCode <chr>
```

## Contribution

Please report any
[issues](https://github.com/poissonconsulting/fishbc/issues).

[Pull requests](https://github.com/poissonconsulting/fishbc/pulls) are
always welcome.

Please note that this project is released with a [Contributor Code of
Conduct](https://github.com/poissonconsulting/fishbc/blob/master/CODE_OF_CONDUCT.md).
By contributing, you agree to abide by its terms.
