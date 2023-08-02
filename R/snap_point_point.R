#' Snap location points to stream points
#'
#' @param points Clipped locations object
#' @param points2 Converted streams object
#' @param buffer Radius of buffer around locations
#'
#' @return SpatialPointsDataFrame of locations snapped to streams
snap_point_point <- function(points, points2, buffer) {
  if (length(points) != 0) {

    # extract reference points within buffers around target points
    points2 <- points2[gBuffer(points, byid = TRUE, width = buffer), ]

    nearest_coordinates <- nearest_distances <- list()
    for (i in seq_along(points)) {

      # compute distances between target point and reference points
      distances <- spDistsN1(points2, points[i, ])

      # obtain coordinates of reference point nearest to target point
      nearest_coordinates[[i]] <- points2@coords[which.min(distances), ]

      # obtain distance from target point to nearest reference point
      nearest_distances[[i]] <- min(distances)
    }

    # snap target points to nearest reference points
    dat <- points
    dat@coords <- do.call("rbind", nearest_coordinates)

    # add nearest reference point distances to target points data
    dat@data$nearest_stream_distance <- unlist(nearest_distances)
  } else {
    dat <- NULL
  }

  return(dat)
}
