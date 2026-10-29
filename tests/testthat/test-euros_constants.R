test_that("la conversion est neutre pour l'année de référence", {
  expect_equal(en_euros_constants(100, annee = 2025), 100)
})

test_that("le passage franc -> euro est correct", {
  expect_equal(en_euros_constants(6.55957, annee = 2000, annee_ref = 2000), 1)
})

test_that("le passage ancien franc -> franc est correct", {
  expect_equal(en_euros_constants(655.957, annee = 1955, annee_ref = 1955), 1)
})

test_that("calc_ir_constant est neutre pour l'année de référence", {
  expect_equal(calc_ir_constant(30000, annee = 2025), calc_ir(30000, annee = 2025))
})

test_that("calc_ir_constant est correct (calcul à la main)", {
  # 30 000 euros 2025 = 29 136 euros 2023 ; impôt 2023 = 2 027,03 ; /0,9712
  expect_equal(calc_ir_constant(30000, annee = 2023), 2087.14, tolerance = 1e-4)
})
