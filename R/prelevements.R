# Paramètres d'une année (dernière ligne <= annee)
params_annee <- function(tab, annee, nom) {
  if (annee < min(tab$annee) || annee > max(tab$annee)) {
    stop("Param\u00e8tres ", nom, " disponibles pour ", min(tab$annee), "-",
         max(tab$annee), " seulement.")
  }
  tab[tab$annee == annee, ]
}

# Montant des cotisations salariales d'un non-cadre, pour un salaire brut annuel
montant_cotisations <- function(brut, annee) {
  cs  <- params_annee(baremesipp::cotisations_salariales, annee, "des cotisations")
  pss <- params_annee(baremesipp::prelevements_sociaux, annee, "sociaux")$pss
  total <- 0
  for (i in seq_len(nrow(cs))) {
    if (cs$cotisation[i] == "cet") {
      # CET : due seulement si le salaire dépasse 1 PSS, sur le salaire jusqu'à 8 PSS
      assiette <- ifelse(brut > pss, pmin(brut, 8 * pss), 0)
    } else {
      assiette <- pmax(0, pmin(brut, cs$borne_sup[i] * pss) - cs$borne_inf[i] * pss)
    }
    total <- total + cs$taux[i] * assiette
  }
  total
}

# CSG (totale et déductible) et CRDS, pour un salaire brut annuel
montant_csg_crds <- function(brut, annee) {
  p <- params_annee(baremesipp::prelevements_sociaux, annee, "sociaux")
  base_abattue <- if (p$csg_abattement_plafonne > 0) pmin(brut, 4 * p$pss) else brut
  assiette <- brut - p$csg_abattement * base_abattue
  list(csg = p$csg_taux * assiette,
       csg_deductible = p$csg_deductible * assiette,
       crds = p$crds_taux * assiette)
}

#' Prélèvements sur le salaire d'un ménage : cotisations, CSG, CRDS et impôt
#'
#' Part du salaire brut annuel et calcule, pour un salarié non-cadre du
#' secteur privé, les cotisations salariales, la CSG, la CRDS, le salaire net
#' imposable, puis l'impôt sur le revenu du foyer.
#'
#' @inheritParams calc_ir
#' @param brut Salaire brut annuel du premier salarié, dans la monnaie de
#'   l'année (un ou plusieurs montants).
#' @param brut2 Salaire brut annuel du second salarié du foyer. Par défaut 0.
#' @param annee Année des revenus (1979-2025).
#'
#' @return Un data frame avec, pour chaque salaire : `brut` (total du foyer),
#'   `cotisations`, `csg`, `crds`, `net_imposable`, `impot`, `net_apres_impot`
#'   et `taux_prelevements` (part du brut prélevée).
#'
#' @details Les cotisations sont celles d'un salarié non-cadre du régime
#'   général : maladie, vieillesse, veuvage, chômage et retraite
#'   complémentaire (ARRCO, ASF, AGFF, AGIRC-ARRCO, CEG, CET). Les
#'   paramètres sont des moyennes annuelles pondérées par les mois. Ne sont
#'   pas pris en compte : les cotisations des cadres, la part patronale de la
#'   complémentaire santé réintégrée au revenu imposable (depuis 2014) et les
#'   régimes spéciaux.
#'
#' @source Barèmes IPP, Institut des politiques publiques.
#'
#' @examples
#' prelevements_salaire(30000, annee = 2025)
#' prelevements_salaire(c(25000, 50000, 100000), annee = 2025)
#'
#' @export
prelevements_salaire <- function(brut, annee, brut2 = 0, parts = 1, couple = FALSE,
                                 decote = FALSE, plafonnement = FALSE) {
  cot1 <- montant_cotisations(brut, annee)
  cot2 <- montant_cotisations(brut2, annee)
  cc1  <- montant_csg_crds(brut, annee)
  cc2  <- montant_csg_crds(brut2, annee)

  net_imp1 <- brut  - cot1 - cc1$csg_deductible
  net_imp2 <- brut2 - cot2 - cc2$csg_deductible

  impot <- calc_ir_salaire(net_imp1, annee = annee, salaire2 = net_imp2,
                           parts = parts, couple = couple, decote = decote,
                           plafonnement = plafonnement)

  brut_total <- brut + brut2
  cotisations <- cot1 + cot2
  csg  <- cc1$csg + cc2$csg
  crds <- cc1$crds + cc2$crds
  net_apres_impot <- brut_total - cotisations - csg - crds - impot

  data.frame(brut = brut_total, cotisations = cotisations, csg = csg, crds = crds,
             net_imposable = net_imp1 + net_imp2, impot = impot,
             net_apres_impot = net_apres_impot,
             taux_prelevements = (brut_total - net_apres_impot) / brut_total)
}

#' Prélèvements sur le salaire sous les règles d'une autre année, en euros constants
#'
#' Comme [prelevements_salaire()], mais le salaire brut est exprimé en euros
#' de `annee_ref` : il est converti dans la monnaie et le niveau de prix de
#' `annee`, puis tous les montants sont reconvertis en euros de `annee_ref`.
#'
#' @inheritParams prelevements_salaire
#' @param brut Salaire brut annuel du premier salarié, en euros de `annee_ref`.
#' @param brut2 Salaire brut annuel du second salarié, en euros de `annee_ref`.
#' @param annee_ref Année de référence des montants. Par défaut 2025.
#'
#' @return Le même data frame que [prelevements_salaire()], en euros de
#'   `annee_ref`.
#'
#' @examples
#' prelevements_salaire_constant(40000, annee = 1990)
#'
#' @export
prelevements_salaire_constant <- function(brut, annee, annee_ref = 2025, brut2 = 0,
                                          parts = 1, couple = FALSE, decote = FALSE,
                                          plafonnement = FALSE) {
  f <- facteur_euros_constants(annee, annee_ref)
  res <- prelevements_salaire(brut / f, annee = annee, brut2 = brut2 / f, parts = parts,
                              couple = couple, decote = decote,
                              plafonnement = plafonnement)
  montants <- c("brut", "cotisations", "csg", "crds", "net_imposable", "impot",
                "net_apres_impot")
  res[montants] <- res[montants] * f
  res
}
