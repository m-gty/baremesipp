# baremesipp 0.2.0

# baremesipp 0.1.0

Première version publique.

## Données

* `bareme_ir` : barème de l'impôt sur le revenu, revenus 1945-2025.
* `decote` : paramètres de la décote, revenus 1950-2025.
* `plafonnement_qf` : plafonds du quotient familial, revenus 1974-2025.
* `abattements_salaires` : déduction de 10 % et abattement de 20 % sur les salaires.
* `ipc` : indice des prix à la consommation de l'INSEE, 1901-2025 (base 2025).
* Paramètres des revenus 2024 et 2025 ajoutés à partir du Code général des impôts.

## Fonctions

* `calc_ir()` : impôt issu du barème, avec quotient familial, plafonnement (1981-2025) et décote (2001-2025).
* `calc_decote()` : montant de la décote.
* `revenu_imposable_salaire()` et `calc_ir_salaire()` : passage du salaire déclaré au revenu imposable (1979-2025).
* `en_euros_constants()` : conversion en euros constants, avec les changements de monnaie.
* `calc_ir_constant()` : impôt sous les règles d'une autre année, en euros constants.
