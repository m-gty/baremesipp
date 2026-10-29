# SMIC de référence : SMIC horaire brut x 151,67 heures x 12 mois (« SMIC à
# 35 heures »), pour toutes les années. Convention retenue pour neutraliser
# les changements de durée légale du travail (40 h, 39 h, puis 35 h) et les
# garanties mensuelles de rémunération de 2000-2005, absentes des données.
# Montants dans la monnaie du package : francs jusqu'en 2000, euros ensuite.
library(readr)
library(dplyr)

# Montant avec décimales : "43,72 FRF" -> 43.72
parse_decimal <- function(x) as.numeric(sub(",", ".", gsub("[^0-9,]", "", x)))

smic_brut <- read_csv("data-raw/smic_ipp.csv", col_types = cols(.default = "c")) |>
  filter(!is.na(date)) |>
  mutate(debut = as.Date(date, format = "%d/%m/%Y"),
         en_euros = grepl("\u20ac", smic_b_horaire),        # la ligne est-elle en euros ?
         horaire = parse_decimal(smic_b_horaire)) |>
  arrange(debut)

# Valeur mois par mois, convertie dans la monnaie de l'année du mois
mois <- seq(as.Date("1979-01-01"), as.Date("2025-12-01"), by = "month")
idx <- findInterval(mois, smic_brut$debut)
annee_mois <- as.integer(format(mois, "%Y"))
horaire <- smic_brut$horaire[idx]
ligne_en_euros <- smic_brut$en_euros[idx]
horaire <- ifelse(annee_mois >= 2001 & !ligne_en_euros, horaire / 6.55957,
                  ifelse(annee_mois <= 2000 & ligne_en_euros, horaire * 6.55957, horaire))

smic <- data.frame(annee = annee_mois, horaire = horaire) |>
  group_by(annee) |>
  summarise(smic_horaire_moyen = mean(horaire),
            smic_annuel = sum(horaire * 151.67), .groups = "drop")

usethis::use_data(smic, overwrite = TRUE)
