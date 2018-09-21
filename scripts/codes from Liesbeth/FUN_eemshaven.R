######################################################
### adjusted read_pvolfile function to include DBZ ###
######################################################
read_pvolfile_liz <-function (filename, param = c("DBZ","DBZH", "VRADH", "VRAD", "RHOHV", 
                              "ZDR", "PHIDP", "CELL"), sort = TRUE, lat, lon, height, elangle.min = 0, 
          elangle.max = 90, verbose = TRUE, mount = dirname(filename)) 
{
  if (!is.logical(sort)) {
    stop("'sort' should be logical")
  }
  if (!missing(lat)) {
    if (!is.numeric(lat) || lat < -90 || lat > 90) {
      stop("'lat' should be numeric between -90 and 90 degrees")
    }
  }
  if (!missing(lon)) {
    if (!is.numeric(lon) || lat < -360 || lat > 360) {
      stop("'lon' should be numeric between -360 and 360 degrees")
    }
  }
  if (!missing(height)) {
    if (!is.numeric(height) || height < 0) {
      stop("'height' should be a positive number of meters above sea level")
    }
  }
  cleanup <- FALSE
  if (rhdf5:::H5Fis_hdf5(filename)) {
    if (!is.pvolfile(filename)) {
      stop("Failed to read hdf5 file.")
    }
  }
  else {
    if (verbose) {
      cat("Converting using Docker...\n")
    }
    if (!.pkgenv$docker) {
      stop("Requires a running Docker daemon.\nTo enable, start your", 
           "local Docker daemon, and run 'check_docker()' in R\n")
    }
    filename <- nexrad_to_odim_tempfile(filename, verbose = verbose, 
                                        mount = mount)
    if (!is.pvolfile(filename)) {
      file.remove(filename)
      stop("converted file contains errors")
    }
    cleanup <- TRUE
  }
  scans <- rhdf5:::h5ls(filename, recursive = FALSE)$name
  scans <- scans[grep("dataset", scans)]
  elevs <- sapply(scans, function(x) {
    rhdf5:::h5readAttributes(filename, paste(x, "/where", sep = ""))$elangle
  })
  scans <- scans[elevs >= elangle.min & elevs <= elangle.max]
  h5struct <- rhdf5:::h5ls(filename)
  h5struct <- h5struct[h5struct$group == "/", ]$name
  attribs.how <- attribs.what <- attribs.where <- NULL
  if ("how" %in% h5struct) {
    attribs.how <- rhdf5:::h5readAttributes(filename, "how")
  }
  if ("what" %in% h5struct) {
    attribs.what <- rhdf5:::h5readAttributes(filename, "what")
  }
  if ("where" %in% h5struct) {
    attribs.where <- rhdf5:::h5readAttributes(filename, "where")
  }
  vol.lat <- attribs.where$lat
  vol.lon <- attribs.where$lon
  vol.height <- attribs.where$height
  if (is.null(vol.lat)) {
    if (missing(lat)) {
      if (cleanup) {
        file.remove(filename)
      }
      stop("latitude not found in file, provide 'lat' argument")
    }
    else {
      vol.lat <- lat
    }
  }
  if (is.null(vol.lon)) {
    if (missing(lon)) {
      if (cleanup) {
        file.remove(filename)
      }
      stop("longitude not found in file, provide 'lon' argument")
    }
    else {
      vol.lon <- lon
    }
  }
  if (is.null(vol.height)) {
    if (missing(height)) {
      if (cleanup) {
        file.remove(filename)
      }
      stop("antenna height not found in file, provide 'height' argument")
    }
    else {
      vol.height <- height
    }
  }
  geo <- list(lat = vol.lat, lon = vol.lon, height = vol.height)
  datetime <- as.POSIXct(paste(attribs.what$date, attribs.what$time), 
                         format = "%Y%m%d %H%M%S", tz = "UTC")
  sources <- strsplit(attribs.what$source, ",")[[1]]
  radar <- gsub("RAD:", "", sources[which(grepl("RAD:", sources))])
  data <- lapply(scans, function(x) {
    bioRad:::read_pvolfile_scan(filename, x, param, radar, datetime, 
                       geo)
  })
  if (sort) {
    data <- data[order(sapply(data, get_elevation_angles))]
  }
  output <- list(radar = radar, datetime = datetime, scans = data, 
                 attributes = list(how = attribs.how, what = attribs.what, 
                                   where = attribs.where), geo = geo)
  class(output) <- "pvol"
  if (cleanup) {
    file.remove(filename)
  }
  output
}


###################################
### simple functio to map a ppi ###
###################################
map_ppi <- function(ppi, map, param="DBZ", radar=c("emd","abs"), path2plots){
  datetime <- paste0(format(ppi$datetime, format="%Y%m%d"), "T",format(ppi$datetime, format="%H%M"))
  name <- paste(radar,"_", datetime , ".png")
  png(filename=paste0(path2plots, name), width = 1000, height = 1000, units = "px")
  print(
    map(ppi, map=bm, param="DBZ") +
      labs(title=ppi$datetime,x="Longitude",y="Latitude") +
      theme(text = element_text(size = rel(5)), 
            plot.title = element_text(size = rel(5)), 
            legend.text = element_text(size=rel(3))
      )
  )
  dev.off()
} 
