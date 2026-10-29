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

#' Indice des prix à la consommation (depuis 1901)
#'
#' Indice des prix à la consommation en moyenne annuelle, base 100 en 2025.
#' Il mesure l'inflation seule, sans les changements de monnaie.
#'
#' @format Un data frame avec 2 colonnes :
#' \describe{
#'   \item{annee}{Année}
#'   \item{indice}{Indice des prix, base 100 en 2025}
#' }
#'
#' @source INSEE, « Coefficient de transformation de l'euro ou du franc d'une
#'   année en euro ou en franc d'une autre année - Base 2025 », via DBnomics.
"ipc"

#' Abattements sur les salaires (depuis 1942)
#'
#' Paramètres de la déduction forfaitaire de 10 pour cent pour frais
#' professionnels et de l'abattement supplémentaire de 20 pour cent
#' (supprimé à partir des revenus 2006), une ligne par année de modification.
#'
#' @format Un tibble avec 9 colonnes :
#' \describe{
#'   \item{annee_revenus}{Année de perception des revenus}
#'   \item{annee_imposition}{Année d'imposition}
#'   \item{abatpro_taux}{Taux de la déduction pour frais professionnels}
#'   \item{abatpro_min}{Minimum de la déduction, par salarié}
#'   \item{abatpro_min2}{Minimum majoré pour les chômeurs de longue durée}
#'   \item{abatpro_max}{Plafond de la déduction, par salarié}
#'   \item{abat_supp_taux}{Taux de l'abattement supplémentaire}
#'   \item{abat_supp_max}{Plafond de l'abattement supplémentaire}
#'   \item{abat_supp_salaire_plafond}{Plafond de salaire correspondant}
#' }
#'
#' @source Barèmes IPP, Institut des politiques publiques ; revenus 2025 :
#'   article 83 du CGI.
"abattements_salaires"
