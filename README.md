# baremesipp

*Historical French income tax schedules in R, from the IPP's Barèmes.*

`baremesipp` donne accès en R au barème de l'impôt sur le revenu français depuis 1945, nettoyé à partir des [Barèmes IPP](https://www.ipp.eu/baremes-ipp/) de l'Institut des politiques publiques. Il permet de :

- calculer l'impôt d'un foyer sous le barème de n'importe quelle année, avec le quotient familial et la décote ;
- convertir les montants en **euros constants**, en gérant l'inflation et les changements de monnaie (anciens francs, francs, euros) ;
- **comparer les barèmes dans le temps** : combien paierait aujourd'hui un foyer sous le barème de 1985 ?

## Installation

```r
# install.packages("devtools")
devtools::install_github("m-gty/baremesipp")
```

## Exemples

### Calculer l'impôt

Impôt d'un célibataire déclarant 30 000 € de revenu imposable en 2025 :

```r
library(baremesipp)
calc_ir(30000, annee = 2025)
#> [1] 2103.99
```

Avec la décote, qui réduit l'impôt des foyers faiblement imposés :

```r
calc_ir(20000, annee = 2025, decote = TRUE)
#> [1] 445.11
```

Pour un couple soumis à imposition commune (2 parts) :

```r
calc_ir(40000, parts = 2, annee = 2025, couple = TRUE, decote = TRUE)
```

### Comparer les barèmes en euros constants

Combien paierait un célibataire à 30 000 € (euros de 2025) sous le barème de 2010 ?

```r
calc_ir_constant(30000, annee = 2010)
```

Convertir un montant historique en euros de 2025 :

```r
en_euros_constants(100000, annee = 1985)   # 100 000 francs de 1985
```

Impôt d'un célibataire, en euros de 2025, sous différents barèmes :

```r
annees <- c(1960, 1970, 1980, 1990, 2000, 2010, 2025)
sapply(annees, function(a) round(calc_ir_constant(30000, annee = a)))
```

## Précautions d'interprétation

`calc_ir` calcule l'impôt issu du barème, avec le quotient familial et, sur option, la décote (revenus 2001 et après). Il ne prend pas encore en compte le plafonnement des effets du quotient familial, ni les réductions et crédits d'impôt.

**Les comparaisons dans le temps se font à revenu net imposable égal.** La définition de ce revenu a changé : jusqu'en 2005, les salaires bénéficiaient d'un abattement de 20 %, intégré au barème en 2006. À revenu imposable égal, un foyer d'avant 2006 correspond donc à un salaire plus élevé, et l'impôt des années antérieures est surestimé par rapport à un raisonnement à salaire égal. Les taxes complémentaires d'avant 1970 ne sont pas incluses. Les comparaisons lointaines sont donc indicatives.

Les montants sont exprimés dans la monnaie de l'année : anciens francs jusqu'en 1959, francs jusqu'en 2000, euros ensuite.

## Données

| Jeu de données | Contenu | Source |
|---|---|---|
| `bareme_ir` | Seuils et taux du barème, revenus 1945-2025 | Barèmes IPP ; lois de finances pour 2025 et 2026 |
| `decote` | Paramètres de la décote, revenus 1950-2025 | Barèmes IPP ; loi de finances pour 2026 |
| `ipc` | Indice des prix à la consommation, 1901-2025 (base 2025) | INSEE, via DBnomics |

Quand un barème n'a pas changé une année donnée, le dernier barème en vigueur s'applique.

Les **Barèmes IPP** sont produits par l'[Institut des politiques publiques](https://www.ipp.eu/) et diffusés sous [Licence Ouverte / Open Licence](https://www.etalab.gouv.fr/licence-ouverte-open-licence/) ([fiche data.gouv.fr](https://www.data.gouv.fr/datasets/baremes-ipp-systeme-social-et-fiscal-francais)), téléchargés en octobre 2026. Les barèmes des revenus 2024 et 2025, absents des Barèmes IPP, ont été ajoutés à partir de l'article 197 du Code général des impôts : loi n° 2025-127 du 14 février 2025 (art. 2) et loi n° 2026-103 du 19 février 2026 (art. 4).

L'**indice des prix** est la série INSEE « Coefficient de transformation de l'euro ou du franc d'une année en euro ou en franc d'une autre année - Base 2025 ». Ses valeurs anciennes sont arrondies à deux décimales, soit une imprécision d'au plus 0,5 % dès 1945.

Si vous utilisez ces données, merci de citer l'IPP et l'INSEE. Les scripts de nettoyage sont disponibles dans `data-raw/`.

## Feuille de route

- [x] Barème de l'impôt sur le revenu, 1945-2025
- [x] Décote (revenus 2001-2025)
- [x] Conversion en euros constants et comparaison des barèmes
- [ ] Comparaison à salaire égal (abattements de 10 % et de 20 %)
- [ ] Décote avant 2001
- [ ] Plafonnement des effets du quotient familial
- [ ] Autres barèmes IPP : CSG, cotisations sociales, prestations

Les contributions sont bienvenues : ouvrez une *issue* ou une *pull request*.
