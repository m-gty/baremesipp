#' Calculer la décote de l'impôt sur le revenu
#'
#' Applique la décote en vigueur pour une année de revenus à un impôt brut :
#' décote = seuil - taux x impôt, dans la limite du montant de l'impôt.
#'
#' @param impot Impôt brut issu du barème (un ou plusieurs montants).
#' @param annee Année de perception des revenus (2001 ou après).
#' @param couple `TRUE` pour un couple soumis à imposition commune. Depuis les
#'   revenus 2014, les couples ont un seuil spécifique ; avant, le seuil est
#'   le même pour tous.
#'
#' @return Le montant de la décote, compris entre 0 et l'impôt.
#'
#' @details Les règles antérieures aux revenus 2001 ne sont pas encore
#'   implémentées.
#'
#' @source Barèmes IPP, Institut des politiques publiques ; article 197 du CGI.
#'
#' @examples
#' calc_decote(935.33, annee = 2024)
#'
#' @export
calc_decote <- function(impot, annee, couple = FALSE) {
  decote <- baremesipp::decote

  if (annee < 2001) {
    stop("La d\u00e9cote n'est impl\u00e9ment\u00e9e qu'\u00e0 partir des revenus 2001.")
  }
  if (annee > max(decote$annee_revenus)) {
    stop("Pas de d\u00e9cote disponible pour les revenus ", annee, ".")
  }

  annees_dispo <- decote$annee_revenus
  d <- decote[decote$annee_revenus == max(annees_dispo[annees_dispo <= annee]), ]

  seuil <- if (couple && !is.na(d$seuil_couple)) d$seuil_couple else d$seuil_celib

  montant <- pmax(0, seuil - d$taux * impot)
  pmin(montant, impot)
}
