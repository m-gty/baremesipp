# CSG sur les revenus d'activité, CRDS et plafond de la Sécurité sociale
# (Barèmes IPP), convertis en moyennes annuelles pondérées par les mois
library(readr)
library(dplyr)

parse_montant <- function(x) as.numeric(gsub("[^0-9]", "", x))
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

# Moyenne annuelle d'une table de paramètres datés, pondérée par les mois.
# Avant la première date, la valeur vaut `avant` (0 pour un taux inexistant,
# NA pour un paramètre qui n'a de sens que lorsque le prélèvement existe).
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

# CSG
csg <- lire("data-raw/csg_ipp.csv")

# L'abattement de 5 % de 1991-1997 est affiché sur la page web de l'IPP mais
# absent de l'export CSV. Source : instruction n° 91-52-M9 du 17 avril 1991
# (assiette = salaire brut après abattement forfaitaire de 5 %).
csg <- csg |>
  mutate(`abattement.0-` = ifelse(debut < as.Date("1998-01-01") & is.na(`abattement.0-`),
                                  "5 %", `abattement.0-`))

csg <- csg |>
  mutate(csg_taux = parse_taux(taux_global),
         csg_deductible = coalesce(parse_taux(deductible), 0),
         csg_abattement = coalesce(parse_taux(`abattement.0-`),
                                   parse_taux(`abattement.0-4`), 0),
         csg_abattement_plafonne = as.numeric(!is.na(parse_taux(`abattement.0-4`))))

# Taux : 0 avant la création de la CSG. Abattement : moyenne sur les seuls
# mois où la CSG existe, puis 0 pour les années sans CSG.
csg_an <- en_annuel(csg, c("csg_taux", "csg_deductible"), annees) |>
  left_join(en_annuel(csg, c("csg_abattement", "csg_abattement_plafonne"),
                      annees, avant = NA), by = "annee") |>
  mutate(across(c(csg_abattement, csg_abattement_plafonne), \(x) ifelse(is.nan(x), 0, x)))

# CRDS (même assiette que la CSG)
crds <- lire("data-raw/crds_ipp.csv")
names(crds)[2] <- "crds_taux"
crds <- crds |> mutate(crds_taux = parse_taux(crds_taux))
crds_an <- en_annuel(crds, "crds_taux", annees)

# Plafond de la Sécurité sociale (montant annuel, dans la monnaie de l'époque).
# Les revenus 2001 étant exprimés en euros dans le package, on convertit 2001.
pss <- lire("data-raw/pss_ipp.csv") |>
  mutate(pss = parse_montant(plafond_securite_sociale_annuel))
pss_an <- en_annuel(pss, "pss", annees, avant = NA)
pss_an <- pss_an |> mutate(pss = ifelse(annee == 2001, pss / 6.55957, pss))

prelevements_sociaux <- csg_an |>
  left_join(crds_an, by = "annee") |>
  left_join(pss_an, by = "annee")

usethis::use_data(prelevements_sociaux, overwrite = TRUE)
