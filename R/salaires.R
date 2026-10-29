#' Passer du salaire déclaré au revenu imposable
#'
#' Applique la déduction forfaitaire de 10 pour cent pour frais professionnels
#' (avec son minimum et son plafond) puis, jusqu'aux revenus 2005,
#' l'abattement supplémentaire de 20 pour cent (avec son plafond).
#'
#' @param salaire Salaire déclaré d'un salarié (un ou plusieurs montants),
#'   dans la monnaie de l'année.
#' @param annee Année des revenus (1979 ou après).
#'
#' @return Le revenu imposable correspondant.
#'
#' @details Le minimum et le plafond s'appliquent par salarié. Le minimum
#'   majoré des chômeurs de longue durée (1997-2017) n'est pas appliqué.
#'
#' @source Barèmes IPP, Institut des politiques publiques ; article 83 du CGI.
#'
#' @examples
#' revenu_imposable_salaire(22223, annee = 2024)
#' revenu_imposable_salaire(20000, annee = 2005)
#'
#' @export
revenu_imposable_salaire <- function(salaire, annee) {
  ab <- baremesipp::abattements_salaires

  if (annee < 1979) {
    stop("Les abattements sur salaires ne sont impl\u00e9ment\u00e9s qu'\u00e0 partir des revenus 1979.")
  }
  if (annee > max(ab$annee_revenus)) {
    stop("Pas de param\u00e8tres disponibles pour les revenus ", annee, ".")
  }

  p <- ab[ab$annee_revenus == max(ab$annee_revenus[ab$annee_revenus <= annee]), ]

  # Déduction de 10 % : au moins le minimum (sans dépasser le salaire), au plus le plafond
  deduction <- pmax(p$abatpro_taux * salaire, p$abatpro_min)
  deduction <- pmin(deduction, salaire, p$abatpro_max)
  net <- salaire - deduction

  # Abattement de 20 % (jusqu'aux revenus 2005)
  if (!is.na(p$abat_supp_taux)) {
    net <- net - pmin(p$abat_supp_taux * net, p$abat_supp_max)
  }
  net
}

#' Calculer l'impôt sur le revenu à partir des salaires
#'
#' @inheritParams calc_ir
#' @param salaire Salaire déclaré du premier salarié, dans la monnaie de l'année.
#' @param salaire2 Salaire déclaré du second salarié du foyer. Par défaut 0.
#'
#' @return L'impôt, calculé comme [calc_ir()] sur le revenu imposable obtenu
#'   par [revenu_imposable_salaire()].
#'
#' @examples
#' calc_ir_salaire(22223, annee = 2024)
#' calc_ir_salaire(30000, salaire2 = 25000, parts = 2, annee = 2024,
#'                 couple = TRUE, decote = TRUE)
#'
#' @export
calc_ir_salaire <- function(salaire, annee, salaire2 = 0, parts = 1,
                            couple = FALSE, decote = FALSE) {
  revenu <- revenu_imposable_salaire(salaire, annee) +
    revenu_imposable_salaire(salaire2, annee)
  calc_ir(revenu, parts = parts, annee = annee, couple = couple, decote = decote)
}
