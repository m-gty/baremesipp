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

# Variante : cas A et D nets des aides aux bas salaires (PPE, RSA activité, prime d'activité)
montants_aides <- c("brut", "cotisations", "csg", "crds", "net_imposable", "impot", "ppe",
                    "rsa_activite", "prime_activite", "net_apres_impot")
panel_aides <- do.call(rbind, lapply(annees, function(a) {
  s <- smic$smic_annuel[smic$annee == a]
  rA <- prelevements_salaire(s, annee = a, decote = TRUE, plafonnement = TRUE, aides = TRUE)
  rD <- prelevements_salaire(1.5 * s, annee = a, brut2 = s, parts = 3, couple = TRUE,
                             decote = TRUE, plafonnement = TRUE,
                             aides = TRUE, personnes_charge = 2)
  rA[montants_aides] <- en_euros_constants(rA[montants_aides], a)
  rD[montants_aides] <- en_euros_constants(rD[montants_aides], a)
  rbind(data.frame(annee = a, cas = "A", libelle = "Célibataire, 1 SMIC (net des aides)", rA),
        data.frame(annee = a, cas = "D", libelle = "Couple 1,5 + 1 SMIC, 2 enfants (net des aides)", rD))
}))
saveRDS(panel_aides, "working-paper/panel_A_aides.rds")

saveRDS(panel, "working-paper/panel_cas_types.rds")

# Figure 1 : taux de prélèvement total par cas type, avec la variante nette des aides
niveaux <- c(cas_types$libelle, "Célibataire, 1 SMIC (net des aides)",
             "Couple 1,5 + 1 SMIC, 2 enfants (net des aides)")
donnees_fig1 <- bind_rows(panel, panel_aides) |>
  mutate(libelle = factor(libelle, levels = niveaux))
couleurs <- c("#F8766D", "#A3A500", "#00BF7D", "#00B0F6", "#E76BF3", "#F8766D", "#00B0F6")
traits   <- c(rep("solid", 5), "dashed", "dashed")
names(couleurs) <- niveaux
names(traits)   <- niveaux

fig1 <- ggplot(donnees_fig1, aes(annee, 100 * taux_prelevements,
                                 colour = libelle, linetype = libelle)) +
  geom_line(linewidth = 0.9) +
  scale_colour_manual(values = couleurs) +
  scale_linetype_manual(values = traits) +
  labs(x = NULL, y = "Part du salaire brut prélevée (%)", colour = NULL, linetype = NULL,
       title = "Prélèvements sur le salaire (cotisations, CSG-CRDS, impôt sur le revenu)",
       subtitle = "Variante nette des aides : PPE, RSA activité et prime d'activité",
       caption = "Source : Barèmes IPP, calculs avec le package baremesipp.") +
  theme_minimal() +
  theme(legend.position = "bottom", legend.direction = "vertical",
        legend.key.width = unit(1.5, "cm"))

ggsave("working-paper/fig1_taux_total.png", fig1, width = 8, height = 6.5, dpi = 200)
fig1
