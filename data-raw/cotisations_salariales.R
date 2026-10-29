# Cotisations salariales d'un salarié non-cadre du secteur privé (Barèmes IPP),
# en moyennes annuelles pondérées par les mois, par tranche de salaire exprimée
# en multiples du plafond de la Sécurité sociale (PSS)
library(readr)
library(dplyr)
library(tidyr)

parse_taux <- function(x) {
  v <- as.numeric(sub(",", ".", gsub("[^0-9,.]", "", x)))
  ifelse(grepl("%", x), v / 100, v)
}

lire <- function(fichier) {
  read_csv(fichier, col_types = cols(.default = "c")) |>
    filter(!is.na(date)) |>
    mutate(debut = as.Date(date, format = "%d/%m/%Y")) |>
    arrange(debut)
}

en_annuel <- function(tab, vars, annees, avant = 0) {
  mois <- seq(as.Date(paste0(min(annees), "-01-01")),
              as.Date(paste0(max(annees), "-12-01")), by = "month")
  idx <- findInterval(mois, tab$debut)
  res <- data.frame(annee = as.integer(format(mois, "%Y")))
  for (v in vars) {
    res[[v]] <- ifelse(idx == 0, avant, tab[[v]][pmax(idx, 1)])
  }
  res |> group_by(annee) |> summarise(across(all_of(vars), \(x) mean(x, na.rm = TRUE)),
                                      .groups = "drop")
}

annees <- 1979:2025

# Lit une table et renvoie ses taux salariaux au format long.
# `colonnes` associe chaque colonne IPP à une tranche "borneinf_bornesup" (en PSS).
lire_cotisation <- function(fichier, colonnes, nom) {
  tab <- lire(fichier)
  tab <- tab[, c("debut", names(colonnes))]
  names(tab) <- c("debut", unname(colonnes))
  for (v in unname(colonnes)) tab[[v]] <- coalesce(parse_taux(tab[[v]]), 0)
  en_annuel(tab, unname(colonnes), annees) |>
    pivot_longer(-annee, names_to = "tranche", values_to = "taux") |>
    mutate(cotisation = nom)
}

cotisations_salariales <- bind_rows(
  lire_cotisation("data-raw/maladie_ipp.csv",
                  c("salarie.maladie.0-" = "0_Inf", "salarie.maladie.0-1" = "0_1",
                    "salarie.maladie.1-" = "1_Inf"), "maladie"),
  lire_cotisation("data-raw/vieillesse_ipp.csv",
                  c("salarie.vieillesse_plafonnee.0-1" = "0_1",
                    "salarie.vieillesse_deplafonnee.0-" = "0_Inf"), "vieillesse"),
  lire_cotisation("data-raw/veuvage_ipp.csv",
                  c("salaries.sous_plafond" = "0_1",
                    "salaries.sur_tout_salaire" = "0_Inf"), "veuvage"),
  lire_cotisation("data-raw/chomage_ipp.csv",
                  c("salarie.chomage.0-" = "0_Inf", "salarie.chomage.0-1" = "0_1",
                    "salarie.chomage.1-4" = "1_4"), "chomage"),
  lire_cotisation("data-raw/arrco_ipp.csv",
                  c("taux_effectifs_salaries_employeurs.salarie.noncadre.arrco.0-1" = "0_1",
                    "taux_effectifs_salaries_employeurs.salarie.noncadre.arrco.1-3" = "1_3"),
                  "arrco"),
  lire_cotisation("data-raw/asf_ipp.csv",
                  c("salarie.asf.0-1" = "0_1", "salarie.asf.1-4" = "1_4"), "asf"),
  lire_cotisation("data-raw/agff_ipp.csv",
                  c("salarie.noncadre.agff.0-1" = "0_1",
                    "salarie.noncadre.agff.1-3" = "1_3"), "agff"),
  lire_cotisation("data-raw/agirc_arrco_ipp.csv",
                  c("salarie.agirc_arrco.0-1" = "0_1",
                    "salarie.agirc_arrco.1-8" = "1_8"), "agirc_arrco"),
  lire_cotisation("data-raw/ceg_ipp.csv",
                  c("salarie.ceg.0-1" = "0_1", "salarie.ceg.1-8" = "1_8"), "ceg"),
  lire_cotisation("data-raw/cet_ipp.csv",
                  c("salarie.cet2019.0-8" = "0_8"), "cet")
) |>
  separate(tranche, into = c("borne_inf", "borne_sup"), sep = "_") |>
  mutate(borne_inf = as.numeric(borne_inf), borne_sup = as.numeric(borne_sup)) |>
  filter(taux > 0) |>
  select(annee, cotisation, borne_inf, borne_sup, taux) |>
  arrange(annee, cotisation, borne_inf)

usethis::use_data(cotisations_salariales, overwrite = TRUE)
