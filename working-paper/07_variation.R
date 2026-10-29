# Working paper : prélèvements sur les salaires, 1981-2025
# 07 - Variation du taux de prélèvement 1981-2025 par cas type (tableau 2)
#      et décomposition entre effet des réformes et effet de la croissance
#      des salaires réels (tableau 5)
devtools::load_all()
library(dplyr)
library(tidyr)

# ---------------------------------------------------------------------------
# 1. Panel des six cas types, 1981-2025
# ---------------------------------------------------------------------------
cas_types <- tibble::tribble(
  ~cas, ~k1, ~k2, ~parts, ~couple, ~cadre1, ~cadre2, ~enfants,
  "A",  1,   0,   1,      FALSE,   FALSE,   FALSE,   0,
  "B",  2,   0,   1,      FALSE,   FALSE,   FALSE,   0,
  "C",  5,   0,   1,      FALSE,   TRUE,    FALSE,   0,
  "D",  1.5, 1,   3,      TRUE,    FALSE,   FALSE,   2,
  "E",  3,   2,   3,      TRUE,    TRUE,    FALSE,   2,
  "F",  5,   3,   3,      TRUE,    TRUE,    TRUE,    2
)

panel6 <- do.call(rbind, lapply(1981:2025, function(a) {
  s <- smic$smic_annuel[smic$annee == a]
  do.call(rbind, lapply(seq_len(nrow(cas_types)), function(i) {
    ct <- cas_types[i, ]
    r <- prelevements_salaire(ct$k1 * s, annee = a, brut2 = ct$k2 * s,
                              parts = ct$parts, couple = ct$couple,
                              decote = TRUE, plafonnement = TRUE,
                              cadre = ct$cadre1, cadre2 = ct$cadre2,
                              aides = TRUE, personnes_charge = ct$enfants)
    aides <- r$ppe + r$rsa_activite + r$prime_activite
    data.frame(annee = a, cas = ct$cas,
               cotisations = 100 * r$cotisations / r$brut,
               csg_crds    = 100 * (r$csg + r$crds) / r$brut,
               ir          = 100 * r$impot / r$brut,
               aides       = 100 * aides / r$brut,
               taux_hors_aides = 100 * (r$cotisations + r$csg + r$crds + r$impot) / r$brut,
               taux_net    = 100 * r$taux_prelevements)
  }))
}))
saveRDS(panel6, "working-paper/panel_six_cas.rds")

# ---------------------------------------------------------------------------
# 2. Tableau 2 : variation 1981-2025 par prélèvement (valeurs non arrondies)
# ---------------------------------------------------------------------------
debut <- panel6 |> filter(annee == 1981)
fin   <- panel6 |> filter(annee == 2025)

tableau2 <- inner_join(debut, fin, by = "cas", suffix = c("_1981", "_2025")) |>
  transmute(cas,
            taux_1981   = taux_hors_aides_1981,
            taux_2025   = taux_hors_aides_2025,
            d_cotis     = cotisations_2025 - cotisations_1981,
            d_csg_crds  = csg_crds_2025 - csg_crds_1981,
            d_ir        = ir_2025 - ir_1981,
            d_total     = taux_hors_aides_2025 - taux_hors_aides_1981,
            aides_2025,
            taux_net_2025)
tableau2 |> mutate(across(where(is.numeric), ~ round(.x, 1))) |> as_tibble() |> print()

# Chiffres cités dans le texte
cat("\nMaximum du taux hors aides par cas type :\n")
panel6 |> group_by(cas) |> slice_max(taux_hors_aides, n = 1) |>
  transmute(annee, taux_max = round(taux_hors_aides, 1)) |> print()

cat("\nÉcart entre C (célibataire, 5 SMIC) et E (couple, 3 + 2 SMIC) :\n")
panel6 |> filter(annee %in% c(1981, 2025), cas %in% c("C", "E")) |>
  select(annee, cas, taux_hors_aides) |>
  pivot_wider(names_from = cas, values_from = taux_hors_aides) |>
  mutate(ecart = round(C - E, 1)) |> print()

# ---------------------------------------------------------------------------
# 3. Tableau 5 : effet des réformes et effet de la croissance des salaires
#    tau(L2025, W2025) - tau(L1981, W1981)
#      = [tau(L2025, W2025) - tau(L1981, W2025)]   (réformes)
#      + [tau(L1981, W2025) - tau(L1981, W1981)]   (croissance des salaires)
# ---------------------------------------------------------------------------
s1981 <- smic$smic_annuel[smic$annee == 1981]
s2025 <- smic$smic_annuel[smic$annee == 2025]

parts_taux <- function(r) {
  c(ir = 100 * r$impot / r$brut,
    total = 100 * (r$cotisations + r$csg + r$crds + r$impot) / r$brut)
}

tableau5 <- do.call(rbind, lapply(c(A = 1, B = 2, C = 5), function(k) {
  cadre <- k == 5
  # Règles de 1981, salaire de 1981 (deux SMIC de 1981)
  l81_w81 <- parts_taux(prelevements_salaire(k * s1981, annee = 1981, decote = TRUE,
                                             plafonnement = TRUE, cadre = cadre))
  # Règles de 1981, salaire réel de 2025 (converti en francs de 1981)
  l81_w25 <- parts_taux(prelevements_salaire_constant(k * s2025, annee = 1981, decote = TRUE,
                                                      plafonnement = TRUE, cadre = cadre))
  # Règles de 2025, salaire de 2025
  l25_w25 <- parts_taux(prelevements_salaire(k * s2025, annee = 2025, decote = TRUE,
                                             plafonnement = TRUE, cadre = cadre))
  data.frame(cas = paste0(k, " SMIC"),
             prelevement = c("Impôt sur le revenu", "Ensemble"),
             regles1981_salaire1981 = l81_w81,
             regles1981_salaire2025 = l81_w25,
             regles2025_salaire2025 = l25_w25,
             variation  = l25_w25 - l81_w81,
             reformes   = l25_w25 - l81_w25,
             croissance = l81_w25 - l81_w81)
}))
rownames(tableau5) <- NULL
tableau5 |> mutate(across(where(is.numeric), ~ round(.x, 1))) |> as_tibble() |> print()

cat("\nSalaire de deux SMIC de 1981, en euros de 2025 :",
    round(en_euros_constants(2 * s1981, 1981)), "\n")
cat("Hausse du pouvoir d'achat du SMIC 1981-2025 (%) :",
    round(100 * (s2025 / en_euros_constants(s1981, 1981) - 1)), "\n")
