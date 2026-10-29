#' Calculer l'impôt sur le revenu d'un foyer
#'
#' Applique le barème progressif de l'impôt sur le revenu d'une année donnée
#' au revenu net imposable d'un foyer, selon le mécanisme du quotient familial.
#' Peut appliquer le plafonnement des effets du quotient familial et la décote.
#'
#' @param revenu Revenu net imposable du foyer (un ou plusieurs montants),
#'   exprimé dans la monnaie de l'année : anciens francs jusqu'en 1959,
#'   francs jusqu'en 2000, euros ensuite.
#' @param parts Nombre de parts de quotient familial. Par défaut 1.
#' @param annee Année de perception des revenus (et non année d'imposition).
#' @param couple `TRUE` pour un couple soumis à imposition commune. Sert à
#'   déterminer les parts de base (2 au lieu de 1) pour le plafonnement, et
#'   le seuil de la décote.
#' @param decote `TRUE` pour appliquer la décote (revenus 1981 et après).
#' @param plafonnement `TRUE` pour plafonner l'avantage procuré par les
#'   demi-parts supplémentaires (revenus 1981 et après).
#'
#' @return Un vecteur numérique : l'impôt issu du barème, après plafonnement
#'   du quotient familial et décote si demandés, mais avant réductions et
#'   crédits d'impôt.
#'
#' @details Quand un paramètre n'a pas changé une année donnée, la dernière
#'   valeur en vigueur est appliquée. Le plafonnement utilise le plafond
#'   général par demi-part ; les plafonds spécifiques (parent isolé,
#'   invalidité, etc.) ne sont pas encore pris en compte.
#'
#' @source Barèmes IPP, Institut des politiques publiques,
#'   \url{https://www.ipp.eu/baremes-ipp/} ; article 197 du CGI.
#'
#' @examples
#' calc_ir(30000, parts = 1, annee = 2025)
#' calc_ir(c(20000, 50000, 100000), parts = 2, annee = 2025, couple = TRUE)
#' calc_ir(20000, annee = 2025, decote = TRUE)
#' # Couple avec deux enfants (3 parts), avec plafonnement
#' calc_ir(100000, parts = 3, annee = 2025, couple = TRUE, plafonnement = TRUE)
#'
#' @export
calc_ir <- function(revenu, parts = 1, annee, couple = FALSE, decote = FALSE,
                    plafonnement = FALSE) {
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

  # Impôt issu du barème pour un nombre de parts donné
  impot_bareme <- function(nb_parts) {
    vapply(revenu / nb_parts, impot_une_part, numeric(1)) * nb_parts
  }

  impot <- impot_bareme(parts)

  # Plafonnement des effets du quotient familial (optionnel)
  if (plafonnement) {
    impot <- plafonner_qf(impot, impot_bareme, parts, annee, couple)
  }

  # Décote (optionnelle), appliquée après le plafonnement
  if (decote) impot <- impot - calc_decote(impot, annee, couple, parts)

  impot
}

# Applique le plafond général par demi-part au-delà des parts de base
plafonner_qf <- function(impot, impot_bareme, parts, annee, couple) {
  pq <- baremesipp::plafonnement_qf

  if (annee < 1981) {
    stop("Le plafonnement du quotient familial n'est impl\u00e9ment\u00e9 qu'\u00e0 partir des revenus 1981.")
  }
  if (annee > max(pq$annee_revenus)) {
    stop("Pas de plafond disponible pour les revenus ", annee, ".")
  }

  parts_base <- if (couple) 2 else 1
  if (parts <= parts_base) return(impot)

  p <- pq[pq$annee_revenus == max(pq$annee_revenus[pq$annee_revenus <= annee]), ]
  avantage_max <- p$general * (parts - parts_base) * 2   # par demi-part

  pmax(impot, impot_bareme(parts_base) - avantage_max)
}
