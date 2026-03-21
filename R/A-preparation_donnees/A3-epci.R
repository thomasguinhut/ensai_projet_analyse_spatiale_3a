################################################################################
############################ Importation des données ###########################
################################################################################


objets_initiaux <- ls()

epci_1 <-
  aws.s3::s3read_using(
    FUN = read.csv2,
    object = "diffusion/projet_analyse_spatiale/sources/pauv_epci.csv",
    bucket = "thomasguinhut",
    opts = list("region" = "")
  )

glimpse(epci_1)

liste_epci_2022_1 <-
  aws.s3::s3read_using(
    FUN = readxl::read_xlsx,
    sheet = "Composition_communale",
    object = "diffusion/projet_analyse_spatiale/sources/Intercommunalite_Metropole_au_01-01-2022.xlsx",
    bucket = "thomasguinhut",
    opts = list("region" = "")
  )

glimpse(liste_epci_2022_1)



################################################################################
############################ Nettoyage des bases ###############################
################################################################################


colnames(epci_1) <- epci_1[2,]
epci_2 <- epci_1[-c(1,2),]

glimpse(epci_2)

colnames(liste_epci_2022_1) <- liste_epci_2022_1[5,]
liste_epci_2022_2 <- liste_epci_2022_1[-c(1:5),]

glimpse(liste_epci_2022_2)

liste_epci_2022_3 <- liste_epci_2022_2 %>% 
  rename(ID = EPCI)

unique(liste_epci_2022_3$DEP)

liste_epci_2022_4 <- liste_epci_2022_3 %>% 
  filter(!(DEP %in% c("971", "972", "973", "974", "976")))

unique(liste_epci_2022_4$DEP)

setdiff(epci_2$Code, liste_epci_2022_1$EPCI)

epci_3 <- epci_2 %>%
  filter(Code %in% liste_epci_2022_4$ID)

epci_4 <- epci_3 %>% 
  rename(ID = Code,
         TX_PAUV = `Taux de pauvreté 2021`,
         ID_NAME = Libellé) %>% 
  dplyr::select(ID, ID_NAME, TX_PAUV)

glimpse(epci_4)

epci_5 <- epci_4 %>% 
  left_join(liste_epci_2022_4 %>% dplyr::select(ID, DEP, REG), by = "ID")

glimpse(epci_5)

table(epci_5$TX_PAUV, useNA = "always")

epci_6 <- epci_5 %>% 
  relocate(TX_PAUV, .after = REG)

table(epci_6$TX_PAUV, useNA = "always")

epci <- epci_6 %>% 
  mutate(TX_PAUV = as.numeric((TX_PAUV)))

glimpse(epci)


################################################################################
################################ Export ########################################
################################################################################


aws.s3::s3write_using(
  epci,
  FUN = function(data, file) saveRDS(data, file = file),
  object = "diffusion/projet_analyse_spatiale/epci.rds",
  bucket = "thomasguinhut",
  opts = list(region = "")
)

nouveaux_objets <- setdiff(ls(), objets_initiaux)
rm(list = nouveaux_objets)
rm(nouveaux_objets)
