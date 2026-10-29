# Working paper : prélèvements sur les salaires, 1981-2025
# 01 - Calcul du panel des cas types
devtools::load_all()
library(dplyr)
library(ggplot2)

cas_types <- tibble::tribble(
  ~cas, ~libelle,                              ~k1, ~k2, ~parts, ~couple,
  "A",  "Célibataire, 1 SMIC",                 1,   0,   1,      FALSE,
  "B",  "Célibataire, 2 SMIC",                 2,   0,   1,      FALSE,
  "C",  "Célibataire, 5 SMIC",                 5,   0,   1,      FALSE,
  "D",  "Couple 1,5 + 1 SMIC, 2 enfants",      1.5, 1,   3,      TRUE,
  "E",  "Couple 3 + 2 SMIC, 2 enfants",        3,   2,   3,      TRUE
)

annees <- 1981:2025   # période où tous les paramètres sont disponibles
montants <- c("brut", "cotisations", "csg", "crds", "net_imposable", "impot",
              "net_apres_impot")

panel <- do.call(rbind, lapply(annees, function(a) {
  s <- smic$smic_annuel[smic$annee == a]
  do.call(rbind, lapply(seq_len(nrow(cas_types)), function(i) {
    ct <- cas_types[i, ]
    r <- prelevements_salaire(ct$k1 * s, annee = a, brut2 = ct$k2 * s,
                              parts = ct$parts, couple = ct$couple,
                              decote = TRUE, plafonnement = TRUE)
    r[montants] <- en_euros_constants(r[montants], a)      # en euros de 2025
    data.frame(annee = a, cas = ct$cas, libelle = ct$libelle, r)
  }))
}))

saveRDS(panel, "working-paper/panel_cas_types.rds")

# Figure 1 : taux de prélèvement total par cas type
fig1 <- ggplot(panel, aes(annee, 100 * taux_prelevements, colour = libelle)) +
  geom_line(linewidth = 0.9) +
  labs(x = NULL, y = "Part du salaire brut prélevée (%)", colour = NULL,
       title = "Prélèvements sur le salaire (cotisations, CSG-CRDS, impôt sur le revenu)",
       caption = "Source : Barèmes IPP, calculs avec le package baremesipp.") +
  theme_minimal() +
  theme(legend.position = "bottom", legend.direction = "vertical")

ggsave("working-paper/fig1_taux_total.png", fig1, width = 8, height = 6, dpi = 200)
fig1
