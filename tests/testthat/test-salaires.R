test_that("la déduction de 10 % est correcte", {
  expect_equal(revenu_imposable_salaire(22223, annee = 2024), 20000.7)
})

test_that("le minimum et le plafond de la déduction s'appliquent", {
  expect_equal(revenu_imposable_salaire(3000, annee = 2024), 3000 - 504)
  expect_equal(revenu_imposable_salaire(200000, annee = 2024), 200000 - 14426)
})

test_that("la déduction ne dépasse jamais le salaire", {
  expect_equal(revenu_imposable_salaire(300, annee = 2024), 0)
})

test_that("l'abattement de 20 % s'applique avant 2006", {
  # 20 000 - 10 % = 18 000 ; 18 000 - 20 % = 14 400
  expect_equal(revenu_imposable_salaire(20000, annee = 2005), 14400)
})

test_that("les salaires d'avant 1979 renvoient une erreur", {
  expect_error(revenu_imposable_salaire(20000, annee = 1970))
})

test_that("calc_ir_salaire est cohérent avec calc_ir", {
  expect_equal(calc_ir_salaire(22223, annee = 2024),
               calc_ir(20000.7, annee = 2024))
})
