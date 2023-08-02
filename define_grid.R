#' Define streams from accumulation grid cells
#'
#' @param grid Name of classified accumulations grid
#'
#' @return File path and raster of defined streams
define_grid <- function(grid) {
  dat <- rast(grid) %>%
    classify(matrix(c(0, 1e12, 1), ncol = 3), include.lowest = TRUE, datatype = "INT1U")
  file_path <- str_replace(grid, "fac", "str")

  writeRaster(dat, file_path, overwrite = TRUE, datatype = "INT1U")

  return(file_path)
}
