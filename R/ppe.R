#' Calculer la prime pour l'emploi (PPE)
#'
#' Calcule la prime pour l'emploi d'un foyer de salariés à temps plein, pour
#' les revenus 2000 à 2015. Elle vaut 0 avant 2000 et après 2015 (remplacée
#' par la prime d'activité).
#'
#' @param revenu1,revenu2 Revenu d'activité de chaque salarié (salaire net
#'   imposable, avant la déduction de 10 pour cent), dans la monnaie de
#'   l'année. `revenu2` vaut 0 par défaut.
#' @param rfr Revenu fiscal de référence du foyer (pour des salariés : le
#'   revenu imposable).
#' @param annee Année des revenus.
#' @param parts Nombre de parts de quotient familial.
#' @param couple `TRUE` pour un couple soumis à imposition commune.
#' @param personnes_charge Nombre de personnes à charge (majoration).
#'
#' @return Le montant de la prime pour l'emploi du foyer.
#'
#' @details Par salarié : taux d'entrée x revenu jusqu'au seuil de taux
#'   plein, puis taux de sortie x (maximum - revenu) jusqu'au maximum. Sont
#'   ajoutées les majorations par personne à charge ; une prime inférieure au
#'   montant minimum n'est pas versée. Ne sont pas implémentés : la majoration
#'   pour temps partiel, les règles des couples dont un seul membre travaille,
#'   et l'imputation du RSA activité (2009-2015).
#'
#' @source Barèmes IPP, Institut des politiques publiques ; article 200
#'   sexies du CGI.
#'
#' @examples
#' calc_ppe(10000, rfr = 9000, annee = 2007)
#'
#' @export
calc_ppe <- function(revenu1, rfr, annee, revenu2 = 0, parts = 1, couple = FALSE,
                     personnes_charge = 0) {
  if (annee < 2000 || annee > 2015) return(0 * revenu1)
  tab <- baremesipp::ppe
  p <- tab[tab$annee_revenus == max(tab$annee_revenus[tab$annee_revenus <= annee]), ]

  # Condition de ressources du foyer
  parts_base <- if (couple) 2 else 1
  seuil_rfr <- (if (couple) p$rfr_couple else p$rfr_seul) +
    p$rfr_demi_part * (parts - parts_base) * 2
  eligible <- rfr <= seuil_rfr

  # Prime individuelle
  prime_individuelle <- function(r) {
    ifelse(r < p$minimum | r > p$maximum, 0,
           ifelse(r <= p$taux_plein, p$taux_entree * r, p$taux_sortie * (p$maximum - r)))
  }
  prime <- prime_individuelle(revenu1) + prime_individuelle(revenu2)

  # Majoration pour personnes à charge, si le foyer touche la prime
  prime <- prime + ifelse(prime > 0, p$majoration_pac * personnes_charge, 0)

  # Pas de versement sous le montant minimum, ni hors condition de ressources
  ifelse(eligible & prime >= p$montant_minimum, prime, 0)
}
