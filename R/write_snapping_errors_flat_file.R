#' Produce flat file of location points snapped to flowline lines or stream points
#'
#' @param errors Assessed snapping errors object
#' @param file Name of file with defined locations
#' @param path Path for writing data
#'
#' @return File path and CSV of assessed errors of snapping locations to accumulations
write_snapping_errors_flat_file <- function(errors, file, path) {
  dat <- errors %>%
    arrange("IDobs")
  file_path <- file.path(path, paste0("snapping_errors_assessed_", basename(file)))

  write_csv(dat, file_path)

  return(file_path)
}
