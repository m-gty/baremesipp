# Nettoyage du barème de l'IR publié par l'IPP (Barèmes IPP)
library(readr)
library(dplyr)
library(tidyr)

brut <- read_delim("data-raw/bareme_ir_ipp.csv", delim = ",",
                   col_types = cols(.default = "c"))

bareme_ir <- brut |>
  filter(!is.na(date)) |>
  mutate(annee_revenus    = as.integer(substr(date, 7, 10)),
         annee_imposition = as.integer(raw)) |>
  pivot_longer(matches("^\\d+\\.(threshold|rate)$"),
               names_to = c("tranche", ".value"),
               names_pattern = "^(\\d+)\\.(threshold|rate)$") |>
  filter(!is.na(threshold), threshold != "") |>
  mutate(tranche = as.integer(tranche),
         seuil   = as.numeric(gsub("[^0-9]", "", threshold)),
         taux    = as.numeric(sub(",", ".", gsub("[^0-9,.]", "", rate))),
         taux    = if_else(grepl("%", rate), taux / 100, taux),
         monnaie = case_when(annee_revenus <= 1959 ~ "AFRF",
                             annee_revenus <= 2000 ~ "FRF",
                             TRUE ~ "EUR")) |>
  select(annee_revenus, annee_imposition, tranche, seuil, taux, monnaie) |>
  arrange(annee_revenus, tranche)

usethis::use_data(bareme_ir, overwrite = TRUE)
