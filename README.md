
<!-- README.md is generated from README.Rmd. Please edit that file -->

# scopusscoper

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

You may be familiar with a “telescope”; you have now in front of you a
ScopusScope, for R: meet, `scopusscoper`.

`scopusscoper` facilitates querying the Scopus API.

N.B. Keep in mind that you will need a valid Scopus subscription
(usually, through a university) and that Scopus API mostly need to be
run from a validated IP address (again, usually associated with your
university).

## What does this package aim to do?

- facilitate the systematic querying of the Scopus API, caching results
  locally
- facilitate retrieving *all* “complete”, results even from queries with
  very many results (e.g. dozens of thousands)
- facilitate extracting only the needed data in a consistent,
  `tidyverse` friendly way: API return a considerable set of
  information, in the form of nested list, and turning them into
  something easier to process can take time.

## What does this package do at this time?

At the moment, absolutely nothing.

## So what?

I’ll be porting and documenting a set of functions I’ve been using, and
explain their use in this readme.

## Installation

You can proceed to install the development version of `scopusscoper`
with:

``` r
pak::pak("giocomai/scopusscoper")
```

## Starting

\[TO DO\]
