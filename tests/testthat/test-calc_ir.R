test_that("calc_ir reproduit des cas calculés à la main", {
  expect_equal(calc_ir(30000, parts = 1, annee = 2023), 2286.23)
  expect_equal(calc_ir(20000, parts = 1, annee = 2023), 957.66)
  expect_equal(calc_ir(100000, parts = 1, annee = 2023), 25228.72)
})

test_that("un revenu sous le premier seuil ne paie rien", {
  expect_equal(calc_ir(10000, parts = 1, annee = 2023), 0)
})

test_that("le quotient familial fonctionne", {
  expect_equal(calc_ir(60000, parts = 2, annee = 2023),
               2 * calc_ir(30000, parts = 1, annee = 2023))
})

test_that("une année sans nouveau barème reprend le précédent", {
  expect_equal(calc_ir(30000, annee = 2011), calc_ir(30000, annee = 2010))
})

test_that("une année hors période renvoie une erreur", {
  expect_error(calc_ir(30000, annee = 2030))
  expect_error(calc_ir(30000, annee = 1900))
})

test_that("les barèmes ajoutés depuis les lois de finances sont corrects", {
  expect_equal(calc_ir(30000, annee = 2024), 2165.48)
  expect_equal(calc_ir(30000, annee = 2025), 2103.99)
})

test_that("plusieurs revenus donnent plusieurs résultats", {
  expect_length(calc_ir(c(20000, 50000, 100000), annee = 2023), 3)
})

