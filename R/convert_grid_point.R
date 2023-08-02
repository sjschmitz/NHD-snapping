#' Convert stream grid cells to points
#'
#' @param grid Name of defined streams grid
#' @param path Path for writing data
#'
#' @return SpatialPointsDataFrame and SHP of converted streams
convert_grid_point <- function(grid, path) {
  dat <- raster(grid) %>%
    rasterToPoints(spatial = TRUE)
  temp <- st_as_sf(dat)
  file_path <- file.path(path, paste0("streams_converted_", basename(grid))) %>%
    str_replace(".tif", ".shp")

  st_write(temp, dsn = file_path, delete_layer = TRUE)

  return(dat)
}
