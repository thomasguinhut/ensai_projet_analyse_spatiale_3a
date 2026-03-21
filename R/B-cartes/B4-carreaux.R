# ===============================
# 1. Préparation des données
# ===============================

# Extraction des coordonnées depuis l'ID INSPIRE
# Format : CRS3035RES1000mN{nord}E{est}
carreaux <- carreaux %>%
  mutate(
    res  = as.numeric(str_extract(ID, "(?<=RES)\\d+")),        # résolution en mètres
    nord = as.numeric(str_extract(ID, "(?<=N)\\d+(?=E)")),     # coordonnée Nord
    est  = as.numeric(str_extract(ID, "(?<=E)\\d+$"))          # coordonnée Est
  )

# Création des géométries (coin inférieur gauche + résolution)
carreaux_sf <- carreaux %>%
  mutate(geometry = purrr::map2(est, nord, function(e, n) {
    st_polygon(list(matrix(c(
      e,       n,
      e + res, n,
      e + res, n + res,
      e,       n + res,
      e,       n
    ), ncol = 2, byrow = TRUE)))
  })) %>%
  st_as_sf(crs = 3035) %>%
  st_transform(2154)

# Discrétisation
bornes <- classIntervals(
  carreaux_sf$TX_PAUV,
  n = 5,
  style = "fisher"
)$brks

pal <- "YlOrRd"

# ===============================
# 2. Thème sombre
# ===============================
mf_theme(
  list(
    bg    = "#4a5568",
    fg    = "white",
    mar   = c(0, 0, 1.5, 0),
    tab   = FALSE,
    pos   = "left",
    inner = FALSE,
    line  = 1.5,
    cex   = 1,
    font  = 2
  )
)

# ===============================
# 3. Carte principale
# ===============================
mf_init(carreaux_sf, expandBB = c(0.05, 0.27, 0.05, 0.2))

# Océan
mf_map(ocean, col = "#a8c8e8", border = NA, add = TRUE)

# Europe
mf_map(europe, col = "#4a5568", border = "grey60", lwd = 0.3, add = TRUE)

# Carreaux
mf_map(
  carreaux_sf,
  var     = "TX_PAUV",
  type    = "choro",
  breaks  = bornes,
  pal     = pal,
  border  = NA,        # pas de bordure, trop de carreaux
  lwd     = 0,
  leg_pos = NA,
  add     = TRUE
)

# Labels mer
text(x = 200000, y = 6500000, labels = "Océan\nAtlantique",
     col = "#1a5276", cex = 0.65, font = 3)
text(x = 900000, y = 6100000, labels = "Mer\nMéditerranée",
     col = "#1a5276", cex = 0.65, font = 3)

# ===============================
# 4. Légende
# ===============================
mf_theme("default")
mf_legend(
  type  = "choro",
  val   = bornes,
  pal   = pal,
  title = "Taux de pauvreté en %\n(discrétisation de Fisher)",
  pos   = "left"
)

# ===============================
# 5. Habillage
# ===============================
mf_theme(
  list(
    bg    = "#4a5568",
    fg    = "white",
    mar   = c(0, 0, 1.5, 0),
    tab   = FALSE,
    pos   = "left",
    inner = FALSE,
    line  = 1.5,
    cex   = 1,
    font  = 2
  )
)
mf_layout(
  title   = "Taux de pauvreté par carreau de 1 km² en 2021",
  credits = "Source : Insee",
  arrow   = TRUE
)