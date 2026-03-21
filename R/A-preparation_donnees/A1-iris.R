################################################################################
############################ Importation des données ###########################
################################################################################


objets_initiaux <- ls()

# On prend la base après redistribution
# https://www.insee.fr/fr/statistiques/8229323
iris_1 <-
  aws.s3::s3read_using(
    FUN = read.csv2,
    object = "diffusion/projet_analyse_spatiale/sources/BASE_TD_FILO_IRIS_2021_DISP.csv",
    bucket = "thomasguinhut",
    opts = list("region" = "")
  )

glimpse(iris_1)

reference_iris_1 <-
  aws.s3::s3read_using(
    FUN = readxl::read_xlsx,
    object = "diffusion/projet_analyse_spatiale/sources/reference_IRIS_geo2022.xlsx",
    bucket = "thomasguinhut",
    opts = list("region" = "")
  )

glimpse(reference_iris_1)



################################################################################
############################ Nettoyage des bases ###############################
################################################################################


colnames(reference_iris_1) <- reference_iris_1[5,]
reference_iris_2 <- reference_iris_1[-c(1:5),]

glimpse(reference_iris_2)

reference_iris_3 <- reference_iris_2 %>% 
  rename(ID = CODE_IRIS)

iris_2 <- iris_1 %>% 
  dplyr::select(IRIS, DISP_TP6021) %>% 
  rename(ID = IRIS,
         TX_PAUV = DISP_TP6021) %>% 
  mutate(TX_PAUV = as.numeric(gsub(",", ".", TX_PAUV)))

glimpse(iris_2)

table(iris_2$TX_PAUV, useNA = "always")

iris_3 <- iris_2 %>% 
  mutate(TX_PAUV = ifelse(TX_PAUV %in% c("nd", "ns", "s"), NA, TX_PAUV))

table(iris_3$TX_PAUV, useNA = "always")

setdiff(iris_3$ID, reference_iris_3$ID)

iris_4 <- iris_3 %>% 
  left_join(reference_iris_3 %>% dplyr::select(ID, LIB_IRIS, LIBCOM, REG, DEP),
            by = "ID")

glimpse(iris_4)

iris_5 <- iris_4 %>% 
  filter(!(ID %in% c("972", "974")))

iris <- iris_5 %>% 
  mutate(TX_PAUV = as.numeric((TX_PAUV)))



################################################################################
################################ Export ########################################
################################################################################


aws.s3::s3write_using(
  iris,
  FUN = function(data, file) saveRDS(data, file = file),
  object = "diffusion/projet_analyse_spatiale/iris.rds",
  bucket = "thomasguinhut",
  opts = list(region = "")
)

nouveaux_objets <- setdiff(ls(), objets_initiaux)
rm(list = nouveaux_objets)
rm(nouveaux_objets)
