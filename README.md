# baremesipp

*Historical French income tax, social contributions and in-work benefits in R, from the IPP's Barèmes.*

`baremesipp` donne accès en R aux paramètres de l'impôt sur le revenu français depuis 1945, des prélèvements sociaux sur les salaires depuis 1979 et des aides aux bas salaires depuis 2000, nettoyés à partir des [Barèmes IPP](https://www.ipp.eu/baremes-ipp/) de l'Institut des politiques publiques. Il permet de :

- calculer l'impôt d'un foyer sous le barème de n'importe quelle année, avec le quotient familial, son plafonnement et la décote ;
- partir du **salaire déclaré**, en appliquant les abattements de chaque époque (10 % pour frais professionnels, 20 % jusqu'en 2005) ;
- partir du **salaire brut**, et calculer les cotisations salariales (non-cadres et cadres), la CSG, la CRDS, l'impôt et le salaire net ;
- déduire les **aides aux bas salaires** : prime pour l'emploi, RSA activité et prime d'activité ;
- convertir les montants en **euros constants**, en gérant l'inflation et les changements de monnaie (anciens francs, francs, euros) ;
- **comparer les règles dans le temps** : combien paierait aujourd'hui un salarié, ou une famille, sous les règles de 1985 ?

## Installation

```r
# install.packages("pak")
pak::pak("m-gty/baremesipp")
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

### Partir du salaire déclaré

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

### Partir du salaire brut : cotisations, CSG, CRDS et impôt

Tous les prélèvements sur un salaire brut annuel de 40 000 € en 2025, pour un non-cadre :

```r
prelevements_salaire(40000, annee = 2025, decote = TRUE)
```

Le résultat détaille les cotisations salariales, la CSG, la CRDS, le salaire net imposable, l'impôt, le salaire net après impôt et la part du brut prélevée (`taux_prelevements`).

Pour un cadre (retraite complémentaire AGIRC avant 2019, APEC), ou pour un couple :

```r
prelevements_salaire(80000, annee = 2010, cadre = TRUE, decote = TRUE)
prelevements_salaire(60000, brut2 = 30000, annee = 2025, parts = 3, couple = TRUE,
                     cadre = TRUE, decote = TRUE, plafonnement = TRUE)
```

### Les aides aux bas salaires

L'option `aides = TRUE` déduit la prime pour l'emploi (revenus 2000-2015), le RSA activité (2009-2015, imputé sur la prime pour l'emploi) et la prime d'activité (depuis 2016). Pour un célibataire au SMIC en 2025 :

```r
smic_2025 <- smic$smic_annuel[smic$annee == 2025]
prelevements_salaire(smic_2025, annee = 2025, decote = TRUE)
prelevements_salaire(smic_2025, annee = 2025, decote = TRUE, aides = TRUE)
```

Sans les aides, ce salarié cède environ 21 % de son salaire brut en prélèvements ; une fois la prime d'activité déduite, environ 6,5 %.

Pour un foyer avec enfants, `personnes_charge` donne le nombre d'enfants :

```r
prelevements_salaire(1.5 * smic_2025, brut2 = smic_2025, annee = 2025, parts = 3,
                     couple = TRUE, decote = TRUE, plafonnement = TRUE,
                     aides = TRUE, personnes_charge = 2)
```

Les fonctions `calc_ppe()`, `calc_rsa_activite()` et `calc_prime_activite()` calculent chaque aide séparément.

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

À salaire réel constant, l'impôt sur le revenu d'un salarié moyen a été divisé par plus de deux entre 1980 et 2025. Le barème n'étant indexé que sur les prix, un salarié qui conserve sa place dans l'échelle des salaires a vu son impôt baisser beaucoup moins : pour le suivre, exprimez son salaire en multiples du SMIC de chaque année (jeu de données `smic`).

Tous les prélèvements sur un salaire brut de 40 000 € de 2025, sous les règles de 1990 :

```r
prelevements_salaire_constant(40000, annee = 1990, decote = TRUE)
```

Effet de la baisse du plafond du quotient familial en 2012-2013, pour un couple avec deux enfants et 150 000 € de salaires (euros de 2025) :

```r
annees <- c(2010, 2013, 2025)
sapply(annees, function(a) round(calc_ir_constant(150000, annee = a, parts = 3,
  couple = TRUE, salaire = TRUE, plafonnement = TRUE)))
#> [1] 20318 23292 23227
```

## Précautions d'interprétation

### Impôt sur le revenu

`calc_ir` calcule l'impôt issu du barème, avec le quotient familial et, sur option, son plafonnement et la décote. Il ne prend pas en compte les réductions et crédits d'impôt, sauf la prime pour l'emploi dans `prelevements_salaire()`.

**Préférez les comparaisons à salaire égal** (`salaire = TRUE`). La définition du revenu imposable a changé dans le temps : jusqu'en 2005, les salaires bénéficiaient d'un abattement de 20 %, intégré au barème en 2006. Comparer les années à revenu imposable égal surestime donc l'impôt des années antérieures à 2006.

Pour un couple marié ou pacsé, indiquez `couple = TRUE` : les parts de base (2 au lieu de 1) déterminent le plafonnement, et le seuil de la décote en dépend.

Avant les revenus 1993, la décote s'appliquait avant le plafonnement du quotient familial ; le package l'applique toujours après.

### Prélèvements sociaux

Les cotisations sont celles d'un salarié du secteur privé relevant du régime général et de l'assurance chômage. Pour les cadres, la série AGIRC retenue est celle des entreprises affiliées avant 1981 (taux plus faibles jusqu'en 1995) ; la garantie minimale de points (GMP) et le forfait APEC d'avant 2011 sont négligés. Les cotisations patronales ne sont pas calculées.

Les paramètres qui changent en cours d'année sont pris en moyenne pondérée par le nombre de mois d'application.

### Aides aux bas salaires

Le RSA activité et la prime d'activité supposent un foyer **locataire sans aide au logement** (pas de forfait logement), des enfants de moins de 14 ans et des allocations familiales à taux plein, comptées dans les ressources du foyer. La prime pour l'emploi suppose des salariés à temps plein ; les règles des couples dont un seul membre travaille ne sont pas implémentées.

Ces calculs décrivent ce que prévoit la loi : une part importante des personnes éligibles ne demande pas la prime d'activité.

### Périodes couvertes

| Élément | Années couvertes |
|---|---|
| Barème de l'impôt sur le revenu | 1945-2025 |
| Abattements sur salaires | 1979-2025 |
| Plafonnement du quotient familial | 1981-2025 |
| Décote | 1981-2025 |
| Cotisations salariales, CSG, CRDS | 1979-2025 |
| Prime pour l'emploi | 2000-2015 |
| RSA activité | 2009-2015 |
| Prime d'activité | 2016-2025 |

Ne sont pas encore pris en compte : les plafonds spécifiques du quotient familial (parent isolé, invalidité, etc.), les taxes complémentaires d'avant 1970 et le minimum majoré de déduction pour les chômeurs de longue durée (1997-2017).

Les montants sont exprimés dans la monnaie de l'année : anciens francs jusqu'en 1959, francs jusqu'en 2000, euros ensuite.

## Données

| Jeu de données | Contenu | Source |
|---|---|---|
| `bareme_ir` | Seuils et taux du barème, revenus 1945-2025 | Barèmes IPP ; lois de finances pour 2025 et 2026 |
| `decote` | Paramètres de la décote, revenus 1950-2025 | Barèmes IPP ; article 197 du CGI ; loi de finances pour 2026 |
| `plafonnement_qf` | Plafonds du quotient familial, revenus 1974-2025 | Barèmes IPP ; loi de finances pour 2026 |
| `abattements_salaires` | Déduction de 10 % et abattement de 20 %, revenus 1942-2025 | Barèmes IPP ; article 83 du CGI |
| `prelevements_sociaux` | CSG, CRDS et plafond de la Sécurité sociale, 1979-2025 | Barèmes IPP ; instruction n° 91-52-M9 |
| `cotisations_salariales` | Cotisations salariales des non-cadres et des cadres, 1979-2025 | Barèmes IPP |
| `smic` | SMIC de référence à 35 heures, 1979-2025 | Barèmes IPP |
| `ppe` | Paramètres de la prime pour l'emploi, revenus 2000-2016 | Barèmes IPP |
| `prestations_activite` | RSA activité, prime d'activité, SMIC horaire et BMAF, par mois, 2009-2025 | Barèmes IPP |
| `ipc` | Indice des prix à la consommation, 1901-2025 (base 2025) | INSEE, via DBnomics |

Quand un paramètre n'a pas changé une année donnée, la dernière valeur en vigueur s'applique.

Les **Barèmes IPP** sont produits par l'[Institut des politiques publiques](https://www.ipp.eu/) et diffusés sous [Licence Ouverte / Open Licence](https://www.etalab.gouv.fr/licence-ouverte-open-licence/) ([fiche data.gouv.fr](https://www.data.gouv.fr/datasets/baremes-ipp-systeme-social-et-fiscal-francais)), téléchargés en octobre 2026.

Les paramètres absents des Barèmes IPP, ou corrigés, ont été ajoutés à partir des textes officiels :

- barème des revenus 2024 : loi n° 2025-127 du 14 février 2025, art. 2 (article 197 du CGI) ;
- barème, décote et plafonnement du quotient familial des revenus 2025 : loi n° 2026-103 du 19 février 2026, art. 4 (article 197 du CGI) ;
- déduction pour frais professionnels des revenus 2025 (minimum 509 €, plafond 14 555 €) : article 83, 3° du CGI ;
- décote des revenus 1981-2000 : versions successives de l'article 197 du CGI et BOI 5 B-9-01 ;
- abattement de 5 % sur l'assiette de la CSG (1991-1997) : instruction n° 91-52-M9 du 17 avril 1991.

L'**indice des prix** est la série INSEE « Coefficient de transformation de l'euro ou du franc d'une année en euro ou en franc d'une autre année - Base 2025 ». Ses valeurs anciennes sont arrondies à deux décimales, soit une imprécision d'au plus 0,5 % dès 1945.

Le **SMIC de référence** est le SMIC horaire brut multiplié par 151,67 heures par mois, pour toutes les années. Cette convention neutralise les changements de durée légale du travail (40, 39 puis 35 heures) et les garanties mensuelles de rémunération de 2000-2005 ; avant 2002, un salarié au SMIC à temps plein gagnait environ 11 % de plus.

Si vous utilisez ces données, merci de citer l'IPP et l'INSEE. Les scripts de nettoyage sont disponibles dans `data-raw/`.

## Feuille de route

- [x] Barème de l'impôt sur le revenu, 1945-2025
- [x] Décote (revenus 1981-2025)
- [x] Conversion en euros constants
- [x] Comparaison à salaire égal (abattements de 10 % et de 20 %, revenus 1979 et après)
- [x] Plafonnement général du quotient familial (revenus 1981-2025)
- [x] Cotisations salariales, CSG et CRDS (1979-2025), non-cadres et cadres
- [x] Prime pour l'emploi, RSA activité et prime d'activité
- [ ] Plafonds spécifiques du quotient familial (parent isolé, invalidité)
- [ ] Décote avant 1981
- [ ] Abattements sur salaires avant 1979
- [ ] Cotisations patronales et allègements de charges
- [ ] Aides au logement et prestations familiales

Les contributions sont bienvenues : ouvrez une *issue* ou une *pull request*.
