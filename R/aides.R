# Paramètres mensuels d'une année (12 lignes), ou NULL hors de 2009-2025
params_mensuels <- function(annee) {
  tab <- baremesipp::prestations_activite
  if (annee < min(tab$annee) || annee > max(tab$annee)) return(NULL)
  tab[tab$annee == annee, ]
}

#' Calculer le RSA activité d'une personne seule (2009-2015)
#'
#' Calcule, mois par mois, la part « activité » du revenu de solidarité
#' active d'une personne seule sans enfant, locataire sans aide au logement
#' (pas de forfait logement), puis la somme sur l'année.
#'
#' @param net Salaire net annuel (après cotisations, CSG et CRDS), supposé
#'   réparti également sur les douze mois. Un ou plusieurs montants.
#' @param annee Année.
#'
#' @return Le RSA activité perçu sur l'année ; 0 hors de juin 2009 - décembre 2015.
#'
#' @details Par mois : RSA = montant forfaitaire + 62 pour cent x salaire -
#'   salaire ; la part activité est ce qui dépasse le RSA socle
#'   (montant forfaitaire - salaire, s'il est positif).
#'
#' @source Barèmes IPP, Institut des politiques publiques.
#'
#' @examples
#' calc_rsa_activite(12000, annee = 2012)
#'
#' @export
calc_rsa_activite <- function(net, annee) {
  p <- params_mensuels(annee)
  if (is.null(p)) return(0 * net)
  r <- net / 12
  total <- 0
  for (m in seq_len(nrow(p))) {
    if (p$rsa_taux[m] > 0) {
      rsa   <- pmax(0, p$rsa_mf[m] + p$rsa_taux[m] * r - r)
      socle <- pmax(0, p$rsa_mf[m] - r)
      total <- total + (rsa - socle)
    }
  }
  total
}

#' Calculer la prime d'activité d'une personne seule (depuis 2016)
#'
#' Calcule, mois par mois, la prime d'activité d'une personne seule sans
#' enfant, locataire sans aide au logement (pas de forfait logement), puis la
#' somme sur l'année.
#'
#' @inheritParams calc_rsa_activite
#'
#' @return La prime d'activité perçue sur l'année ; 0 avant 2016.
#'
#' @details Par mois : prime = montant forfaitaire + 61 pour cent (62 avant
#'   août 2018) x salaire + bonification - max(salaire, montant forfaitaire),
#'   non versée sous le montant minimum. La bonification est nulle sous un
#'   seuil exprimé en heures de SMIC, croît en ligne droite jusqu'à un second
#'   seuil, puis reste à son maximum (un pourcentage du montant forfaitaire).
#'
#' @source Barèmes IPP, Institut des politiques publiques.
#'
#' @examples
#' calc_prime_activite(18000, annee = 2025)
#'
#' @export
calc_prime_activite <- function(net, annee) {
  p <- params_mensuels(annee)
  if (is.null(p)) return(0 * net)
  r <- net / 12
  total <- 0
  for (m in seq_len(nrow(p))) {
    if (p$pa_mf[m] > 0) {
      seuil  <- p$pa_bonif_seuil[m] * p$smic_horaire[m]
      maxi   <- p$pa_bonif_max[m] * p$smic_horaire[m]
      b_max  <- p$pa_bonif_taux[m] * p$pa_mf[m]
      bonif  <- b_max * pmin(1, pmax(0, (r - seuil) / (maxi - seuil)))
      prime  <- p$pa_mf[m] + p$pa_taux[m] * r + bonif - pmax(r, p$pa_mf[m])
      total  <- total + ifelse(prime >= p$pa_min[m], prime, 0)
    }
  }
  total
}
