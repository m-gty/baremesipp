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

test_that("le régime 1986-1999 est correct (décote = seuil - impôt)", {
  # 1999 : seuil 3 350 F ; impôt 2 000 F -> décote 1 350 -> impôt 650 F
  expect_equal(calc_decote(2000, annee = 1999), 1350)
})

test_that("le régime de 2000 est correct (décote = seuil - impôt / 2)", {
  # 2000 : seuil 2 450 F ; impôt 3 000 F -> décote 950 -> impôt 2 050 F
  expect_equal(calc_decote(3000, annee = 2000), 950)
})

test_that("le régime 1981-1985 est correct (1 et 1,5 part seulement)", {
  # 1983 : seuils de 3 700 F (1 part) et 1 400 F (1,5 part)
  expect_equal(calc_decote(2000, annee = 1983, parts = 1), 1700)
  expect_equal(calc_decote(1000, annee = 1983, parts = 1.5), 400)
  expect_equal(calc_decote(1000, annee = 1983, parts = 2), 0)
})

test_that("la décote avant 1981 renvoie une erreur", {
  expect_error(calc_ir(30000, annee = 1980, decote = TRUE))
})
