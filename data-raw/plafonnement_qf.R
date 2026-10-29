# Plafonnement des effets du quotient familial, publié par l'IPP (Barèmes IPP)
library(readr)
library(dplyr)

parse_montant <- function(x) as.numeric(gsub("[^0-9]", "", x))

brut <- read_csv("data-raw/plafonnement_qf_ipp.csv", col_types = cols(.default = "c"))

plafonnement_qf <- brut |>
  filter(!is.na(date)) |>
  mutate(annee_revenus    = as.integer(substr(date, 7, 10)),
         annee_imposition = as.integer(raw),
         across(c(general, celib_enf, celib, reduc_postplafond,
                  reduc_postplafond_veuf, enfant_majeur_celibataire, celib_E_ou_K),
                parse_montant)) |>
  select(annee_revenus, annee_imposition, general, celib_enf, celib,
         reduc_postplafond, reduc_postplafond_veuf,
         enfant_majeur_celibataire, celib_E_ou_K, notes) |>
  arrange(annee_revenus)

# Revenus 2025 : absents des Barèmes IPP, saisis depuis l'article 197, I.2 du CGI
# (loi n° 2026-103 du 19/02/2026, LF pour 2026, art. 4)
complement <- tibble(annee_revenus = 2025L, annee_imposition = 2026L,
                     general = 1807, celib_enf = 4262, celib = 1079,
                     reduc_postplafond = 1801, reduc_postplafond_veuf = 2011)

plafonnement_qf <- plafonnement_qf |>
  select(-notes) |>
  bind_rows(complement) |>
  arrange(annee_revenus)

usethis::use_data(plafonnement_qf, overwrite = TRUE)
