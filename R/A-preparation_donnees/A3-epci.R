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
glimpse(liste_epci_2022_4)

epci_5 <- epci_4 %>% 
  left_join(
    liste_epci_2022_4 %>% 
      distinct(ID, .keep_all = TRUE) %>% 
      dplyr::select(ID, DEP, REG),
    by = "ID"
  )

glimpse(epci_5)

table(epci_5$TX_PAUV, useNA = "always")

epci_6 <- epci_5 %>% 
  relocate(TX_PAUV, .after = REG)

table(epci_6$TX_PAUV, useNA = "always")

epci_7 <- epci_6 %>% 
  mutate(TX_PAUV = as.numeric((TX_PAUV)))

glimpse(epci_7)



################################################################################
########################### Infos auxiliaires ##################################
################################################################################


# https://statistiques-locales.insee.fr/#c=indicator&i=bdcom.pmen&i2=ds_filosofi.ir_d9_d1_sl&s=2022&s2=2021&t=A01&t2=A01&view=map4
export_insee_stats_locales_1 <- aws.s3::s3read_using(
  FUN = read.csv2,
  object = "diffusion/projet_analyse_spatiale/sources/data.csv",
  bucket = "thomasguinhut",
  opts = list("region" = "")
)
colnames(export_insee_stats_locales_1) <- export_insee_stats_locales_1[2,]
export_insee_stats_locales_1 <- export_insee_stats_locales_1[-c(1,2),]

names(export_insee_stats_locales_1)

export_insee_stats_locales_2 <- export_insee_stats_locales_1 %>%
  rename(
    ID = "Code",
    LIBELLE = "Libellé",
    POP_2022 = "Population des ménages 2022",
    RATIO_DECILE9_1_2021 = "Rapport interdécile du niveau de vie (9e déc./1er déc.) 2021",
    SALAIRE_MOYEN_2023 = "Salaire net EQTP mensuel moyen 2023",
    TX_ACTIVITE_2022 = "Taux d'activité par tranche d'âge 2022",
    NB_EMPLOIS_LT_2022 = "Nb d'emplois au lieu de travail (LT) 2022",
    PART_MONO_2022 = "Part des familles monoparentales 2022",
    PART_MENAGE_1PERS_2022 = "Part des ménages d'une pers. 2022",
    TAILLE_MOY_MENAGE_2022 = "Taille moyenne des ménages 2022",
    PART_CHOMAGE_REV_2021 = "Part des indemnités de chômage dans le rev. disp. 2021",
    PART_ACTIVITE_REV_2021 = "Part des revenus d'activité dans le rev. disp. 2021",
    PART_PENSIONS_REV_2021 = "Part des pensions, retraites et rentes dans le rev. disp. 2021",
    PART_PATRIMOINE_REV_2021 = "Part des revenus du patrimoine et autres dans le rev. disp. 2021",
    PART_PREST_SOC_REV_2021 = "Part des prestations sociales dans le rev. disp. 2021",
    PART_PREST_FAM_REV_2021 = "Part des prestations familiales dans le rev. disp. 2021",
    PART_MINIMA_SOC_REV_2021 = "Part des minima sociaux dans le rev. disp. 2021",
    PART_PREST_LOG_REV_2021 = "Part des prestations logement dans le rev. disp. 2021",
    PART_IMPOTS_REV_2021 = "Part des impôts dans le rev. disp. 2021",
    MED_NIV_VIE_2021 = "Médiane du niveau de vie 2021",
    DECILE9_NIV_VIE_2021 = "9e décile du niv. de vie 2021",
    DECILE1_NIV_VIE_2021 = "1er décile du niv. de vie 2021",
    PART_SALAIRES_REV_2021 = "Part des salaires et traitements hors chômage dans le rev. disp. 2021",
    PART_MENAGE_IMPOSE_2021 = "Part des ménages fiscaux imposés 2021",
    PART_NON_DIPLOME_2022 = "Part des non ou peu diplômés dans la pop. non scolarisée de 15 ans ou + 2022",
    PART_BREVET_2022 = "Part des pers., dont le diplôme le plus élevé est le bepc ou le brevet, dans la pop. non scolarisée de 15 ans ou + 2022",
    PART_CAP_BEP_2022 = "Part des pers., dont le diplôme le plus élevé est un CAP ou un BEP, dans la pop. non scolarisée de 15 ans ou + 2022",
    PART_BAC_2022 = "Part des pers., dont le diplôme le plus élevé est le bac, dans la pop. non scolarisée de 15 ans ou + 2022",
    PART_BAC2_2022 = "Part des diplômés d'un BAC+2 dans la pop. non scolarisée de 15 ans ou + 2022",
    PART_BAC34_2022 = "Part des diplômés d'un BAC+3  ou BAC+4 dans la pop. non scolarisée de 15 ans ou + 2022",
    PART_BAC5PLUS_2022 = "Part des diplômés d'un BAC+5 ou plus dans la pop. non scolarisée de 15 ans ou + 2022",
    CREATIONS_ENT_2024 = "Créations d'entreprises (en nombre) 2024"
  ) %>% 
  dplyr::select(-LIBELLE) %>% 
  mutate(across(-ID, as.numeric))

epci_8 <- epci_7 %>% 
  left_join(export_insee_stats_locales_2 , by = "ID")

colSums(is.na(epci_8))


################################################################################
################################ Export ########################################
################################################################################


aws.s3::s3write_using(
  epci_8,
  FUN = function(data, file) saveRDS(data, file = file),
  object = "diffusion/projet_analyse_spatiale/epci.rds",
  bucket = "thomasguinhut",
  opts = list(region = "")
)

nouveaux_objets <- setdiff(ls(), objets_initiaux)
rm(list = nouveaux_objets)
rm(nouveaux_objets)
