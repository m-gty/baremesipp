# Prime pour l'emploi (PPE), revenus 2000-2015 (Barèmes IPP)
# Paramètres de 2007 inchangés jusqu'aux revenus 2015 ; supprimée à partir de 2016.
library(readr)
library(dplyr)

parse_montant <- function(x) as.numeric(gsub("[^0-9]", "", x))
parse_taux <- function(x) {
  v <- as.numeric(sub(",", ".", gsub("[^0-9,.]", "", x)))
  ifelse(grepl("%", x), v / 100, v)
}

brut <- read_csv("data-raw/ppe_ipp.csv", col_types = cols(.default = "c")) |>
  filter(!is.na(date))
names(brut) <- sub("^(seuils_revenu_activite|seuils_rfr_eligibilite|taux|supplements)\\.",
                   "", names(brut))

ppe <- brut |>
  mutate(annee_revenus = as.integer(substr(date, 7, 10))) |>
  filter(annee_revenus >= 2000, annee_revenus <= 2016) |>
  transmute(annee_revenus,
            existe        = annee_revenus <= 2015,
            minimum       = parse_montant(minimum),
            taux_plein    = parse_montant(pour_taux_plein_cas_general),
            maximum       = parse_montant(maximum_cas_general),
            rfr_seul      = parse_montant(personne_seule),
            rfr_couple    = parse_montant(couple_marie_pacse),
            rfr_demi_part = parse_montant(increment_par_demi_part),
            taux_entree   = parse_taux(phase_in),
            taux_sortie   = parse_taux(phase_out_cas_general),
            majoration_pac = parse_montant(par_personne_charge),
            montant_minimum = parse_montant(montant_minimum)) |>
  arrange(annee_revenus)

usethis::use_data(ppe, overwrite = TRUE)
