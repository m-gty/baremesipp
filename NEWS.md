# baremesipp 0.2.0

# baremesipp 0.2.0

## Prélèvements sociaux

* Nouveaux jeux de données `prelevements_sociaux` (CSG, CRDS, plafond de la
  Sécurité sociale) et `cotisations_salariales` (cotisations salariales du
  secteur privé, non-cadres et cadres, depuis 1979).
* `prelevements_salaire()` et `prelevements_salaire_constant()` calculent,
  à partir du salaire brut, les cotisations, la CSG, la CRDS, l'impôt sur le
  revenu et le salaire net, pour une personne seule ou un couple.
* Option `cadre` : retraite complémentaire des cadres (AGIRC, AGFF, CET,
  APEC) avant 2019.

## Aides aux bas salaires

* `calc_ppe()` et jeu de données `ppe` : prime pour l'emploi (revenus 2000-2015).
* `calc_rsa_activite()` et `calc_prime_activite()`, avec le jeu de données
  mensuel `prestations_activite` : RSA activité (2009-2015) et prime
  d'activité (depuis 2016), pour un foyer locataire sans aide au logement.
* Option `aides` de `prelevements_salaire()` : déduit toutes ces aides, le
  RSA activité étant imputé sur la prime pour l'emploi.

## Impôt sur le revenu

* La décote est désormais calculée à partir des revenus 1981 (au lieu de
  2001) : régime réservé aux foyers à 1 ou 1,5 part en 1981-1985, puis
  seuil - impôt en 1986-1999, d'après les versions successives de
  l'article 197 du CGI.

## Autres

* Nouveau jeu de données `smic` : SMIC de référence à 35 heures, 1979-2025.
