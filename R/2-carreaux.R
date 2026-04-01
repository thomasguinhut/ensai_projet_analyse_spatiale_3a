################################################################################
############################ Importation des données ###########################
################################################################################


objets_initiaux <- ls()

carreaux_1 <-
  aws.s3::s3read_using(
    FUN = read.csv,
    object = "diffusion/projet_analyse_spatiale/sources/carreaux_nivNaturel_met.csv",
    bucket = "thomasguinhut",
    opts = list("region" = "")
  )

glimpse(carreaux_1)



################################################################################
############################ Nettoyage des bases ###############################
################################################################################


summary(carreaux_1$men)
# Le minimum est bien 11

carreaux_2 <- carreaux_1 %>% 
  mutate(tx_pauv = round(men_pauv / men * 100, 1)) %>% 
  dplyr::select(idcar_nat, tx_pauv) %>% 
  rename(ID = idcar_nat,
         TX_PAUV = tx_pauv)
  
glimpse(carreaux_2)

table(carreaux_2$TX_PAUV, useNA = "always")
# Pas de NA

carreaux <- carreaux_2 %>% 
  mutate(TX_PAUV = as.numeric((TX_PAUV)))



################################################################################
################################ Export ########################################
################################################################################


aws.s3::s3write_using(
  carreaux,
  FUN = function(data, file) saveRDS(data, file = file),
  object = "diffusion/projet_analyse_spatiale/carreaux.rds",
  bucket = "thomasguinhut",
  opts = list(region = "")
)

nouveaux_objets <- setdiff(ls(), objets_initiaux)
rm(list = nouveaux_objets)
rm(nouveaux_objets)
