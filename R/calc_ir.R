#' Calculer l'impôt sur le revenu d'un foyer
#'
#' Applique le barème progressif de l'impôt sur le revenu d'une année donnée
#' au revenu net imposable d'un foyer, selon le mécanisme du quotient familial.
#'
#' @param revenu Revenu net imposable du foyer (un ou plusieurs montants),
#'   exprimé dans la monnaie de l'année : anciens francs jusqu'en 1959,
#'   francs jusqu'en 2000, euros ensuite.
#' @param parts Nombre de parts de quotient familial. Par défaut 1.
#' @param annee Année de perception des revenus (et non année d'imposition).
#'
#' @return Un vecteur numérique : l'impôt brut, avant décote, plafonnement du
#'   quotient familial, réductions et crédits d'impôt.
#'
#' @details Quand le barème n'a pas changé une année donnée, le dernier
#'   barème en vigueur est appliqué.
#'
#' @source Barèmes IPP, Institut des politiques publiques,
#'   \url{https://www.ipp.eu/baremes-ipp/}
#'
#' @examples
#' calc_ir(30000, parts = 1, annee = 2023)
#' calc_ir(c(20000, 50000, 100000), parts = 2, annee = 2023)
#'
#' @export
calc_ir <- function(revenu, parts = 1, annee) {
  bareme_ir <- baremesipp::bareme_ir
  annees_dispo <- unique(bareme_ir$annee_revenus)

  if (annee < min(annees_dispo) || annee > max(annees_dispo)) {
    stop("Pas de bar\u00e8me disponible pour les revenus ", annee,
         " (ann\u00e9es couvertes : ", min(annees_dispo), "-",
         max(annees_dispo), ").")
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
