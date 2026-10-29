# Working paper : prélèvements sur les salaires, 1981-2025
# 02 - Décomposition des prélèvements (cotisations, CSG-CRDS, impôt sur le revenu)
library(dplyr)
library(tidyr)
library(ggplot2)

panel <- readRDS("working-paper/panel_cas_types.rds")

composantes <- c("Cotisations salariales", "CSG et CRDS", "Impôt sur le revenu")

decomp <- panel |>
  mutate(`Cotisations salariales` = 100 * cotisations / brut,
         `CSG et CRDS`            = 100 * (csg + crds) / brut,
         `Impôt sur le revenu`    = 100 * impot / brut) |>
  select(annee, cas, libelle, all_of(composantes)) |>
  pivot_longer(all_of(composantes), names_to = "prelevement", values_to = "part") |>
  mutate(prelevement = factor(prelevement, levels = rev(composantes)))

# Principales réformes, pour repérer les ruptures
reformes <- data.frame(
  annee = c(1991, 1998, 2006, 2018),
  label = c("Création\nCSG", "Maladie\n\u2192 CSG", "Réforme\nIR", "Chômage\n\u2192 CSG"),
  y     = c(32, 25, 32, 25),           # deux hauteurs en alternance
  hjust = c(0, 0, 0, 1)                # à droite du trait, sauf 2018 (à gauche)
)

# Figure 2 : décomposition pour le cas B (célibataire à 2 SMIC)
fig2 <- ggplot(filter(decomp, cas == "B"), aes(annee, part, fill = prelevement)) +
  geom_area(colour = "white", linewidth = 0.2) +
  geom_vline(data = reformes, aes(xintercept = annee), linetype = "dashed",
             colour = "grey30") +
  geom_label(data = reformes, aes(x = annee, y = y, label = label, hjust = hjust),
             inherit.aes = FALSE, size = 2.6, vjust = 1, fill = "white",
             linewidth = 0, label.padding = unit(0.15, "lines")) +
  scale_y_continuous(limits = c(0, 33)) +
  labs(x = NULL, y = "Part du salaire brut (%)", fill = NULL,
       title = "Décomposition des prélèvements : célibataire à 2 SMIC",
       caption = "Source : Barèmes IPP, calculs avec le package baremesipp.") +
  theme_minimal() +
  theme(legend.position = "bottom")

ggsave("working-paper/fig2_decomposition_B.png", fig2, width = 8, height = 6, dpi = 200)
fig2

# Variante : les cinq cas types côte à côte
fig2_tous <- ggplot(decomp, aes(annee, part, fill = prelevement)) +
  geom_area(colour = "white", linewidth = 0.1) +
  facet_wrap(~ libelle, ncol = 2) +
  labs(x = NULL, y = "Part du salaire brut (%)", fill = NULL,
       title = "Décomposition des prélèvements par cas type",
       caption = "Source : Barèmes IPP, calculs avec le package baremesipp.") +
  theme_minimal() +
  theme(legend.position = "bottom")

ggsave("working-paper/fig2_decomposition_tous.png", fig2_tous, width = 9, height = 10, dpi = 200)

# Tableau chiffré pour le cas B
decomp |>
  filter(cas == "B", annee %in% c(1981, 1990, 1997, 1998, 2005, 2006, 2017, 2018, 2025)) |>
  mutate(part = round(part, 1)) |>
  select(annee, prelevement, part) |>
  pivot_wider(names_from = prelevement, values_from = part)
