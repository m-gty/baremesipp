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

#' Plafonnement des effets du quotient familial (depuis 1974)
#'
#' Plafonds de l'avantage fiscal procuré par les demi-parts de quotient
#' familial, une ligne par année de modification.
#'
#' @format Un tibble dont les colonnes principales sont :
#' \describe{
#'   \item{annee_revenus}{Année de perception des revenus}
#'   \item{general}{Plafond général par demi-part (depuis les revenus 1981)}
#'   \item{celib_enf}{Plafond pour la part du premier enfant d'un parent isolé}
#'   \item{celib}{Plafond pour certaines demi-parts spécifiques}
#' }
#' Les autres colonnes reprennent des dispositifs particuliers, non encore
#' utilisés par [calc_ir()].
#'
#' @source Barèmes IPP, Institut des politiques publiques ; revenus 2025 :
#'   article 197 du CGI.
"plafonnement_qf"

#' CSG, CRDS et plafond de la Sécurité sociale (1979-2025)
#'
#' Paramètres annuels de la CSG et de la CRDS sur les revenus d'activité, et
#' plafond annuel de la Sécurité sociale. Les valeurs sont des moyennes
#' annuelles pondérées par le nombre de mois d'application.
#'
#' @format Un tibble avec 7 colonnes :
#' \describe{
#'   \item{annee}{Année}
#'   \item{csg_taux}{Taux global de la CSG}
#'   \item{csg_deductible}{Part déductible du revenu imposable}
#'   \item{csg_abattement}{Abattement d'assiette pour frais professionnels}
#'   \item{csg_abattement_plafonne}{1 si l'abattement est limité à 4 PSS}
#'   \item{crds_taux}{Taux de la CRDS (même assiette que la CSG)}
#'   \item{pss}{Plafond annuel de la Sécurité sociale (francs jusqu'en 2000)}
#' }
#'
#' @source Barèmes IPP, Institut des politiques publiques. L'abattement de 5
#'   pour cent de 1991-1997, absent de l'export CSV, est complété d'après
#'   l'instruction n° 91-52-M9 du 17 avril 1991.
"prelevements_sociaux"

#' Cotisations salariales du secteur privé (1979-2025)
#'
#' Taux salariaux par statut (non-cadre ou cadre), par cotisation et par
#' tranche de salaire, exprimée en multiples du plafond de la Sécurité sociale
#' (PSS). Moyennes annuelles pondérées par le nombre de mois d'application.
#'
#' @format Un tibble avec 6 colonnes :
#' \describe{
#'   \item{annee}{Année}
#'   \item{statut}{"noncadre" ou "cadre"}
#'   \item{cotisation}{Nom de la cotisation (maladie, vieillesse, veuvage,
#'     chomage, asf, arrco, agff, agirc, apec, cet_cadres, agirc_arrco, ceg, cet)}
#'   \item{borne_inf}{Début de la tranche, en PSS}
#'   \item{borne_sup}{Fin de la tranche, en PSS (Inf pour tout le salaire)}
#'   \item{taux}{Taux salarial}
#' }
#'
#' @details La CET (depuis 2019) n'est due que si le salaire dépasse 1 PSS ;
#'   elle s'applique alors au salaire jusqu'à 8 PSS. Pour l'AGIRC, la série
#'   retenue est celle des entreprises affiliées avant 1981 (taux plus faibles
#'   jusqu'en 1995). Pour l'AGFF des cadres en 2016-2018, les colonnes 0-4 et
#'   4-8 de l'IPP sont lues comme 0-1 et 1-8 PSS.
#'
#' @source Barèmes IPP, Institut des politiques publiques. Taux effectifs
#'   (taux d'appel inclus) pour la retraite complémentaire.
"cotisations_salariales"

#' SMIC de référence (1979-2025)
#'
#' SMIC horaire brut moyen de l'année et SMIC annuel brut de référence,
#' calculé sur 151,67 heures par mois pour toutes les années.
#'
#' @format Un tibble avec 3 colonnes :
#' \describe{
#'   \item{annee}{Année}
#'   \item{smic_horaire_moyen}{SMIC horaire brut, moyenne pondérée par les mois}
#'   \item{smic_annuel}{SMIC horaire x 151,67 heures x 12 mois}
#' }
#'
#' @details Convention « SMIC à 35 heures » appliquée à toutes les années, pour
#'   neutraliser les changements de durée légale du travail (40, 39 puis 35
#'   heures) et les garanties mensuelles de rémunération de 2000-2005. Avant
#'   2002, un salarié au SMIC à temps plein gagnait environ 11 pour cent de plus.
#'   Montants en francs jusqu'en 2000, en euros ensuite.
#'
#' @source Barèmes IPP, Institut des politiques publiques.
"smic"

#' Prime pour l'emploi (revenus 2000-2016)
#'
#' Paramètres de la prime pour l'emploi, une ligne par année de modification.
#' Les paramètres de 2007 s'appliquent jusqu'aux revenus 2015 ; la prime est
#' supprimée à partir des revenus 2016.
#'
#' @format Un tibble avec 12 colonnes : année des revenus, existence de la
#'   prime, seuils de revenu d'activité (minimum, taux plein, maximum), seuils
#'   de revenu fiscal de référence, taux d'entrée et de sortie, majoration par
#'   personne à charge et montant minimum versé.
#'
#' @source Barèmes IPP, Institut des politiques publiques.
"ppe"
