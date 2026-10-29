# Cotisations salariales des salariés du secteur privé (Barèmes IPP), non-cadres
# et cadres, en moyennes annuelles pondérées par les mois, par tranche de
# salaire exprimée en multiples du plafond de la Sécurité sociale (PSS)
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
# `colonnes` associe chaque colonne (IPP ou préparée) à une tranche "inf_sup" en PSS.
# `preparer` permet de corriger ou combiner des colonnes avant la lecture.
lire_cotisation <- function(fichier, colonnes, nom, preparer = identity) {
  tab <- preparer(lire(fichier))
  tab <- tab[, c("debut", names(colonnes))]
  names(tab) <- c("debut", unname(colonnes))
  for (v in unname(colonnes)) tab[[v]] <- coalesce(parse_taux(tab[[v]]), 0)
  en_annuel(tab, unname(colonnes), annees) |>
    pivot_longer(-annee, names_to = "tranche", values_to = "taux") |>
    mutate(cotisation = nom)
}

# Cotisations communes aux non-cadres et aux cadres
communes <- bind_rows(
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
  lire_cotisation("data-raw/asf_ipp.csv",
                  c("salarie.asf.0-1" = "0_1", "salarie.asf.1-4" = "1_4"), "asf"),
  lire_cotisation("data-raw/agirc_arrco_ipp.csv",
                  c("salarie.agirc_arrco.0-1" = "0_1",
                    "salarie.agirc_arrco.1-8" = "1_8"), "agirc_arrco"),
  lire_cotisation("data-raw/ceg_ipp.csv",
                  c("salarie.ceg.0-1" = "0_1", "salarie.ceg.1-8" = "1_8"), "ceg"),
  lire_cotisation("data-raw/cet_ipp.csv",
                  c("salarie.cet2019.0-8" = "0_8"), "cet")
)

# Cotisations propres aux non-cadres (retraite complémentaire avant 2019)
noncadres <- bind_rows(
  lire_cotisation("data-raw/arrco_ipp.csv",
                  c("taux_effectifs_salaries_employeurs.salarie.noncadre.arrco.0-1" = "0_1",
                    "taux_effectifs_salaries_employeurs.salarie.noncadre.arrco.1-3" = "1_3"),
                  "arrco"),
  lire_cotisation("data-raw/agff_ipp.csv",
                  c("salarie.noncadre.agff.0-1" = "0_1",
                    "salarie.noncadre.agff.1-3" = "1_3"), "agff")
)

# AGFF des cadres : en 2016-2018, l'IPP range les taux dans des colonnes 0-4 et
# 4-8 ; d'après sa note (extension à la tranche C), on les lit comme 0-1 et 1-8.
preparer_agff_cadre <- function(t) {
  t |> mutate(agff_cadre_0_1 = coalesce(`salarie.cadre.agff.0-1`, `salarie.cadre.agff.0-4`),
              agff_cadre_1_8 = `salarie.cadre.agff.4-8`)
}

# Cotisations propres aux cadres (retraite complémentaire avant 2019, APEC)
# AGIRC : série des entreprises affiliées avant 1981, complète sur toute la période.
cadres <- bind_rows(
  lire_cotisation("data-raw/arrco_ipp.csv",
                  c("taux_effectifs_salaries_employeurs.salarie.cadre.arrco.0-1" = "0_1"),
                  "arrco"),
  lire_cotisation("data-raw/agirc_ipp.csv",
                  c("taux_effectifs_salaries_employeurs.avant81.salarie.agirc.1-4" = "1_4",
                    "taux_effectifs_salaries_employeurs.avant81.salarie.agirc.4-8" = "4_8"),
                  "agirc"),
  lire_cotisation("data-raw/agff_ipp.csv",
                  c("agff_cadre_0_1" = "0_1", "salarie.cadre.agff.1-4" = "1_4",
                    "agff_cadre_1_8" = "1_8"), "agff", preparer = preparer_agff_cadre),
  lire_cotisation("data-raw/apec_ipp.csv",
                  c("salarie.apec.0-1" = "0_1", "salarie.apec.1-4" = "1_4"), "apec"),
  lire_cotisation("data-raw/cet_ancienne_ipp.csv",
                  c("salarie.cet.0-8" = "0_8"), "cet_cadres")
)

cotisations_salariales <- bind_rows(
  mutate(communes, statut = "noncadre"), mutate(noncadres, statut = "noncadre"),
  mutate(communes, statut = "cadre"),    mutate(cadres, statut = "cadre")
) |>
  separate(tranche, into = c("borne_inf", "borne_sup"), sep = "_") |>
  mutate(borne_inf = as.numeric(borne_inf), borne_sup = as.numeric(borne_sup)) |>
  filter(taux > 0) |>
  select(annee, statut, cotisation, borne_inf, borne_sup, taux) |>
  arrange(annee, statut, cotisation, borne_inf)

usethis::use_data(cotisations_salariales, overwrite = TRUE)

