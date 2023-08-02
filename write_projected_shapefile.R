#' Produce shapefile of location points projected as AEA or other
#'
#' @param locations Projected locations object
#' @param file Name of file with defined locations
#' @param path Path for writing data
#'
#' @return File path and SHP of projected locations
write_projected_shapefile <- function(locations, file, path) {
  dat <- st_as_sf(locations)
  file_path <- file.path(path, basename(file))

  st_write(dat, dsn = file_path, delete_layer = TRUE)

  return(file_path)
}
