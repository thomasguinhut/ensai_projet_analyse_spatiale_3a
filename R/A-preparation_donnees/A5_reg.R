################################################################################
############################ Importation des données ###########################
################################################################################


objets_initiaux <- ls()

reg_1 <-
  aws.s3::s3read_using(
    FUN = read.csv2,
    object = "diffusion/projet_analyse_spatiale/sources/pauv_reg.csv",
    bucket = "thomasguinhut",
    opts = list("region" = "")
  )

glimpse(reg_1)



################################################################################
############################ Nettoyage des bases ###############################
################################################################################


colnames(reg_1) <- reg_1[2,]
reg_2 <- reg_1[-c(1,2),]

glimpse(reg_2)

reg_3 <- reg_2 %>% 
  rename(ID = Code,
         TX_PAUV = `Taux de pauvreté 2021`,
         ID_NAME = Libellé) %>% 
  dplyr::select(ID, ID_NAME, TX_PAUV)

glimpse(reg_3)

reg_4 <- reg_3 %>% 
  filter(!(ID %in% c("01", "02", "03", "04", "06", "94")))

table(reg_4$TX_PAUV, useNA = "always")

reg <- reg_4 %>% 
  mutate(TX_PAUV = as.numeric((TX_PAUV)))



################################################################################
################################ Export ########################################
################################################################################


aws.s3::s3write_using(
  reg,
  FUN = function(data, file) saveRDS(data, file = file),
  object = "diffusion/projet_analyse_spatiale/reg.rds",
  bucket = "thomasguinhut",
  opts = list(region = "")
)

nouveaux_objets <- setdiff(ls(), objets_initiaux)
rm(list = nouveaux_objets)
rm(nouveaux_objets)
