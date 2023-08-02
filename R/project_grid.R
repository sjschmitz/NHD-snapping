#' Project accumulation or stream grid as AEA or other
#'
#' @param grid_shapefile Name of grid
#' @param path Path for writing data
#' @param proj_args Projection arguments as PROJ.4
#'
#' @return File path and TIF of projected accumulations
project_grid <- function(grid, path, proj_args = "+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs") {
  dat <- rast(grid)
  file_path <- file.path(path, basename(grid))

  if (st_crs(dat)$proj4string == proj_args) {
    file.copy(grid, file_path)
  } else {
    dat <- project(dat, proj_args)

    writeRaster(dat, file_path, overwrite = TRUE, datatype = "INT4S")
  }

  return(file_path)
}
