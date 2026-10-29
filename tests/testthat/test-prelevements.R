test_that("les cotisations 2025 sous le plafond sont correctes", {
  # 30 000 : vieillesse 7,3 % + AGIRC-ARRCO 3,15 % + CEG 0,86 % = 11,31 %
  expect_equal(baremesipp:::montant_cotisations(30000, 2025), 3393, tolerance = 1e-6)
})

test_that("les cotisations au-dessus du plafond sont correctes (avec CET)", {
  # 60 000 en 2025, PSS = 47 100
  expect_equal(baremesipp:::montant_cotisations(60000, 2025), 6716.49, tolerance = 1e-6)
})

test_that("la CSG et la CRDS 2025 sont correctes", {
  cc <- baremesipp:::montant_csg_crds(30000, 2025)
  expect_equal(cc$csg, 0.092 * 30000 * 0.9825)
  expect_equal(cc$csg_deductible, 0.068 * 30000 * 0.9825)
  expect_equal(cc$crds, 0.005 * 30000 * 0.9825)
})

test_that("le salaire net imposable 2025 est correct", {
  # 30 000 - 3 393 - 2 004,30 = 24 602,70
  expect_equal(prelevements_salaire(30000, annee = 2025)$net_imposable,
               24602.7, tolerance = 1e-6)
})

test_that("les éléments du salaire s'additionnent", {
  r <- prelevements_salaire(50000, annee = 2010)
  expect_equal(r$brut, r$cotisations + r$csg + r$crds + r$impot + r$net_apres_impot)
})

test_that("les prélèvements en euros constants sont neutres pour 2025", {
  expect_equal(prelevements_salaire_constant(30000, annee = 2025),
               prelevements_salaire(30000, annee = 2025))
})
