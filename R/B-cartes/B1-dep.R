plot_dep <- function(var = "TX_PAUV"){
  
  fonds_dep <- aws.s3::s3read_using(
  FUN = st_read,
  object = "diffusion/projet_analyse_spatiale/fonds_carte/departements.geojson",
  bucket = "thomasguinhut",
  opts = list("region" = "")
)

# ===============================
# 1. Préparation des données
# ===============================
fonds_dep <- fonds_dep %>%
  left_join(dep, by = c("code" = "ID"))

idf_codes <- c("75", "92", "93", "94")
fonds_idf <- fonds_dep %>%
  filter(code %in% idf_codes)

# Fonds Europe et océan
europe <- ne_countries(scale = "medium", continent = "Europe", returnclass = "sf")
ocean  <- ne_download(scale = "medium", type = "ocean", category = "physical", returnclass = "sf")

# Reprojection
fonds_dep <- st_transform(fonds_dep, 2154)
fonds_idf <- st_transform(fonds_idf, 2154)
europe    <- st_transform(europe, 2154)
ocean     <- st_transform(ocean, 2154)

# Discrétisation
bornes <- classIntervals(
  fonds_dep[[var]],
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
mf_init(fonds_dep, expandBB = c(0.05, 0.27, 0.05, 0.2))

# Océan
mf_map(ocean, col = "#a8c8e8", border = NA, add = TRUE)

# Europe
mf_map(europe, col = "#4a5568", border = "grey60", lwd = 0.3, add = TRUE)

# Départements français
mf_map(
  fonds_dep,
  var     = var,
  type    = "choro",
  breaks  = bornes,
  pal     = pal,
  border  = "black",
  lwd     = 0.4,
  leg_pos = NA,
  add     = TRUE
)

# Encadré IDF sur la carte principale
bbox_idf <- st_bbox(fonds_idf)
bbox_idf["xmin"] <- bbox_idf["xmin"] - 10000
bbox_idf["xmax"] <- bbox_idf["xmax"] + 10000
bbox_idf["ymin"] <- bbox_idf["ymin"] - 10000
bbox_idf["ymax"] <- bbox_idf["ymax"] + 10000
bbox_idf <- bbox_idf %>% st_as_sfc() %>% st_as_sf()
mf_map(
  bbox_idf,
  border = "black",
  lwd    = 2,
  col    = NA,
  add    = TRUE
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
# 4. Encart IDF
# ===============================
mf_inset_on(fonds_idf, pos = "topright", cex = 0.22)
mf_init(fonds_idf, expandBB = c(0.3, 0.2, 0.3, 0.2))
mf_map(
  fonds_idf,
  var     = var,
  type    = "choro",
  breaks  = bornes,
  pal     = pal,
  border  = "white",
  lwd     = 0.8,
  leg_pos = NA,
  add     = TRUE
)
mf_label(
  fonds_idf,
  var     = "nom",
  col     = "white",
  halo    = TRUE,
  bg      = "grey20",
  cex     = 0.6,
  overlap = FALSE
)
mf_scale(size = 10, col = "white")
box(which = "plot", col = "white", lwd = 1.5)
mf_inset_off()

# ===============================
# 5. Légende
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
# 6. Habillage
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
  title   = "Taux de pauvreté par département de France métropolitaine en 2021",
  credits = "Source : Insee",
  arrow   = TRUE
)

}
