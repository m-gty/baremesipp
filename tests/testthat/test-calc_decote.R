test_that("la décote moderne est correcte (calculs à la main)", {
  # 2024, célibataire, 20 000 : impôt brut 935,33 ; décote 889 - 0,4525 x 935,33
  expect_equal(calc_ir(20000, annee = 2024, decote = TRUE), 469.57, tolerance = 0.01)
  # 2025, couple, 40 000 sur 2 parts : brut 1 848 ; décote 1 483 - 0,4525 x 1 848
  expect_equal(calc_ir(40000, parts = 2, annee = 2025, couple = TRUE, decote = TRUE),
               1201.22, tolerance = 0.01)
})

test_that("l'ancien régime (2001-2013) est correct", {
  # 2010, célibataire, 15 000 : brut 760,875 ; décote 439 - 0,5 x 760,875
  expect_equal(calc_ir(15000, annee = 2010, decote = TRUE), 702.31, tolerance = 0.01)
})

test_that("la décote ne rend jamais l'impôt négatif", {
  expect_equal(calc_ir(12000, annee = 2024, decote = TRUE), 0)
})

test_that("la décote avant 2001 renvoie une erreur", {
  expect_error(calc_ir(30000, annee = 1995, decote = TRUE))
})
