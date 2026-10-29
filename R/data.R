#' Barème de l'impôt sur le revenu (depuis 1945)
#'
#' Seuils et taux marginaux du barème progressif de l'impôt sur le revenu,
#' une ligne par tranche et par année de modification du barème.
#'
#' @format Un tibble avec 6 colonnes :
#' \describe{
#'   \item{annee_revenus}{Année de perception des revenus}
#'   \item{annee_imposition}{Année d'imposition (loi de finances)}
#'   \item{tranche}{Numéro de la tranche, à partir de 0}
#'   \item{seuil}{Seuil d'entrée de la tranche, par part de quotient familial}
#'   #'   \item{taux}{Taux marginal de la tranche, en proportion (0.11 pour 11 pour cent)}
#'   \item{monnaie}{"AFRF" (anciens francs), "FRF" (francs) ou "EUR"}
#' }
#'
#' @details Une année absente signifie que le barème n'a pas changé : le
#'   barème de l'année précédente disponible s'applique.
#'
#' @source Barèmes IPP, Institut des politiques publiques,
#'   \url{https://www.ipp.eu/baremes-ipp/}
"bareme_ir"

#' Décote de l'impôt sur le revenu
#'
#' Paramètres de la décote, une ligne par année de modification.
#'
#' @format Un tibble dont les colonnes principales sont :
#' \describe{
#'   \item{annee_revenus}{Année de perception des revenus}
#'   \item{taux}{Taux appliqué à l'impôt (0.4525 pour 45,25 pour cent)}
#'   \item{seuil_celib}{Seuil pour une personne seule, ou pour tous avant 2014}
#'   \item{seuil_couple}{Seuil pour un couple soumis à imposition commune}
#'   \item{monnaie}{"AFRF", "FRF" ou "EUR"}
#' }
#' Les autres colonnes reprennent les paramètres des régimes anciens
#' (avant 2001), non encore utilisés par \code{calc_decote}.
#'
#' @source Barèmes IPP, Institut des politiques publiques,
#'   \url{https://www.ipp.eu/baremes-ipp/} ; revenus 2025 : article 197 du CGI.
"decote"
