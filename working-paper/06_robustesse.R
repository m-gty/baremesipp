# Working paper : prélèvements sur les salaires, 1981-2025
# 06 - Robustesse : SMIC à 169 heures (39 h) avant 2002 au lieu de 151,67 heures
devtools::load_all()
library(dplyr)
library(tidyr)

annees <- c(1981, 1990, 1997, 2000, 2001)

# SMIC de référence selon la convention retenue
smic_conv <- function(a, convention) {
  s <- smic$smic_annuel[smic$annee == a]
  if (convention == "169 h" && a < 2002) s * 169 / 151.67 else s
}

cas <- tibble::tribble(
  ~cas, ~k1, ~k2, ~parts, ~couple, ~cadre1, ~cadre2,
  "A",  1,   0,   1,      FALSE,   FALSE,   FALSE,
  "B",  2,   0,   1,      FALSE,   FALSE,   FALSE,
  "C",  5,   0,   1,      FALSE,   TRUE,    FALSE,
  "D",  1.5, 1,   3,      TRUE,    FALSE,   FALSE
)

rob <- do.call(rbind, lapply(c("151,67 h", "169 h"), function(conv) {
  do.call(rbind, lapply(annees, function(a) {
    s <- smic_conv(a, conv)
    do.call(rbind, lapply(seq_len(nrow(cas)), function(i) {
      ct <- cas[i, ]
      r <- prelevements_salaire(ct$k1 * s, annee = a, brut2 = ct$k2 * s,
                                parts = ct$parts, couple = ct$couple,
                                decote = TRUE, plafonnement = TRUE,
                                cadre = ct$cadre1, cadre2 = ct$cadre2)
      ra <- if (ct$cas == "A") prelevements_salaire(s, annee = a, decote = TRUE,
                                                    plafonnement = TRUE, aides = TRUE) else r
      data.frame(convention = conv, annee = a, cas = ct$cas,
                 taux = 100 * r$taux_prelevements,
                 taux_aides = 100 * ra$taux_prelevements)
    }))
  }))
}))

# 1. Taux de prélèvement par cas type, selon la convention
rob |>
  select(convention, annee, cas, taux) |>
  mutate(taux = round(taux, 1)) |>
  pivot_wider(names_from = cas, values_from = taux) |>
  arrange(annee, convention) |>
  print(n = Inf)

# 2. Écart de taux entre C et A (hors aides et aides comprises)
rob |>
  select(convention, annee, cas, taux, taux_aides) |>
  filter(cas %in% c("A", "C")) |>
  pivot_wider(names_from = cas, values_from = c(taux, taux_aides)) |>
  transmute(convention, annee,
            ecart_hors_aides = round(taux_C - taux_A, 1),
            ecart_aides      = round(taux_C - taux_aides_A, 1)) |>
  arrange(annee, convention) |>
  print(n = Inf)
