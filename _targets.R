library(targets)

options(clustermq.scheduler = "multiprocess")

sapply(list.files("R", full.names = TRUE), source)

tar_option_set(packages = c("tidyverse",
                            "sf",
                            "terra",
                            "raster",
                            "rgdal",
                            "rgeos",
                            "maptools"),
               memory = "transient")


# Assign paths and projection arguments
path_raw_data <- "data-raw"
path_data <- "data"
path_results <- "results"
proj_args_nad83 <- "+proj=longlat +datum=NAD83 +no_defs"
proj_args_aea <- "+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs"


# Naming convention for medium resolution NHD: HUC2 with letter (such as 17a, 17b, etc.)
# Naming convention for NHDPlusHR: HUC4 (such as 1701, 1702, etc.)


list(

  # Track changes in raw data files
  tar_target(
    locations_csv,
    file.path(path_raw_data, "Streamflow_Catalog_draft.csv"),
    format = "file"
  ),
  tar_target(
    watersheds_shp,
    list.files(path_raw_data,
               pattern = glob2rx("*HU4*.shp"),
               full.names = TRUE),
    format = "file"
  ),
  tar_target(
    flowlines_shp,
    list.files(path_raw_data,
               pattern = glob2rx("*Flowline*.shp"),
               full.names = TRUE),
    format = "file"
  ),
  tar_target(
    accumulations_tif,
    list.files(path_raw_data,
               pattern = glob2rx("*fac*.tif"),
               full.names = TRUE),
    format = "file"
  ),

  # Produce objects of raw data file names with paths for pattern mapping
  tar_target(
    locations,
    locations_csv
  ),
  tar_target(
    watersheds,
    watersheds_shp
  ),
  tar_target(
    flowlines,
    flowlines_shp
  ),
  tar_target(
    accumulations,
    accumulations_tif
  ),

  # Define lat/long of locations in flat file as NAD83 or other
  tar_target(
    locations_defined,
    define_flat_file(locations,
                     path = path_results,
                     lat_variable = "lat",
                     long_variable = "long",
                     proj_args = proj_args_nad83),
    format = "file"
  ),

  # Project location, watershed, or flowline shapefile or accumulation grid as AEA or other
  tar_target(
    locations_projected,
    project_shapefile(locations_defined,
                      proj_args = proj_args_aea)
  ),
  tar_target(
    watersheds_projected,
    project_shapefile(watersheds,
                      proj_args = proj_args_aea),
    pattern = map(watersheds),
    iteration = "list"
  ),
  tar_target(
    flowlines_projected,
    project_shapefile(flowlines,
                      proj_args = proj_args_aea),
    pattern = map(flowlines),
    iteration = "list"
  ),
  tar_target(
    accumulations_projected,
    project_grid(accumulations,
                 path = path_data,
                 proj_args = proj_args_aea),
    pattern = map(accumulations),
    format = "file"
  ),

  # Produce shapefile of location points projected as AEA or other
  tar_target(
    locations_projected_shp,
    write_projected_shapefile(locations_projected,
                              file = locations_defined,
                              path = path_results),
    format = "file"
  ),

  # Classify accumulation grid cells less than or equal to threshold as non-stream
  tar_target(
    accumulations_classified,
    classify_grid(grid = accumulations_projected,
                  threshold = 100),
    pattern = map(accumulations_projected),
    format = "file"
  ),

  # Define streams from accumulation grid cells
  tar_target(
    streams_defined,
    define_grid(grid = accumulations_classified),
    pattern = map(accumulations_classified),
    format = "file"
  ),

  # Convert stream grid cells to points
  tar_target(
    streams_converted,
    convert_grid_point(grid = streams_defined,
                       path = path_results),
    pattern = map(streams_defined),
    iteration = "list"
  ),

  # Clip location points by watershed polygons
  tar_target(
    locations_clipped,
    clip_point_polygon(points = locations_projected,
                       polygons = watersheds_projected),
    pattern = map(watersheds_projected),
    iteration = "list"
  ),

  # Snap location points to stream points
  tar_target(
    locations_snapped_streams,
    snap_point_point(points = locations_clipped,
                     points2 = streams_converted,
                     buffer = 1000),
    pattern = map(locations_clipped, streams_converted),
    iteration = "list"
  ),

  # Snap location points to flowline lines
  tar_target(
    locations_snapped_flowlines,
    snap_point_line(points = locations_snapped_streams,
                    lines = flowlines_projected,
                    buffer = 5000),
    pattern = map(locations_snapped_streams, flowlines_projected),
    iteration = "list"
  ),

  # Produce shapefiles of locations points snapped to stream points or flowline lines
  tar_target(
    locations_snapped_streams_shp,
    write_snapped_shapefile(locations_snapped_streams,
                            file = locations_defined,
                            path = path_results),
    format = "file"
  ),
  tar_target(
    locations_snapped_flowlines_shp,
    write_snapped_shapefile(locations_snapped_flowlines,
                            file = locations_defined,
                            path = path_results),
    format = "file"
  ),

  # Extract accumulation grid at and within buffer around location points
  tar_target(
    accumulations_extracted_locations,
    extract_grid_point(grid = accumulations_classified,
                       points = locations_snapped_streams,
                       buffer = 50),
    pattern = map(accumulations_classified, locations_snapped_streams),
    iteration = "list"
  ),

  # Assess errors in snapping location points to stream points
  tar_target(
    snapping_errors_assessed,
    assess_snapping_errors(locations = locations_snapped_flowlines,
                           accumulations = accumulations_extracted_locations,
                           site_variable = "SiteName",
                           buffer = 100),
    pattern = map(locations_snapped_flowlines, accumulations_extracted_locations),
  ),

  # Produce flat file of errors assessed in snapping locations points to stream points
  tar_target(
    snapping_errors_assessed_csv,
    write_snapping_errors_flat_file(snapping_errors_assessed,
                                    file = locations_defined,
                                    path = path_results),
    format = "file"
  )
)
