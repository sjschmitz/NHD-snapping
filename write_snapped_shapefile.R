#' Produce shapefiles of location points snapped to flowline lines or stream points
#'
#' @param locations Flowline- or stream-snapped locations object
#' @param file Name of file with defined locations
#' @param path Path for writing data
#'
#' @return File path and SHP of snapped locations
write_snapped_shapefile <- function(locations, file, path) {
  name <- names(locations) %>%
    str_split("_", simplify = TRUE) %>%
    .[1, -ncol(.)] %>%
    str_c("_", collapse = "")
  dat <- unlist(locations) %>%
    bind() %>%
    st_as_sf()
  names(dat) <- abbreviate(names(dat), minlength = 10, named = FALSE)
  file_path <- file.path(path, paste0(name, basename(file)))

  st_write(dat, dsn = file_path, delete_layer = TRUE)

  return(file_path)
}
