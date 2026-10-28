# Nettoyage du barème de l'IR publié par l'IPP (Barèmes IPP)
library(readr)
library(dplyr)
library(tidyr)

# 1. Lire le fichier en texte brut (on convertit nous-mêmes ensuite)
brut <- read_delim("data-raw/bareme_ir_ipp.csv", delim = ",",
                   col_types = cols(.default = "c"))

bareme_ir <- brut |>
  filter(!is.na(date)) |>
  # 2. Année des revenus et année d'imposition
  mutate(annee_revenus    = as.integer(substr(date, 7, 10)),
         annee_imposition = as.integer(raw)) |>
  # 3. Passer du format large (0.threshold, 1.threshold...) au format long
  pivot_longer(matches("^\\d+\\.(threshold|rate)$"),
               names_to = c("tranche", ".value"),
               names_pattern = "^(\\d+)\\.(threshold|rate)$") |>
  filter(!is.na(threshold), threshold != "") |>
  # 4. Convertir texte -> nombres
  mutate(tranche = as.integer(tranche),
         seuil   = as.numeric(gsub("[^0-9]", "", threshold)),  # "11 294 €" -> 11294
         taux    = as.numeric(sub(",", ".", gsub("[^0-9,.]", "", rate))),
         taux    = if_else(grepl("%", rate), taux / 100, taux),
         # 5. Monnaie selon l'année des revenus
         monnaie = case_when(annee_revenus <= 1959 ~ "AFRF",
                             annee_revenus <= 2000 ~ "FRF",
                             TRUE ~ "EUR")) |>
  select(annee_revenus, annee_imposition, tranche, seuil, taux, monnaie) |>
  arrange(annee_revenus, tranche)

# 6. Enregistrer comme donnée du package
usethis::use_data(bareme_ir, overwrite = TRUE)
