# Indice des prix à la consommation en moyenne annuelle (base 2025 = 100)
# Source : INSEE, « Coefficient de transformation de l'euro ou du franc d'une
# année en euro ou en franc d'une autre année - Base 2025 », via DBnomics.
# Série d'inflation pure : les changements de monnaie ne sont pas inclus.
brut <- rdbnomics::rdb(ids = "INSEE/COEFF-EURO-FRANC/A.IPC.INDICE.FE.SO.BRUT.2025")

ipc <- data.frame(annee  = as.integer(format(brut$period, "%Y")),
                  indice = brut$value)

usethis::use_data(ipc, overwrite = TRUE)
