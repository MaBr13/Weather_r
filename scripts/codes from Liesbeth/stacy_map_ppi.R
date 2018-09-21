#needed in advance
Sys.setenv(TZ='UTC')
library(bioRad)
library(ggplot2)
source("./FUN_eemshaven.R")

#read paths to where pvols are stored; put outcome in a list
path2pvols <- dir("./path/to/data/", recursive = TRUE, full.names = TRUE) 
#read in pvols
list.pvol <- lapply(path2pvols, read_pvolfile_liz)
#extract scans (here 2nd, but you can adjust this)
list.scans <- lapply(list.pvol, function(x) x$scans[[2]])
#following code only if you load in a lot of pvols. They take up lots of memory, so I remove them and then reboot R to delete them from memory
rm(list.pvol)
#reboot r session manually (Session > Restart R)
#project all scans as ppi's
list.ppis <- lapply(list.scans, project_as_ppi, range.max=50000, cellsize=500)
#download the background map. see ?download_basemap for more information what you can adjust
bm <- download_basemap(list.ppis[[1]], source="stamen", maptype="toner-background", alpha=0.7)
#map ppi's and save as png
lapply(list.ppis[1], map_ppi, map=bm, param="DBZ", radar="emd", path2plots="./path/to/folder/")