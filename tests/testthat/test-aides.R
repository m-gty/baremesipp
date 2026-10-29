test_that("pas d'aide hors de leurs périodes d'existence", {
  expect_equal(calc_rsa_activite(12000, 2005), 0)
  expect_equal(calc_rsa_activite(12000, 2018), 0)
  expect_equal(calc_prime_activite(12000, 2012), 0)
})

test_that("pas de prime d'activité pour un salaire élevé", {
  expect_equal(calc_prime_activite(60000, 2025), 0)
})

test_that("la prime d'activité au SMIC est positive et a augmenté en 2019", {
  pa_2018 <- calc_prime_activite(13500, 2018)
  pa_2019 <- calc_prime_activite(13500, 2019)
  expect_gt(pa_2018, 0)
  expect_gt(pa_2019, pa_2018)
})

test_that("la prime d'activité suit la formule (mois sans bonification)", {
  # Avril 2025 seul : salaire mensuel de 500 euros, sous le seuil de bonification
  p <- baremesipp::prestations_activite
  p <- p[p$annee == 2025 & p$mois == 4, ]
  attendu <- p$pa_mf + p$pa_taux * 500 - p$pa_mf     # max(500, mf) = mf
  expect_equal(attendu, p$pa_taux * 500)
  expect_lt(500, p$pa_bonif_seuil * p$smic_horaire)  # bien sous le seuil
})

test_that("les majorations selon la composition du foyer sont correctes", {
  expect_equal(baremesipp:::coef_foyer(FALSE, 0), 1)
  expect_equal(baremesipp:::coef_foyer(TRUE, 2), 2.1)     # couple, 2 enfants
  expect_equal(baremesipp:::coef_foyer(FALSE, 3), 2.2)    # seul, 3 enfants
})

test_that("pas de prime d'activité pour un couple aisé avec enfants", {
  expect_equal(calc_prime_activite(60000, 2025, net2 = 40000, couple = TRUE, enfants = 2), 0)
})
