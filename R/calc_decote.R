#' Calculer la décote de l'impôt sur le revenu
#'
#' Applique la décote en vigueur pour une année de revenus à un impôt brut :
#' décote = seuil - taux x impôt, dans la limite du montant de l'impôt.
#'
#' @param impot Impôt brut issu du barème (un ou plusieurs montants).
#' @param annee Année de perception des revenus (1981 ou après).
#' @param couple `TRUE` pour un couple soumis à imposition commune. Depuis les
#'   revenus 2014, les couples ont un seuil spécifique.
#' @param parts Nombre de parts de quotient familial. Utilisé pour les revenus
#'   1981-1985, où la décote était réservée aux foyers à 1 ou 1,5 part.
#'
#' @return Le montant de la décote, compris entre 0 et l'impôt.
#'
#' @details Revenus 1981-1985 : seuil - impôt, avec un seuil propre aux foyers
#'   à 1 part et à 1,5 part, et pas de décote au-delà. Revenus 1986-1999 :
#'   seuil - impôt pour tous. Le taux vaut ensuite 0,5 pour 2000-2013, 1 en
#'   2014, 0,75 pour 2015-2019 et 0,4525 depuis 2020. Avant les revenus 1993,
#'   la décote s'appliquait avant le plafonnement du quotient familial ; le
#'   package l'applique toujours après. Les règles d'avant 1981 ne sont pas
#'   implémentées.
#'
#' @source Barèmes IPP, Institut des politiques publiques ; article 197 du
#'   CGI (versions successives) ; BOI 5 B-9-01.
#'
#' @examples
#' calc_decote(935.33, annee = 2024)
#' calc_decote(2000, annee = 1999)
#' calc_decote(2000, annee = 1983, parts = 1)
#'
#' @export
calc_decote <- function(impot, annee, couple = FALSE, parts = 1) {
  decote <- baremesipp::decote

  if (annee < 1981) {
    stop("La d\u00e9cote n'est impl\u00e9ment\u00e9e qu'\u00e0 partir des revenus 1981.")
  }
  if (annee > max(decote$annee_revenus)) {
    stop("Pas de d\u00e9cote disponible pour les revenus ", annee, ".")
  }

  annees_dispo <- decote$annee_revenus
  d <- decote[decote$annee_revenus == max(annees_dispo[annees_dispo <= annee]), ]

  if (annee <= 1985) {
    # Décote réservée aux foyers à 1 ou 1,5 part
    seuil <- if (parts == 1) d$seuil_1_part else if (parts == 1.5) d$seuil_15_part else 0
  } else {
    seuil <- if (couple && !is.na(d$seuil_couple)) d$seuil_couple else d$seuil_celib
  }

  montant <- pmax(0, seuil - d$taux * impot)
  pmin(montant, impot)
}
