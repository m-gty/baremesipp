# Working paper : prélèvements sur les salaires, 1981-2025
# 03 - Progressivité : décomposition de l'écart de taux entre 5 SMIC et 1 SMIC
library(dplyr)
library(tidyr)
library(ggplot2)

panel <- readRDS("working-paper/panel_cas_types.rds")

taux <- panel |>
  filter(cas %in% c("A", "C")) |>
  mutate(`Cotisations salariales` = 100 * cotisations / brut,
         `CSG et CRDS`            = 100 * (csg + crds) / brut,
         `Impôt sur le revenu`    = 100 * impot / brut,
         `Total`                  = 100 * taux_prelevements) |>
  select(annee, cas, `Cotisations salariales`, `CSG et CRDS`, `Impôt sur le revenu`, Total) |>
  pivot_longer(-c(annee, cas), names_to = "prelevement", values_to = "taux") |>
  pivot_wider(names_from = cas, values_from = taux) |>
  mutate(ecart = C - A,
         prelevement = factor(prelevement, levels = c("Total", "Impôt sur le revenu",
                                                      "CSG et CRDS", "Cotisations salariales")))

# Figure 3 : contribution de chaque prélèvement à l'écart de taux entre 5 SMIC et 1 SMIC
fig3 <- ggplot(taux, aes(annee, ecart, colour = prelevement, linewidth = prelevement)) +
  geom_hline(yintercept = 0, colour = "grey50") +
  geom_line() +
  scale_linewidth_manual(values = c(1.4, 0.9, 0.9, 0.9), guide = "none") +
  scale_colour_manual(values = c("black", "#F8766D", "#00BA38", "#619CFF")) +
  labs(x = NULL, y = "Écart de taux, 5 SMIC moins 1 SMIC (points de %)", colour = NULL,
       title = "D'où vient la progressivité des prélèvements sur le salaire ?",
       subtitle = "Célibataires à 5 SMIC et à 1 SMIC ; une valeur positive indique un prélèvement progressif",
       caption = "Source : Barèmes IPP, calculs avec le package baremesipp.") +
  theme_minimal() +
  theme(legend.position = "bottom")

ggsave("working-paper/fig3_progressivite.png", fig3, width = 8, height = 6, dpi = 200)
fig3

# Tableau chiffré
taux |>
  filter(annee %in% c(1981, 1990, 1997, 1998, 2006, 2013, 2018, 2025)) |>
  mutate(ecart = round(ecart, 1)) |>
  select(annee, prelevement, ecart) |>
  pivot_wider(names_from = prelevement, values_from = ecart)

# Variante : écart total avec le SMIC net des aides
panel_aides <- readRDS("working-paper/panel_A_aides.rds") |> filter(cas == "A")
ecart_aides <- panel |>
  filter(cas == "C") |>
  select(annee, taux_C = taux_prelevements) |>
  left_join(select(panel_aides, annee, taux_A = taux_prelevements), by = "annee") |>
  mutate(ecart = 100 * (taux_C - taux_A))

ecart_aides |>
  filter(annee %in% c(1981, 2000, 2006, 2010, 2016, 2019, 2025)) |>
  mutate(across(c(taux_C, taux_A), \(x) round(100 * x, 1)), ecart = round(ecart, 1))
