# Working paper : prélèvements sur les salaires, 1981-2025
# 08 - Simulation de deux propositions de La France insoumise sur les cas types,
#      revenus 2025 (tableau 6) :
#      (1) barème de l'impôt sur le revenu à 14 tranches (amendement n° CF767
#          au projet de loi de finances pour 2026) ;
#      (2) CSG progressive, barème illustratif à 5 tranches (simulateur de la
#          campagne présidentielle de 2022, repris par l'Institut Montaigne).
#      Le quotient familial, son plafonnement, la décote, la CRDS et les
#      cotisations restent ceux de la législation 2025.
devtools::load_all()
library(dplyr)

annee <- 2025

# ---------------------------------------------------------------------------
# Barèmes des réformes
# ---------------------------------------------------------------------------
# Barème de l'impôt sur le revenu par part (seuils en euros, taux marginaux)
bareme_lfi <- data.frame(
  seuil = c(0, 10434, 15639, 20856, 28152, 32290, 35415, 38836, 44849,
            62579, 104291, 146015, 261173, 400000),
  taux  = c(0, 0.05, 0.10, 0.15, 0.20, 0.25, 0.275, 0.325, 0.40,
            0.45, 0.50, 0.55, 0.65, 0.70)
)

# Barème de CSG progressive : taux marginaux par tranche de salaire brut annuel
csg_lfi <- data.frame(
  borne_inf = c(0, 20400, 28262, 47097, 156985),
  borne_sup = c(20400, 28262, 47097, 156985, Inf),
  taux      = c(0.0077, 0.0153, 0.0229, 0.0612, 0.092)
)

# ---------------------------------------------------------------------------
# Fonctions de calcul
# ---------------------------------------------------------------------------
# Impôt issu d'un barème pour un revenu par part q
impot_une_part <- function(q, bareme) {
  bornes_sup <- c(bareme$seuil[-1], Inf)
  sum(bareme$taux * pmax(0, pmin(q, bornes_sup) - bareme$seuil))
}

# Impôt sur le revenu 2025 avec un barème donné : quotient familial,
# plafonnement et décote de la législation 2025
impot_bareme <- function(revenu, parts, couple, bareme) {
  impot_parts <- function(n) n * impot_une_part(revenu / n, bareme)
  impot <- impot_parts(parts)
  parts_base <- if (couple) 2 else 1
  if (parts > parts_base) {
    pq <- plafonnement_qf
    plafond <- pq$general[pq$annee_revenus == max(pq$annee_revenus[pq$annee_revenus <= annee])]
    impot <- max(impot, impot_parts(parts_base) - plafond * (parts - parts_base) * 2)
  }
  impot - calc_decote(impot, annee, couple, parts)
}

# CSG et CRDS d'un salarié, CSG proportionnelle (législation) ou progressive
csg_crds <- function(brut, progressive) {
  p <- prelevements_sociaux[prelevements_sociaux$annee == annee, ]
  assiette <- brut - p$csg_abattement * pmin(brut, 4 * p$pss)
  if (!progressive) {
    csg <- p$csg_taux * assiette
  } else {
    # Barème appliqué au salaire brut, puis réduit dans le rapport assiette / brut
    csg_brut <- sum(csg_lfi$taux * pmax(0, pmin(brut, csg_lfi$borne_sup) - csg_lfi$borne_inf))
    csg <- if (brut > 0) csg_brut * assiette / brut else 0
  }
  # La part déductible reste proportionnelle à la CSG (6,8 / 9,2)
  list(csg = csg, csg_deductible = csg * p$csg_deductible / p$csg_taux,
       crds = p$crds_taux * assiette)
}

# Taux de prélèvement d'un foyer, aides comprises, sous un scénario
taux_scenario <- function(brut1, brut2, parts, couple, cadre1, cadre2, enfants,
                          bareme = NULL, csg_progressive = FALSE) {
  cot1 <- montant_cotisations(brut1, annee, cadre1)
  cot2 <- montant_cotisations(brut2, annee, cadre2)
  cc1 <- csg_crds(brut1, csg_progressive)
  cc2 <- csg_crds(brut2, csg_progressive)
  net_imp1 <- brut1 - cot1 - cc1$csg_deductible
  net_imp2 <- brut2 - cot2 - cc2$csg_deductible
  revenu <- revenu_imposable_salaire(net_imp1, annee) + revenu_imposable_salaire(net_imp2, annee)
  impot <- if (is.null(bareme)) {
    calc_ir(revenu, parts = parts, annee = annee, couple = couple,
            decote = TRUE, plafonnement = TRUE)
  } else {
    impot_bareme(revenu, parts, couple, bareme)
  }
  # Prime d'activité recalculée sur le nouveau salaire net
  net1 <- brut1 - cot1 - cc1$csg - cc1$crds
  net2 <- brut2 - cot2 - cc2$csg - cc2$crds
  prime <- calc_prime_activite(net1, annee, net2 = net2, couple = couple, enfants = enfants)
  brut <- brut1 + brut2
  100 * (cot1 + cot2 + cc1$csg + cc2$csg + cc1$crds + cc2$crds + impot - prime) / brut
}

# ---------------------------------------------------------------------------
# Cas types et simulation
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
s <- smic$smic_annuel[smic$annee == annee]

simulation <- do.call(rbind, lapply(seq_len(nrow(cas_types)), function(i) {
  ct <- cas_types[i, ]
  f <- function(...) taux_scenario(ct$k1 * s, ct$k2 * s, ct$parts, ct$couple,
                                   ct$cadre1, ct$cadre2, ct$enfants, ...)
  # Contrôle : le scénario « législation » doit redonner prelevements_salaire()
  officiel <- prelevements_salaire(ct$k1 * s, annee = annee, brut2 = ct$k2 * s,
                                   parts = ct$parts, couple = ct$couple,
                                   decote = TRUE, plafonnement = TRUE,
                                   cadre = ct$cadre1, cadre2 = ct$cadre2,
                                   aides = TRUE, personnes_charge = ct$enfants)
  stopifnot(abs(f() - 100 * officiel$taux_prelevements) < 1e-8)
  data.frame(cas = ct$cas,
             legislation      = f(),
             ir_14_tranches   = f(bareme = bareme_lfi),
             ir_et_csg        = f(bareme = bareme_lfi, csg_progressive = TRUE))
})) |>
  mutate(ecart = ir_et_csg - legislation)

# Écart de taux entre C et A
ecart_CA <- simulation |>
  summarise(across(c(legislation, ir_14_tranches, ir_et_csg, ecart),
                   ~ .x[cas == "C"] - .x[cas == "A"])) |>
  mutate(cas = "C - A")

bind_rows(simulation, ecart_CA) |>
  mutate(across(where(is.numeric), ~ round(.x, 1))) |>
  as_tibble() |>
  print()
