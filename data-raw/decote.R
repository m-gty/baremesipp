# Nettoyage de la table de la décote publiée par l'IPP (Barèmes IPP)
library(readr)
library(dplyr)

parse_montant <- function(x) as.numeric(gsub("[^0-9]", "", x))   # "1 470 €" -> 1470
parse_taux <- function(x) {
  v <- as.numeric(sub(",", ".", gsub("[^0-9,.]", "", x)))         # "45,25 %" -> 45.25
  ifelse(grepl("%", x), v / 100, v)                                # -> 0.4525
}

brut <- read_csv("data-raw/decote_ipp.csv", col_types = cols(.default = "c"))

decote <- brut |>
  filter(!is.na(date)) |>
  mutate(annee_revenus    = as.integer(substr(date, 7, 10)),
         annee_imposition = as.integer(raw),
         taux = parse_taux(taux),
         across(c(seuil, seuil_celib, seuil_couple, seuil_1_part, seuil_15_part,
                  seuil_1_faible_nombre_part, seuil_2_faible_nombre_part),
                parse_montant),
         nombre_part_limite = as.numeric(sub(",", ".", nombre_part_limite)),
         monnaie = case_when(annee_revenus <= 1959 ~ "AFRF",
                             annee_revenus <= 2000 ~ "FRF",
                             TRUE ~ "EUR")) |>
  arrange(annee_revenus)

# Revenus 2025 : absents des Barèmes IPP, saisis depuis l'article 197, I.4.a du CGI
# (loi n° 2026-103 du 19/02/2026, LF pour 2026, art. 4)
complement <- tibble(annee_revenus = 2025L, annee_imposition = 2026L,
                     taux = 0.4525, seuil_celib = 897, seuil_couple = 1483,
                     monnaie = "EUR")

# Taux de 1981-2000, absents des Barèmes IPP.
# Revenus 1981-1985 : décote = seuil - impôt, seulement à 1 ou 1,5 part
#   (article 197 du CGI, version de 1983 : 2 600 F et 800 F pour 1981).
# Revenus 1986-1999 : décote = seuil - impôt (taux 1), pour tous.
# Revenus 2000 : décote = seuil - impôt / 2 (taux 0,5), plafond de 2 450 F.
# Sources : article 197 du CGI (versions successives), BOI 5 B-9-01.
decote <- decote |>
  mutate(taux = case_when(annee_revenus >= 1981 & annee_revenus <= 1999 ~ 1,
                          annee_revenus == 2000 ~ 0.5,
                          TRUE ~ taux))

decote <- decote |>
  select(annee_revenus, annee_imposition, taux, seuil, seuil_celib, seuil_couple,
         seuil_1_part, seuil_15_part, seuil_1_faible_nombre_part,
         seuil_2_faible_nombre_part, nombre_part_limite, monnaie) |>
  bind_rows(complement) |>
  arrange(annee_revenus)

usethis::use_data(decote, overwrite = TRUE)
