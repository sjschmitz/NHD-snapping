#' Classify accumulation grid cells less than or equal to threshold as non-stream
#'
#' @param grid Name of projected accumulations grid
#' @param threshold Value of flow accumulation threshold for classifying grid cells as NA
#'
#' @return File path and raster of classified accumulations
classify_grid <- function(grid, threshold) {
  dat <- rast(grid) %>%
    classify(matrix(c(0, threshold, NA), ncol = 3), include.lowest = TRUE, datatype = "INT4S")
  file_path <- str_replace(grid, "fac", paste0("fac", threshold))

  writeRaster(dat, file_path, overwrite = TRUE, datatype = "INT4S")

  return(file_path)
}
