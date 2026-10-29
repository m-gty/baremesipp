test_that("le plafonnement s'applique aux hauts revenus", {
  # Couple, 2 enfants (3 parts), 100 000 euros en 2025
  # Impôt à 3 parts : 9 311,97 ; à 2 parts : 16 207,98 ; avantage 6 896 > 2 x 1 807
  # Impôt plafonné : 16 207,98 - 3 614 = 12 593,98
  expect_equal(calc_ir(100000, parts = 3, annee = 2025, couple = TRUE,
                       plafonnement = TRUE),
               12593.98, tolerance = 1e-4)
})

test_that("le plafonnement ne change rien quand l'avantage est sous le plafond", {
  # 50 000 euros, 3 parts : avantage de 1 276 < 3 614
  expect_equal(calc_ir(50000, parts = 3, annee = 2025, couple = TRUE, plafonnement = TRUE),
               calc_ir(50000, parts = 3, annee = 2025, couple = TRUE))
})

test_that("le plafonnement ne change rien sans demi-part supplémentaire", {
  expect_equal(calc_ir(100000, parts = 2, annee = 2025, couple = TRUE, plafonnement = TRUE),
               calc_ir(100000, parts = 2, annee = 2025, couple = TRUE))
})

test_that("le plafonnement avant 1981 renvoie une erreur", {
  expect_error(calc_ir(100000, parts = 3, annee = 1975, couple = TRUE, plafonnement = TRUE))
})
