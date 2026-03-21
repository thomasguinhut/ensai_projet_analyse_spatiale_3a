################################################################################
############################ Importation des données ###########################
################################################################################


objets_initiaux <- ls()

dep_1 <-
  aws.s3::s3read_using(
    FUN = read.csv2,
    object = "diffusion/projet_analyse_spatiale/sources/pauv_dep.csv",
    bucket = "thomasguinhut",
    opts = list("region" = "")
  )

glimpse(dep_1)



################################################################################
############################ Nettoyage des bases ###############################
################################################################################


colnames(dep_1) <- dep_1[2,]
dep_2 <- dep_1[-c(1,2),]

glimpse(dep_2)

dep_3 <- dep_2 %>% 
  rename(ID = Code,
         TX_PAUV = `Taux de pauvreté 2021`,
         ID_NAME = Libellé) %>% 
  dplyr::select(ID, ID_NAME, TX_PAUV)

glimpse(dep_3)

dep_4 <- dep_3 %>% 
  filter(!(ID %in% c("971", "972", "973", "974", "976")))

table(dep_3$TX_PAUV, useNA = "always")

dep_5 <- dep_4 %>% 
  mutate(TX_PAUV = ifelse(TX_PAUV == "N/A - résultat non disponible", NA, TX_PAUV))

table(dep_5$TX_PAUV, useNA = "always")

dep <- dep_5 %>% 
  mutate(TX_PAUV = as.numeric((TX_PAUV)))



################################################################################
################################ Export ########################################
################################################################################


aws.s3::s3write_using(
  dep,
  FUN = function(data, file) saveRDS(data, file = file),
  object = "diffusion/projet_analyse_spatiale/dep.rds",
  bucket = "thomasguinhut",
  opts = list(region = "")
)

nouveaux_objets <- setdiff(ls(), objets_initiaux)
rm(list = nouveaux_objets)
rm(nouveaux_objets)
