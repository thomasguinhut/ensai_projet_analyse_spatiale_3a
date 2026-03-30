################################################################################
############################ CHARGEMENT DES PACKAGES ###########################
################################################################################


packages_requis <- c("aws.s3", "dplyr", "stringr", "ggplot2", "sf", "mapsf",
                     "classInt", "rnaturalearth", "rnaturalearthdata", "remotes")

if (!"pacman" %in% installed.packages()) {
  install.packages("pacman")
}
library(pacman)

pacman::p_load(char = packages_requis)

rm(packages_requis)



################################################################################
############################ IMPORTATION DES DONNÉES ###########################
################################################################################


source("R/A-preparation_donnees/A0-import_donnees.R")



################################################################################
#################################### CARTES ####################################
################################################################################


source("R/B-cartes/B0-import_fonctions_carte.R")

plot_dep()
plot_reg()
plot_epci()
plot_carreaux()
plot_iris()

glimpse(epci)

plot_epci(var = "PART_BAC5PLUS_2022")
plot_epci(var = "PART_CHOMAGE_REV_2021")
