calc_ir <- function(revenu, parts = 1, annee) {
  annees_dispo <- unique(bareme_ir$annee_revenus)

  if (annee < min(annees_dispo) || annee > max(annees_dispo)) {
    stop("Pas de barème disponible pour les revenus ", annee,
         " (années couvertes : ", min(annees_dispo), "-", max(annees_dispo), ").")
  }

  # Un barème reste en vigueur jusqu'au suivant : on prend le dernier <= annee
  annee_bareme <- max(annees_dispo[annees_dispo <= annee])
  b <- bareme_ir[bareme_ir$annee_revenus == annee_bareme, ]
  b <- b[order(b$tranche), ]

  bornes_inf <- b$seuil
  bornes_sup <- c(b$seuil[-1], Inf)

  # Impôt pour une part de quotient familial
  impot_une_part <- function(q) {
    sum(b$taux * pmax(0, pmin(q, bornes_sup) - bornes_inf))
  }

  quotient <- revenu / parts
  vapply(quotient, impot_une_part, numeric(1)) * parts
}
