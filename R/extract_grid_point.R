#' Extract accumulation grid at and within buffer around location points
#'
#' @param grid Name of classified accumulations grid
#' @param points Stream-snapped locations object
#' @param buffer Radius of buffer around locations
#'
#' @return ata.frame of accumulations extracted for locations
extract_grid_point = function(grid, points, buffer) {
  if (length(points) != 0) {
    dat <- extract(rast(grid), vect(points)) %>%
      left_join(extract(rast(grid), buffer(vect(points), buffer), fun = range, na.rm = TRUE))
    dat <- dat[, -1]
    names(dat) <- c("fac_point", "fac_min_buffer", "fac_max_buffer")
  } else {
    dat <- NULL
  }

  return(dat)
}
