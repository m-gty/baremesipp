# baremesipp

*Historical French income tax schedules in R, from the IPP's Barèmes.*

`baremesipp` donne accès en R au barème de l'impôt sur le revenu français depuis 1945, nettoyé à partir des [Barèmes IPP](https://www.ipp.eu/baremes-ipp/) de l'Institut des politiques publiques, et permet de calculer l'impôt d'un foyer selon le barème de n'importe quelle année.

## Installation

```r
# install.packages("devtools")
devtools::install_github("m-gty/baremesipp")
```

## Exemples

Impôt d'un célibataire déclarant 30 000 € de revenu imposable en 2023 :

```r
library(baremesipp)
calc_ir(30000, parts = 1, annee = 2023)
#> [1] 2286.23
```

Plusieurs revenus pour un couple (2 parts) :

```r
calc_ir(c(20000, 50000, 100000), parts = 2, annee = 2023)
#> [1]     0.00  3015.32 16572.46
```

Le barème lui-même, en format long (une ligne par tranche et par année) :

```r
bareme_ir[bareme_ir$annee_revenus == 2023, ]
```

## Ce que fait (et ne fait pas encore) `calc_ir`

`calc_ir` calcule l'**impôt brut** issu du barème progressif, avec le quotient familial. Elle ne prend pas encore en compte :

- la décote ;
- le plafonnement des effets du quotient familial ;
- les réductions et crédits d'impôt.

Les montants sont exprimés dans la monnaie de l'année : anciens francs jusqu'en 1959, francs jusqu'en 2000, euros ensuite.

## Données

Les barèmes couvrent les revenus de 1945 à 2023. Quand le barème n'a pas changé une année donnée, le dernier barème en vigueur s'applique.

Toutes les données proviennent des **Barèmes IPP** produits par l'[Institut des politiques publiques](https://www.ipp.eu/), diffusés sous [Licence Ouverte / Open Licence](https://www.etalab.gouv.fr/licence-ouverte-open-licence/) ([fiche data.gouv.fr](https://www.data.gouv.fr/datasets/baremes-ipp-systeme-social-et-fiscal-francais)). Données téléchargées en octobre 2026. Si vous les utilisez, merci de citer l'IPP.

Le script de nettoyage est disponible dans `data-raw/`.

## Feuille de route

- [ ] Barèmes des revenus 2024 et 2025
- [ ] Décote
- [ ] Plafonnement du quotient familial
- [ ] Autres barèmes IPP : CSG, cotisations sociales, prestations

Les contributions sont bienvenues : ouvrez une *issue* ou une *pull request*.
