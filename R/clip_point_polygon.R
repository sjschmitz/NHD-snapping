#' Clip location points by watershed polygons
#'
#' @param points Project locations object
#' @param polygons Projected watersheds object
#'
#' @return SpatialPointsDataFrame of locations clipped by watersheds
clip_point_polygon <- function(points, polygons) {
  dat <- points[polygons, ]

  return(dat)
}
