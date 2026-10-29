# Facteur pour passer d'une unité monétaire de l'année `annee` (anciens francs,
# francs ou euros) à des euros ayant le pouvoir d'achat de l'année `annee_ref`.
facteur_euros_constants <- function(annee, annee_ref) {
  ipc <- baremesipp::ipc
  i     <- ipc$indice[match(annee, ipc$annee)]
  i_ref <- ipc$indice[match(annee_ref, ipc$annee)]
  if (anyNA(i) || anyNA(i_ref)) {
    stop("Indice des prix indisponible pour l'ann\u00e9e demand\u00e9e (",
         min(ipc$annee), "-", max(ipc$annee), ").")
  }
  unites_par_euro <- ifelse(annee <= 1959, 655.957,         # anciens francs
                            ifelse(annee <= 2000, 6.55957, 1))     # francs, euros
  (1 / unites_par_euro) * i_ref / i
}

#' Convertir un montant en euros constants
#'
#' Exprime un montant de l'année `annee`, dans la monnaie de l'époque, en
#' euros ayant le pouvoir d'achat de l'année `annee_ref`. La fonction gère les
#' changements de monnaie (1 franc = 100 anciens francs, 1 euro = 6,55957
#' francs) et l'inflation.
#'
#' @param montant Montant(s) dans la monnaie de l'année `annee`.
#' @param annee Année du montant.
#' @param annee_ref Année de référence pour le pouvoir d'achat. Par défaut 2025.
#'
#' @return Le montant en euros constants de `annee_ref`.
#'
#' @details Les années de revenus jusqu'en 1959 sont en anciens francs, de
#'   1960 à 2000 en francs, puis en euros, comme dans [bareme_ir].
#'
#' @source INSEE, coefficients de transformation du pouvoir d'achat de l'euro
#'   et du franc (base 2025). Les valeurs anciennes sont arrondies à deux
#'   décimales, soit une imprécision d'au plus 0,5 pour cent dès 1945.
#'
#' @examples
#' en_euros_constants(100000, annee = 1985)
#'
#' @export
en_euros_constants <- function(montant, annee, annee_ref = 2025) {
  montant * facteur_euros_constants(annee, annee_ref)
}

#' Calculer l'impôt sous les règles d'une autre année, en euros constants
#'
#' Répond à la question : combien paierait un foyer dont le revenu (ou le
#' salaire) est exprimé en euros de `annee_ref`, si on lui appliquait les
#' règles de l'année `annee` ? Le montant est converti dans la monnaie et le
#' niveau de prix de `annee`, l'impôt est calculé, puis reconverti en euros
#' de `annee_ref`.
#'
#' @inheritParams calc_ir
#' @param revenu Revenu net imposable, ou salaire déclaré si
#'   `salaire = TRUE`, en euros de `annee_ref`.
#' @param annee Année dont on applique les règles.
#' @param annee_ref Année de référence des montants. Par défaut 2025.
#' @param salaire `TRUE` pour interpréter `revenu` comme le salaire déclaré
#'   d'un salarié : les abattements de l'année `annee` (10 et 20 pour cent)
#'   sont alors appliqués, ce qui rend les comparaisons historiques plus
#'   fiables (revenus 1979 et après).
#'
#' @return L'impôt, en euros de `annee_ref`.
#'
#' @details Avec `salaire = FALSE`, la comparaison se fait à revenu net
#'   imposable égal, dont la définition a changé dans le temps (abattement de
#'   20 pour cent sur les salaires jusqu'en 2005). Préférer `salaire = TRUE`
#'   pour comparer des foyers de salariés.
#'
#' @examples
#' calc_ir_constant(30000, annee = 1985)
#' calc_ir_constant(33333, annee = 1985, salaire = TRUE)
#' # Couple avec deux enfants, 80 000 euros de salaire
#' calc_ir_constant(80000, annee = 1990, parts = 3, couple = TRUE,
#'                  plafonnement = TRUE, salaire = TRUE)
#'
#' @export
calc_ir_constant <- function(revenu, annee, annee_ref = 2025, parts = 1,
                             couple = FALSE, decote = FALSE,
                             plafonnement = FALSE, salaire = FALSE) {
  f <- facteur_euros_constants(annee, annee_ref)
  montant <- revenu / f
  if (salaire) montant <- revenu_imposable_salaire(montant, annee)
  impot <- calc_ir(montant, parts = parts, annee = annee, couple = couple,
                   decote = decote, plafonnement = plafonnement)
  impot * f
}
