# baremesipp

*Historical French income tax schedules in R, from the IPP's Barèmes.*

`baremesipp` donne accès en R aux paramètres de l'impôt sur le revenu français depuis 1945, nettoyés à partir des [Barèmes IPP](https://www.ipp.eu/baremes-ipp/) de l'Institut des politiques publiques. Il permet de :

- calculer l'impôt d'un foyer sous le barème de n'importe quelle année, avec le quotient familial, son plafonnement et la décote ;
- partir du **salaire déclaré**, en appliquant les abattements de chaque époque (10 % pour frais professionnels, 20 % jusqu'en 2005) ;
- convertir les montants en **euros constants**, en gérant l'inflation et les changements de monnaie (anciens francs, francs, euros) ;
- **comparer les règles fiscales dans le temps** : combien paierait aujourd'hui un salarié, ou une famille, sous les règles de 1985 ?

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

Couple avec deux enfants (3 parts), avec le plafonnement des effets du quotient familial :

```r
calc_ir(100000, parts = 3, annee = 2025, couple = TRUE, plafonnement = TRUE)
#> [1] 12593.98
```

### Partir du salaire

Revenu imposable correspondant à un salaire déclaré de 22 223 € en 2024 (déduction de 10 %) :

```r
revenu_imposable_salaire(22223, annee = 2024)
#> [1] 20000.7
```

Impôt d'un couple de deux salariés : la déduction s'applique séparément à chacun.

```r
calc_ir_salaire(30000, salaire2 = 25000, parts = 3, annee = 2024,
                couple = TRUE, decote = TRUE, plafonnement = TRUE)
```

### Comparer les règles dans le temps, en euros constants

Convertir un montant historique en euros de 2025 :

```r
en_euros_constants(100000, annee = 1985)   # 100 000 francs de 1985
```

Impôt d'un célibataire salarié (33 333 € de salaire déclaré, en euros de 2025), sous les règles de différentes années :

```r
annees <- c(1980, 1990, 2000, 2005, 2006, 2010, 2025)
sapply(annees, function(a) round(calc_ir_constant(33333, annee = a, salaire = TRUE)))
#> [1] 4818 4653 3360 2979 2493 2490 2104
```

À salaire constant, l'impôt sur le revenu d'un salarié moyen a été divisé par plus de deux entre 1980 et 2025.

Effet de la baisse du plafond du quotient familial en 2012-2013, pour un couple avec deux enfants et 150 000 € de salaires (euros de 2025) :

```r
annees <- c(2010, 2013, 2025)
sapply(annees, function(a) round(calc_ir_constant(150000, annee = a, parts = 3,
  couple = TRUE, salaire = TRUE, plafonnement = TRUE)))
#> [1] 20318 23292 23227
```

## Précautions d'interprétation

`calc_ir` calcule l'impôt issu du barème, avec le quotient familial et, sur option, son plafonnement et la décote. Il ne prend pas en compte les réductions et crédits d'impôt.

**Préférez les comparaisons à salaire égal** (`salaire = TRUE`). La définition du revenu imposable a changé dans le temps : jusqu'en 2005, les salaires bénéficiaient d'un abattement de 20 %, intégré au barème en 2006. Comparer les années à revenu imposable égal surestime donc l'impôt des années antérieures à 2006.

Pour un couple marié ou pacsé, indiquez `couple = TRUE` : les parts de base (2 au lieu de 1) déterminent le plafonnement, et le seuil de la décote en dépend.

Périodes couvertes :

| Élément | Revenus couverts |
|---|---|
| Barème | 1945-2025 |
| Abattements sur salaires | 1979-2025 |
| Plafonnement du quotient familial | 1981-2025 |
| Décote | 2001-2025 |

Ne sont pas encore pris en compte : les plafonds spécifiques du quotient familial (parent isolé, invalidité, etc.), les taxes complémentaires d'avant 1970 et le minimum majoré de déduction pour les chômeurs de longue durée (1997-2017).

Les montants sont exprimés dans la monnaie de l'année : anciens francs jusqu'en 1959, francs jusqu'en 2000, euros ensuite.

## Données

| Jeu de données | Contenu | Source |
|---|---|---|
| `bareme_ir` | Seuils et taux du barème, revenus 1945-2025 | Barèmes IPP ; lois de finances pour 2025 et 2026 |
| `decote` | Paramètres de la décote, revenus 1950-2025 | Barèmes IPP ; loi de finances pour 2026 |
| `plafonnement_qf` | Plafonds du quotient familial, revenus 1974-2025 | Barèmes IPP ; loi de finances pour 2026 |
| `abattements_salaires` | Déduction de 10 % et abattement de 20 %, revenus 1942-2025 | Barèmes IPP ; article 83 du CGI |
| `ipc` | Indice des prix à la consommation, 1901-2025 (base 2025) | INSEE, via DBnomics |

Quand un paramètre n'a pas changé une année donnée, la dernière valeur en vigueur s'applique.

Les **Barèmes IPP** sont produits par l'[Institut des politiques publiques](https://www.ipp.eu/) et diffusés sous [Licence Ouverte / Open Licence](https://www.etalab.gouv.fr/licence-ouverte-open-licence/) ([fiche data.gouv.fr](https://www.data.gouv.fr/datasets/baremes-ipp-systeme-social-et-fiscal-francais)), téléchargés en octobre 2026.

Les paramètres absents des Barèmes IPP ont été ajoutés à partir du Code général des impôts :

- barème des revenus 2024 : loi n° 2025-127 du 14 février 2025, art. 2 (article 197 du CGI) ;
- barème, décote et plafonnement du quotient familial des revenus 2025 : loi n° 2026-103 du 19 février 2026, art. 4 (article 197 du CGI) ;
- déduction pour frais professionnels des revenus 2025 (minimum 509 €, plafond 14 555 €) : article 83, 3° du CGI.

L'**indice des prix** est la série INSEE « Coefficient de transformation de l'euro ou du franc d'une année en euro ou en franc d'une autre année - Base 2025 ». Ses valeurs anciennes sont arrondies à deux décimales, soit une imprécision d'au plus 0,5 % dès 1945.

Si vous utilisez ces données, merci de citer l'IPP et l'INSEE. Les scripts de nettoyage sont disponibles dans `data-raw/`.

## Feuille de route

- [x] Barème de l'impôt sur le revenu, 1945-2025
- [x] Décote (revenus 2001-2025)
- [x] Conversion en euros constants
- [x] Comparaison à salaire égal (abattements de 10 % et de 20 %, revenus 1979 et après)
- [x] Plafonnement général du quotient familial (revenus 1981-2025)
- [ ] Plafonds spécifiques du quotient familial (parent isolé, invalidité)
- [ ] Décote avant 2001
- [ ] Abattements sur salaires avant 1979
- [ ] Autres barèmes IPP : CSG, cotisations sociales, prestations

Les contributions sont bienvenues : ouvrez une *issue* ou une *pull request*.
