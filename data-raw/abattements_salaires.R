# Déduction pour frais professionnels (10 %) et abattement supplémentaire
# (20 %) sur les salaires, publiés par l'IPP (Barèmes IPP)
library(readr)
library(dplyr)

parse_montant <- function(x) as.numeric(gsub("[^0-9]", "", x))
parse_taux <- function(x) {
  v <- as.numeric(sub(",", ".", gsub("[^0-9,.]", "", x)))
  ifelse(grepl("%", x), v / 100, v)
}

brut <- read_csv("data-raw/salaires_ipp.csv", col_types = cols(.default = "c"))
names(brut) <- gsub(".", "_", names(brut), fixed = TRUE)   # abatpro.taux -> abatpro_taux

abattements_salaires <- brut |>
  filter(!is.na(date)) |>
  mutate(annee_revenus    = as.integer(substr(date, 7, 10)),
         annee_imposition = as.integer(raw),
         across(c(abatpro_taux, abat_supp_taux), parse_taux),
         across(c(abatpro_min, abatpro_min2, abatpro_max,
                  abat_supp_max, abat_supp_salaire_plafond), parse_montant)) |>
  select(annee_revenus, annee_imposition,
         abatpro_taux, abatpro_min, abatpro_min2, abatpro_max,
         abat_supp_taux, abat_supp_max, abat_supp_salaire_plafond, notes) |>
  arrange(annee_revenus)

# Revenus 2025 : absents des Barèmes IPP, saisis depuis l'article 83, 3° du CGI
# (version modifiée par la loi n° 2026-103 du 19/02/2026) : minimum 509 €,
# plafond 14 555 €.
complement <- tibble(annee_revenus = 2025L, annee_imposition = 2026L,
                     abatpro_taux = 0.1, abatpro_min = 509, abatpro_max = 14555)

abattements_salaires <- abattements_salaires |>
  select(-notes) |>
  distinct() |>                       # la ligne 1979 est en double dans la source
  bind_rows(complement) |>
  arrange(annee_revenus)

usethis::use_data(abattements_salaires, overwrite = TRUE)
