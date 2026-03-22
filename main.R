################################################################################
############################ CHARGEMENT DES PACKAGES ###########################
################################################################################



packages_requis <- c("aws.s3", "dplyr", "stringr", "ggplot2", "sf", "mapsf",
                     "classInt", "rnaturalearth")

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
