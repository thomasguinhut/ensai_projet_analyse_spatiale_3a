# ===============================
# 1. Préparation des données
# ===============================

# Fonds Europe et océan
europe <- ne_countries(scale = "medium", continent = "Europe", returnclass = "sf")
ocean  <- ne_download(scale = "medium", type = "ocean", category = "physical", returnclass = "sf")

# Extraction vectorisée des coordonnées depuis l'ID INSPIRE
res  <- as.numeric(str_extract(carreaux$ID, "(?<=RES)\\d+"))
nord <- as.numeric(str_extract(carreaux$ID, "(?<=N)\\d+(?=E)"))
est  <- as.numeric(str_extract(carreaux$ID, "(?<=E)\\d+$"))

# Création des WKT directement (beaucoup plus léger)
wkt <- paste0(
  "POLYGON((",
  est,       " ", nord,       ",",
  est + res, " ", nord,       ",",
  est + res, " ", nord + res, ",",
  est,       " ", nord + res, ",",
  est,       " ", nord,
  "))"
)

# Conversion en sf en une seule opération
carreaux_sf <- st_as_sf(
  data.frame(TX_PAUV = carreaux$TX_PAUV, wkt = wkt),
  wkt = "wkt",
  crs = 3035
) %>%
  st_transform(2154)

# Reprojection Europe et océan
europe <- st_transform(europe, 2154)
ocean  <- st_transform(ocean, 2154)

# Discrétisation
bornes <- classIntervals(
  carreaux_sf$TX_PAUV,
  n = 5,
  style = "quantile"
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
  border  = NA,
  lwd     = 0.001,
  leg_pos = NA,
  add     = TRUE
)

# Labels mer
text(
  x      = 200000,
  y      = 6500000,
  labels = "Océan\nAtlantique",
  col    = "#1a5276",
  cex    = 0.65,
  font   = 3
)
text(
  x      = 900000,
  y      = 6100000,
  labels = "Mer\nMéditerranée",
  col    = "#1a5276",
  cex    = 0.65,
  font   = 3
)

# ===============================
# 4. Légende
# ===============================
mf_theme("default")
mf_legend(
  type  = "choro",
  val   = bornes,
  pal   = pal,
  title = "Taux de pauvreté en %\n(discrétisation de quantiles)",
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
  title   = "Taux de pauvreté par carreau au niveau naturel en 2021",
  credits = "Source : Insee",
  arrow   = TRUE
)
