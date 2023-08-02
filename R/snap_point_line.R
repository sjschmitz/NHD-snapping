#' Snap location points to flowline lines
#'
#' @param points Stream-snapped locations object
#' @param lines Projected flowlines object
#' @param buffer Radius of buffer around locations
#'
#' @return SpatialPointsDataFrame of locations snapped to flowlines
snap_point_line <- function(points, lines, buffer) {
  if (length(points) != 0) {

    # extract reference lines within buffers around target points
    lines <- lines[gBuffer(points, byid = TRUE, width = buffer), ]

    # snap target points to nearest reference lines
    dat <- my_snapPointsToLines(points, lines)
  } else {
    dat <- NULL
  }

  return(dat)
}
