plot_reg <- function(var = "TX_PAUV"){
  
  fonds_reg <- aws.s3::s3read_using(
  FUN = st_read,
  object = "diffusion/projet_analyse_spatiale/fonds_carte/regions.geojson",
  bucket = "thomasguinhut",
  opts = list("region" = "")
)

# ===============================
# 1. Préparation des données
# ===============================
fonds_reg <- fonds_reg %>%
  left_join(reg, by = c("code" = "ID"))

# Fonds Europe et océan
europe <- ne_countries(scale = "medium", continent = "Europe", returnclass = "sf")
ocean  <- ne_download(scale = "medium", type = "ocean", category = "physical", returnclass = "sf")

# Reprojection
fonds_reg <- st_transform(fonds_reg, 2154)
europe    <- st_transform(europe, 2154)
ocean     <- st_transform(ocean, 2154)

# Discrétisation
bornes <- classIntervals(
  fonds_reg[[var]],
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
mf_init(fonds_reg, expandBB = c(0.05, 0.27, 0.05, 0.2))

# Océan
mf_map(ocean, col = "#a8c8e8", border = NA, add = TRUE)

# Europe
mf_map(europe, col = "#4a5568", border = "grey60", lwd = 0.3, add = TRUE)

# Régions françaises
mf_map(
  fonds_reg,
  var     = var,
  type    = "choro",
  breaks  = bornes,
  pal     = pal,
  border  = "black",
  lwd     = 0.6,
  leg_pos = NA,
  add     = TRUE
)

# Label océan Atlantique
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

mf_label(
  fonds_reg,
  var     = var,
  col     = "white",
  halo    = TRUE,
  bg      = "grey20",
  cex     = 0.75,
  overlap = FALSE,
  r       = 0.07
)

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
  title   = "Taux de pauvreté par région de France métropolitaine en 2021",
  credits = "Source : Insee",
  arrow   = TRUE
)

}
