# Working paper : prélèvements sur les salaires, 1981-2025
# 04 - Familles : avantage fiscal procuré par deux enfants et effet du plafonnement
devtools::load_all()
library(dplyr)
library(tidyr)
library(ggplot2)

couples <- tibble::tribble(
  ~cas, ~libelle,                           ~k1, ~k2, ~cadre1, ~cadre2,
  "D",  "Couple 1,5 + 1 SMIC",              1.5, 1,   FALSE,   FALSE,
  "E",  "Couple 3 + 2 SMIC",                3,   2,   TRUE,    FALSE,
  "F",  "Couple 5 + 3 SMIC",                5,   3,   TRUE,    TRUE
)

familles <- do.call(rbind, lapply(1981:2025, function(a) {
  s <- smic$smic_annuel[smic$annee == a]
  do.call(rbind, lapply(seq_len(nrow(couples)), function(i) {
    ct <- couples[i, ]
    impot <- function(parts, plafonnement) {
      prelevements_salaire(ct$k1 * s, annee = a, brut2 = ct$k2 * s, parts = parts,
                           couple = TRUE, decote = TRUE,
                           plafonnement = plafonnement,
                           cadre = ct$cadre1, cadre2 = ct$cadre2)$impot
    }
    data.frame(annee = a, cas = ct$cas, libelle = ct$libelle,
               sans_enfant        = en_euros_constants(impot(2, TRUE), a),
               avec_enfants       = en_euros_constants(impot(3, TRUE), a),
               avec_enfants_sans_plafond = en_euros_constants(impot(3, FALSE), a))
  }))
})) |>
  mutate(`Avantage effectif`          = sans_enfant - avec_enfants,
         `Avantage sans plafonnement` = sans_enfant - avec_enfants_sans_plafond,
         libelle = factor(libelle, levels = couples$libelle))

saveRDS(familles, "working-paper/familles.rds")

reformes <- data.frame(annee = c(1998, 2012, 2013),
                       label = c("1998", "2012", "2013"))

# Figure 4
fig4 <- familles |>
  select(annee, libelle, `Avantage effectif`, `Avantage sans plafonnement`) |>
  pivot_longer(-c(annee, libelle), names_to = "mesure", values_to = "montant") |>
  ggplot(aes(annee, montant, colour = mesure, linetype = mesure)) +
  geom_vline(data = reformes, aes(xintercept = annee), colour = "grey70") +
  geom_line(linewidth = 0.9) +
  facet_wrap(~ libelle, ncol = 1, scales = "free_y") +
  scale_colour_manual(values = c("#00BA38", "grey40")) +
  scale_linetype_manual(values = c("solid", "dashed")) +
  labs(x = NULL, y = "Réduction d'impôt sur le revenu (euros de 2025 par an)",
       colour = NULL, linetype = NULL,
       title = "Ce que deux enfants font économiser d'impôt sur le revenu",
       subtitle = "Écart entre l'avantage sans plafonnement et l'avantage effectif : effet du plafonnement du quotient familial",
       caption = "Source : Barèmes IPP, calculs avec le package baremesipp.") +
  theme_minimal() +
  theme(legend.position = "bottom")

ggsave("working-paper/fig4_familles.png", fig4, width = 8, height = 9, dpi = 200)
fig4

# Tableau chiffré (euros de 2025)
familles |>
  filter(annee %in% c(1981, 1990, 1997, 1998, 2011, 2012, 2013, 2025)) |>
  transmute(annee, cas,
            avantage_effectif = round(`Avantage effectif`),
            sans_plafond      = round(`Avantage sans plafonnement`),
            perdu_plafond     = sans_plafond - avantage_effectif) |>
  arrange(cas, annee) |>
  tibble::as_tibble() |>
  print(n = Inf)
