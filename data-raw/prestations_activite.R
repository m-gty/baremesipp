# Paramètres mensuels du RSA activité (juin 2009 - décembre 2015) et de la
# prime d'activité (depuis janvier 2016), avec le SMIC horaire brut du mois.
# Barèmes IPP.
library(readr)
library(dplyr)

parse_decimal <- function(x) as.numeric(sub(",", ".", gsub("[^0-9,]", "", x)))
parse_taux <- function(x) {
  v <- as.numeric(sub(",", ".", gsub("[^0-9,.]", "", x)))
  ifelse(grepl("%", x), v / 100, v)
}
lire <- function(f) {
  read_csv(f, col_types = cols(.default = "c")) |>
    filter(!is.na(date)) |>
    mutate(debut = as.Date(date, format = "%d/%m/%Y")) |>
    arrange(debut)
}

mois <- seq(as.Date("2009-01-01"), as.Date("2025-12-01"), by = "month")
valeur_du_mois <- function(tab, colonne) {
  idx <- findInterval(mois, tab$debut)
  ifelse(idx == 0, NA, tab[[colonne]][pmax(idx, 1)])
}

rsa <- lire("data-raw/rsa_montant_ipp.csv") |>
  mutate(rsa_mf = parse_decimal(montant_de_base_du_rsa), rsa_taux = parse_taux(pente))

pa <- lire("data-raw/pa_parametres_ipp.csv")
names(pa) <- sub("^bonification\\.", "", names(pa))
pa <- pa |>
  mutate(pa_mf          = parse_decimal(montant_de_base),
         pa_taux        = parse_taux(majoration_ressources_revenus_activite),
         # seuils exprimés en nombre d'heures de SMIC (le « € » de l'IPP est une coquille)
         pa_bonif_seuil = parse_decimal(seuil_bonification),
         pa_bonif_max   = parse_decimal(seuil_max_bonification),
         pa_bonif_taux  = parse_taux(taux_bonification_max),
         pa_min         = parse_decimal(montant_minimum_verse))

smic_brut <- lire("data-raw/smic_ipp.csv") |>
  mutate(smic_horaire = parse_decimal(smic_b_horaire))

prestations_activite <- data.frame(
  annee = as.integer(format(mois, "%Y")),
  mois  = as.integer(format(mois, "%m")),
  rsa_mf   = valeur_du_mois(rsa, "rsa_mf"),
  rsa_taux = valeur_du_mois(rsa, "rsa_taux"),
  pa_mf          = valeur_du_mois(pa, "pa_mf"),
  pa_taux        = valeur_du_mois(pa, "pa_taux"),
  pa_bonif_seuil = valeur_du_mois(pa, "pa_bonif_seuil"),
  pa_bonif_max   = valeur_du_mois(pa, "pa_bonif_max"),
  pa_bonif_taux  = valeur_du_mois(pa, "pa_bonif_taux"),
  pa_min         = valeur_du_mois(pa, "pa_min"),
  smic_horaire   = valeur_du_mois(smic_brut, "smic_horaire")
) |>
  # Pas de RSA activité hors juin 2009 - décembre 2015, pas de prime d'activité avant 2016
  mutate(across(c(rsa_mf, rsa_taux, pa_mf, pa_taux, pa_bonif_seuil, pa_bonif_max,
                  pa_bonif_taux, pa_min), \(x) coalesce(x, 0)))

usethis::use_data(prestations_activite, overwrite = TRUE)
