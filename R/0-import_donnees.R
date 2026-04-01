# source("R/A-preparation_donnees/A1-iris.R")
# source("R/A-preparation_donnees/A2-carreaux.R")
# source("R/A-preparation_donnees/A3-epci.R")
# source("R/A-preparation_donnees/A4_dep.R")
# source("R/A-preparation_donnees/A5_reg.R")

epci <-
  aws.s3::s3read_using(
    FUN = readRDS,
    object = "diffusion/projet_analyse_spatiale/epci.rds",
    bucket = "thomasguinhut",
    opts = list("region" = "")
  )

dep <-
  aws.s3::s3read_using(
    FUN = readRDS,
    object = "diffusion/projet_analyse_spatiale/dep.rds",
    bucket = "thomasguinhut",
    opts = list("region" = "")
  )

reg <-
  aws.s3::s3read_using(
    FUN = readRDS,
    object = "diffusion/projet_analyse_spatiale/reg.rds",
    bucket = "thomasguinhut",
    opts = list("region" = "")
  )

carreaux <-
  aws.s3::s3read_using(
    FUN = readRDS,
    object = "diffusion/projet_analyse_spatiale/carreaux.rds",
    bucket = "thomasguinhut",
    opts = list("region" = "")
  )

iris <-
  aws.s3::s3read_using(
    FUN = readRDS,
    object = "diffusion/projet_analyse_spatiale/iris.rds",
    bucket = "thomasguinhut",
    opts = list("region" = "")
  )

