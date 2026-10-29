test_that("la phase d'entrée est correcte", {
  # 2007, 10 000 euros : 7,7 % x 10 000 = 770
  expect_equal(calc_ppe(10000, rfr = 9000, annee = 2007), 770)
})

test_that("la phase de sortie est correcte", {
  # 2007, 15 000 euros : 19,3 % x (17 451 - 15 000) = 473,04
  expect_equal(calc_ppe(15000, rfr = 13500, annee = 2007), 473.043, tolerance = 1e-6)
})

test_that("les paramètres de 2007 s'appliquent jusqu'en 2015", {
  expect_equal(calc_ppe(10000, rfr = 9000, annee = 2012),
               calc_ppe(10000, rfr = 9000, annee = 2007))
})

test_that("pas de prime hors période ni au-dessus de la condition de ressources", {
  expect_equal(calc_ppe(10000, rfr = 9000, annee = 2018), 0)
  expect_equal(calc_ppe(10000, rfr = 20000, annee = 2007), 0)
})
