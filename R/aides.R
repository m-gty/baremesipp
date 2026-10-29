# Paramètres mensuels d'une année (12 lignes), ou NULL hors de 2009-2025
params_mensuels <- function(annee) {
  tab <- baremesipp::prestations_activite
  if (annee < min(tab$annee) || annee > max(tab$annee)) return(NULL)
  tab[tab$annee == annee, ]
}

# Coefficient du montant forfaitaire selon la composition du foyer (RSA et
# prime d'activité, constant de 2009 à 2025) : +50 % pour la deuxième personne
# (conjoint, ou premier enfant d'une personne seule), +30 % pour chacune des
# deux personnes suivantes, +40 % par enfant à partir du troisième.
coef_foyer <- function(couple, enfants) {
  if (couple) {
    1 + 0.5 + 0.3 * min(enfants, 2) + 0.4 * max(enfants - 2, 0)
  } else if (enfants >= 1) {
    1 + 0.5 + 0.3 * min(enfants - 1, 1) + 0.4 * max(enfants - 2, 0)
  } else {
    1
  }
}

# Allocations familiales mensuelles, à taux plein (sans modulation selon les
# revenus ni majoration pour âge) : 32 % de la BMAF pour deux enfants,
# + 41 % par enfant supplémentaire, rien pour un seul enfant.
af_mensuelles <- function(bmaf, enfants) {
  if (enfants < 2) return(0)
  bmaf * (0.32 + 0.41 * (enfants - 2))
}

#' Calculer le RSA activité d'un foyer (2009-2015)
#'
#' Calcule, mois par mois, la part « activité » du revenu de solidarité
#' active d'un foyer locataire sans aide au logement (pas de forfait
#' logement), puis la somme sur l'année.
#'
#' @param net Salaire net annuel du premier membre du foyer (après
#'   cotisations, CSG et CRDS), supposé réparti également sur les douze mois.
#' @param annee Année.
#' @param net2 Salaire net annuel du second membre. Par défaut 0.
#' @param couple `TRUE` pour un couple.
#' @param enfants Nombre d'enfants à charge.
#'
#' @return Le RSA activité perçu sur l'année ; 0 hors de juin 2009 - décembre 2015.
#'
#' @details Par mois : RSA = montant forfaitaire du foyer + 62 pour cent x
#'   salaires - salaires - allocations familiales ; la part activité est ce
#'   qui dépasse le RSA socle. Les allocations familiales sont comptées à
#'   taux plein, sans majoration pour âge.
#'
#' @source Barèmes IPP, Institut des politiques publiques.
#'
#' @examples
#' calc_rsa_activite(12000, annee = 2012)
#'
#' @export
calc_rsa_activite <- function(net, annee, net2 = 0, couple = FALSE, enfants = 0) {
  p <- params_mensuels(annee)
  if (is.null(p)) return(0 * net)
  r <- (net + net2) / 12
  coef <- coef_foyer(couple, enfants)
  total <- 0
  for (m in seq_len(nrow(p))) {
    if (p$rsa_taux[m] > 0) {
      mf    <- p$rsa_mf[m] * coef
      af    <- af_mensuelles(p$bmaf[m], enfants)
      rsa   <- pmax(0, mf + p$rsa_taux[m] * r - r - af)
      socle <- pmax(0, mf - r - af)
      total <- total + (rsa - socle)
    }
  }
  total
}

#' Calculer la prime d'activité d'un foyer (depuis 2016)
#'
#' Calcule, mois par mois, la prime d'activité d'un foyer locataire sans aide
#' au logement (pas de forfait logement), puis la somme sur l'année.
#'
#' @inheritParams calc_rsa_activite
#'
#' @return La prime d'activité perçue sur l'année ; 0 avant 2016.
#'
#' @details Par mois : prime = montant forfaitaire du foyer + 61 pour cent
#'   (62 avant août 2018) x salaires + bonifications individuelles -
#'   max(salaires + allocations familiales, montant forfaitaire du foyer), non
#'   versée sous le montant minimum. Chaque salarié a sa bonification : nulle
#'   sous un seuil exprimé en heures de SMIC, croissante jusqu'à un second
#'   seuil, puis à son maximum (un pourcentage du montant forfaitaire de base).
#'
#' @source Barèmes IPP, Institut des politiques publiques.
#'
#' @examples
#' calc_prime_activite(18000, annee = 2025)
#' calc_prime_activite(22000, annee = 2025, net2 = 15000, couple = TRUE, enfants = 2)
#'
#' @export
calc_prime_activite <- function(net, annee, net2 = 0, couple = FALSE, enfants = 0) {
  p <- params_mensuels(annee)
  if (is.null(p)) return(0 * net)
  r1 <- net / 12
  r2 <- net2 / 12
  coef <- coef_foyer(couple, enfants)
  total <- 0
  for (m in seq_len(nrow(p))) {
    if (p$pa_mf[m] > 0) {
      seuil <- p$pa_bonif_seuil[m] * p$smic_horaire[m]
      maxi  <- p$pa_bonif_max[m] * p$smic_horaire[m]
      b_max <- p$pa_bonif_taux[m] * p$pa_mf[m]
      bonif <- function(r) b_max * pmin(1, pmax(0, (r - seuil) / (maxi - seuil)))
      mf    <- p$pa_mf[m] * coef
      af    <- af_mensuelles(p$bmaf[m], enfants)
      prime <- mf + p$pa_taux[m] * (r1 + r2) + bonif(r1) + bonif(r2) -
        pmax(r1 + r2 + af, mf)
      total <- total + ifelse(prime >= p$pa_min[m], prime, 0)
    }
  }
  total
}
