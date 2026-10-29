# Working paper : prélèvements sur les salaires, 1981-2025
# 01 - Calcul du panel des cas types
devtools::load_all()
library(dplyr)
library(ggplot2)

cas_types <- tibble::tribble(
  ~cas, ~libelle,                              ~k1, ~k2, ~parts, ~couple, ~cadre1, ~cadre2,
  "A",  "Célibataire, 1 SMIC",                 1,   0,   1,      FALSE,   FALSE,   FALSE,
  "B",  "Célibataire, 2 SMIC",                 2,   0,   1,      FALSE,   FALSE,   FALSE,
  "C",  "Célibataire cadre, 5 SMIC",           5,   0,   1,      FALSE,   TRUE,    FALSE,
  "D",  "Couple 1,5 + 1 SMIC, 2 enfants",      1.5, 1,   3,      TRUE,    FALSE,   FALSE,
  "E",  "Couple 3 + 2 SMIC, 2 enfants",        3,   2,   3,      TRUE,    TRUE,    FALSE
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
                              decote = TRUE, plafonnement = TRUE,
                              cadre = ct$cadre1, cadre2 = ct$cadre2)
    r[montants] <- en_euros_constants(r[montants], a)      # en euros de 2025
    data.frame(annee = a, cas = ct$cas, libelle = ct$libelle, r)
  }))
}))

# Variante : cas A net des aides aux bas salaires (PPE, RSA activité, prime d'activité)
panel_aides <- do.call(rbind, lapply(annees, function(a) {
  s <- smic$smic_annuel[smic$annee == a]
  r <- prelevements_salaire(s, annee = a, decote = TRUE, plafonnement = TRUE, aides = TRUE)
  r[c("brut", "cotisations", "csg", "crds", "net_imposable", "impot", "ppe",
      "rsa_activite", "prime_activite", "net_apres_impot")] <-
    en_euros_constants(r[c("brut", "cotisations", "csg", "crds", "net_imposable", "impot",
                           "ppe", "rsa_activite", "prime_activite", "net_apres_impot")], a)
  data.frame(annee = a, cas = "A", libelle = "Célibataire, 1 SMIC (net des aides)", r)
}))
saveRDS(panel_aides, "working-paper/panel_A_aides.rds")

saveRDS(panel, "working-paper/panel_cas_types.rds")

# Figure 1 : taux de prélèvement total par cas type
fig1 <- ggplot(panel, aes(annee, 100 * taux_prelevements, colour = libelle)) +
  geom_line(linewidth = 0.9) +
  geom_line(data = panel_aides, aes(annee, 100 * taux_prelevements),
            colour = "grey30", linetype = "dashed", linewidth = 0.8, inherit.aes = FALSE) +
  labs(x = NULL, y = "Part du salaire brut prélevée (%)", colour = NULL,
       title = "Prélèvements sur le salaire (cotisations, CSG-CRDS, impôt sur le revenu)",
       subtitle = "Pointillés : célibataire au SMIC, net de la PPE, du RSA activité et de la prime d'activité",
       caption = "Source : Barèmes IPP, calculs avec le package baremesipp.") +
  theme_minimal() +
  theme(legend.position = "bottom", legend.direction = "vertical")

ggsave("working-paper/fig1_taux_total.png", fig1, width = 8, height = 6, dpi = 200)
fig1
