#' Project flowline, watershed, or location shapefile as AEA or other
#'
#' @param shapefile Name of shapefile
#' @param proj_args Projection arguments as PROJ.4
#'
#' @return Spatial*DataFrame of projected flowlines, watersheds, or locations
project_shapefile <- function(shapefile, proj_args = "+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs") {
  dat <- st_read(shapefile)
  dat <- st_zm(dat)

  if (st_crs(dat)$proj4string != proj_args) {
    dat <- st_transform(dat, crs = proj_args)
  }

  dat <- as(dat, "Spatial")

  return(dat)
}
