plot_carreaux <- function(var_choisie = "TX_PAUV") {
  
  europe <- ne_countries(scale = "medium", continent = "Europe", returnclass = "sf")
  ocean  <- ne_download(scale = "medium", type = "ocean", category = "physical", returnclass = "sf")
  
  res  <- as.numeric(str_extract(carreaux$ID, "(?<=RES)\\d+"))
  nord <- as.numeric(str_extract(carreaux$ID, "(?<=N)\\d+(?=E)"))
  est  <- as.numeric(str_extract(carreaux$ID, "(?<=E)\\d+$"))
  
  wkt <- paste0(
    "POLYGON((",
    est,       " ", nord,       ",",
    est + res, " ", nord,       ",",
    est + res, " ", nord + res, ",",
    est,       " ", nord + res, ",",
    est,       " ", nord,
    "))"
  )
  
  # ✅ La colonne prend le nom de var_choisie (ex. "TX_PAUV")
  carreaux_sf <- st_as_sf(
    setNames(data.frame(carreaux[[var_choisie]], wkt), c(var_choisie, "wkt")),
    wkt = "wkt",
    crs = 3035
  ) %>%
    st_transform(2154)
  
  europe <- st_transform(europe, 2154)
  ocean  <- st_transform(ocean, 2154)
  
  # ✅ On accède à la colonne dynamiquement
  bornes <- classIntervals(
    carreaux_sf[[var_choisie]],
    n = 5,
    style = "quantile"
  )$brks
  
  pal <- "YlOrRd"
  
  mf_theme(list(bg = "#4a5568", fg = "white", mar = c(0, 0, 1.5, 0),
                tab = FALSE, pos = "left", inner = FALSE,
                line = 1.5, cex = 1, font = 2))
  
  mf_init(carreaux_sf, expandBB = c(0.05, 0.27, 0.05, 0.2))
  mf_map(ocean, col = "#a8c8e8", border = NA, add = TRUE)
  mf_map(europe, col = "#4a5568", border = "grey60", lwd = 0.3, add = TRUE)
  
  # ✅ var = var_choisie correspond maintenant au bon nom de colonne
  mf_map(carreaux_sf, var = var_choisie, type = "choro",
         breaks = bornes, pal = pal, border = NA,
         lwd = 0.001, leg_pos = NA, add = TRUE)
  
  text(x = 200000, y = 6500000, labels = "Océan\nAtlantique",
       col = "#1a5276", cex = 0.65, font = 3)
  text(x = 900000, y = 6100000, labels = "Mer\nMéditerranée",
       col = "#1a5276", cex = 0.65, font = 3)
  
  mf_theme("default")
  mf_legend(type = "choro", val = bornes, pal = pal,
            title = "Taux de pauvreté en %\n(discrétisation de quantiles)",
            pos = "left")
  
  mf_theme(list(bg = "#4a5568", fg = "white", mar = c(0, 0, 1.5, 0),
                tab = FALSE, pos = "left", inner = FALSE,
                line = 1.5, cex = 1, font = 2))
  mf_layout(title   = "Taux de pauvreté par carreau au niveau naturel en 2021",
            credits = "Source : Insee", arrow = TRUE)
}