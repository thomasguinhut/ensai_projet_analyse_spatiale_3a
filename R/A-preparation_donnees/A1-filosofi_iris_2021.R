objets_initiaux <- ls()

# On prend la base après redistribution
filosofi_iris_2023_1 <-
  aws.s3::s3read_using(
    FUN = read.csv2,
    object = "diffusion/projet_analyse_spatiale/sources/BASE_TD_FILO_IRIS_2021_DISP.csv",
    bucket = "thomasguinhut",
    opts = list("region" = "")
  )

glimpse(filosofi_iris_2023_1)



################################################################################
################################ Export ########################################
################################################################################


aws.s3::s3write_using(
  catnat,
  FUN = function(data, file) saveRDS(data, file = file),
  object = "diffusion/projet_analyse_spatiale/filosofi_iris_2023.rds",
  bucket = "thomasguinhut",
  opts = list(region = "")
)

nouveaux_objets <- setdiff(ls(), objets_initiaux)
rm(nouveaux_objets, list = nouveaux_objets)