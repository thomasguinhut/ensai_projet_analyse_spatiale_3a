fonds_reg <- aws.s3::s3read_using(
  FUN = st_read,
  object = "diffusion/projet_analyse_spatiale/fonds_carte/regions.geojson",
  bucket = "thomasguinhut",
  opts = list("region" = "")
)

glimpse(fonds_epci)

glimpse(epci)