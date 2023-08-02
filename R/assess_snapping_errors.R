#' Assess errors of snapping location points to stream points
#'
#' @param locations Flowline-snapped locations object
#' @param accumulations Location-extracted accumulations object
#' @param site_variable Name of column with site names
#' @param buffer Radius of buffer around locations
#'
#' @return data.frame of assessed errors of snapping locations to accumulations
assess_snapping_errors <- function(locations, accumulations, site_variable, buffer) {

  # bind accumulation data to location data
  locations <- st_as_sf(locations) %>%
    st_drop_geometry()
  dat <- data.frame(locations, accumulations) %>%
    relocate(nearest_stream_distance, .after = nearest_flowline_distance)

  # obtain locations with accumulation value less than half, etc., of maximum or greater than double, etc., of minimum within buffer around location
  fac_ratio_max <- dat$fac_point / dat$fac_max_buffer
  fac_ratio_min <- dat$fac_point / dat$fac_min_buffer
  errors <- rep("", nrow(dat))
  errors[which((dat$fac_point >= 1e7 & (fac_ratio_max <= 0.9 | fac_ratio_min >= 1.11))
               | (dat$fac_point >= 1e6 & dat$fac_point < 1e7 & (fac_ratio_max <= 0.8 | fac_ratio_min >= 1.25))
               | (dat$fac_point >= 1e5 & dat$fac_point < 1e6 & (fac_ratio_max <= 0.6 | fac_ratio_min >= 1.67))
               | (dat$fac_point >= 1e4 & dat$fac_point < 1e5 & (fac_ratio_max <= 0.4 | fac_ratio_min >= 2.5))
               | (dat$fac_point >= 1e3 & dat$fac_point < 1e4 & (fac_ratio_max <= 0.2 | fac_ratio_min >= 5))
               | (dat$fac_point >= 1e2 & dat$fac_point < 1e3 & (fac_ratio_max <= 0.1 | fac_ratio_min >= 10)))
  ] <- "maybe"
  dat$err_pt_fac_exc_buff_rng <- errors

  # obtain locations with nearest stream distance farther than buffer around location
  errors <- rep("", nrow(dat))
  errors[which(dat$nearest_stream_distance > buffer)] <- "maybe"
  dat$err_snap_dist_exc_buff_rad <- errors

  # change site names to upper case and change NAs
  dat[[site_variable]] <- toupper(dat[[site_variable]])
  dat$GNIS_NAME <- toupper(dat$GNIS_NAME)
  dat[[site_variable]][which(is.na(dat[[site_variable]]))] <- "UNKNOWN"
  dat$GNIS_NAME[which(is.na(dat$GNIS_NAME))] <- "UNKNOWN"
  dat <- dat[order(dat[[site_variable]], dat$fac_point), ]

  # obtain locations with beginning (first 3 characters) of site name not equivalent to nearest flowline
  errors <- rep("", nrow(dat))
  errors[(str_sub(dat[[site_variable]], 1, 3) != str_sub(dat$GNIS_NAME, 1, 3))] <- "maybe"
  dat$err_obs_name_diff_fln_name <- errors

  # obtain locations with accumulation value less than half of median or greater than double of median for all locations with same site name
  errors <- rep("", nrow(dat))
  for (i in unique(dat[[site_variable]])) {
    idx = which(dat[[site_variable]] == i)
    fac <- dat$fac_point[idx]
    for (j in seq_along(idx)) {
      if (fac[j] < median(fac) * 0.5 | fac[j] > median(fac) / 0.5) {
        errors[idx[j]] = "maybe"
      }
    }
  }
  dat$err_pt_fac_exc_same_site_name_rng <- errors

  return(dat)
}
