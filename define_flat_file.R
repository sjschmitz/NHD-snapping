#' Define lat/long of locations in flat file as NAD83 or other
#'
#' @param flat_file Name of flat file with locations
#' @param path Path for writing data
#' @param lat_variable Name of column with latitude values
#' @param long_variable Name of column with longitude values
#' @param proj_args Projection arguments as PROJ.4
#'
#' @return File path, CSV, and SHP of defined locations
define_flat_file <- function(flat_file, path, lat_variable, long_variable, proj_args = "+proj=longlat +datum=NAD83 +no_defs") {
  dat <- read_csv(flat_file, show_col_types = FALSE)
  file_path <- file.path(path, basename(flat_file))

  dat <- dat %>%
    rownames_to_column(var = "IDobs") %>%
    filter(!is.na(!!sym(lat_variable)),
           !is.na(!!sym(long_variable))) %>%
    group_by(!!sym(lat_variable), !!sym(long_variable)) %>%
    mutate(IDloc = cur_group_id(), .after = IDobs) %>%
    ungroup()

  names(dat) <- names(dat) %>%
    str_remove_all("[^[:alnum:]]") %>%
    abbreviate(minlength = 10, named = FALSE)

  write_csv(dat, file_path)

  dat <- distinct(dat, IDloc, .keep_all = TRUE)
  coordinates(dat) <- c(long_variable, lat_variable)
  proj4string(dat) <- proj_args
  dat <- st_as_sf(dat)
  file_path <- str_replace(flat_file, ".csv", ".shp")

  st_write(dat, dsn = file_path, delete_layer = TRUE)

  return(file_path)
}
