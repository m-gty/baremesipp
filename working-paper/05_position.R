# Working paper : prélèvements sur les salaires, 1981-2025
# 05 - Effet de position : position relative constante vs salaire réel constant
devtools::load_all()
library(dplyr)
library(tidyr)
library(ggplot2)

smic_2025 <- smic$smic_annuel[smic$annee == 2025]

position <- do.call(rbind, lapply(1981:2025, function(a) {
  s <- smic$smic_annuel[smic$annee == a]
  relatif <- prelevements_salaire(2 * s, annee = a, decote = TRUE, plafonnement = TRUE)
  reel    <- prelevements_salaire_constant(2 * smic_2025, annee = a,
                                           decote = TRUE, plafonnement = TRUE)
  rbind(
    data.frame(annee = a, approche = "Position relative constante (2 SMIC de l'année)",
               brut_2025 = en_euros_constants(2 * s, a),
               taux_ir = 100 * relatif$impot / relatif$brut,
               taux_total = 100 * relatif$taux_prelevements),
    data.frame(annee = a, approche = "Salaire réel constant (2 SMIC de 2025)",
               brut_2025 = reel$brut,
               taux_ir = 100 * reel$impot / reel$brut,
               taux_total = 100 * reel$taux_prelevements)
  )
}))

saveRDS(position, "working-paper/position.rds")

# Figure 5
fig5 <- position |>
  select(annee, approche, `Impôt sur le revenu` = taux_ir, `Total des prélèvements` = taux_total) |>
  pivot_longer(-c(annee, approche), names_to = "mesure", values_to = "taux") |>
  ggplot(aes(annee, taux, colour = approche)) +
  geom_line(linewidth = 0.9) +
  facet_wrap(~ mesure, ncol = 1, scales = "free_y") +
  scale_colour_manual(values = c("#619CFF", "#F8766D")) +
  labs(x = NULL, y = "Part du salaire brut (%)", colour = NULL,
       title = "Règles ou position ? Deux façons de suivre un célibataire dans le temps",
       subtitle = "Les deux approches coïncident en 2025 ; leur écart passé mesure l'effet de position",
       caption = "Source : Barèmes IPP, calculs avec le package baremesipp.") +
  theme_minimal() +
  theme(legend.position = "bottom", legend.direction = "vertical")

ggsave("working-paper/fig5_position.png", fig5, width = 8, height = 7, dpi = 200)
fig5

# Tableau chiffré
position |>
  filter(annee %in% c(1981, 1990, 2000, 2010, 2025)) |>
  mutate(across(c(brut_2025, taux_ir, taux_total), \(x) round(x, 1)),
         approche = ifelse(grepl("relative", approche), "relatif", "reel")) |>
  pivot_wider(names_from = approche, values_from = c(brut_2025, taux_ir, taux_total)) |>
  tibble::as_tibble() |>
  print(width = Inf)
