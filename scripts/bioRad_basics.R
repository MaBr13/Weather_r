#loading the package
require(bioRad)

#making vol2bird possible to work
checkDocker()

#locate example volume file
getwd()

pvol1 <- "C:/Users/mbradar/Documents/test-dataset-judy/2016/10/07/17/nldbl_pvol_20161007T1700Z.h5"
pvol2 <- "C:/Users/mbradar/Documents/test-dataset-judy/2016/10/07/17/nldbl_pvol_20161007T1715Z.h5"

#all the stuff you can find out from different summary tables of one pvol

vol1 <- read.pvol(pvol1) #load the file (polar volume)
vol2 <- read.pvol(pvol2)
vol2 #print general summary of pvol(gives info on how many scans, radar name, nominal time)
vol$scans #print summary of the scans (scan parameters, how many bins and rays in each scan, elevation angle of each scan)
vol2$radar #radar name
vol$datetime #nominal time
vol$attributes # (lat, long, time, beam info,wavelength, height and bunch of info that you don't need)
vol$geo #lat, long and height

#make separate objects for separate scans (fixed elevation and polar coordinates)
scan1 <- vol1$scans[[1]]
scan2 <- vol1$scans[[2]]
scan3 <- vol1$scans[[3]]
scan4 <- vol1$scans[[4]]

scan5 <- vol2$scans[[1]]
scan6 <- vol2$scans[[2]]
scan7 <- vol2$scans[[3]]
scan8 <- vol2$scans[[4]]

scan1$params
scan1$attributes #(are the random numbers all the coordinates caught by one scan)
scan1$geo #lat, lon, height, el angle, r scale, a scale


#make plan position indicator (ppi) - representation of radar data on Cartesian grid
ppi1 <- ppi(scan1, range.max = 100000) 
ppi2 <- ppi(scan2, range.max = 100000)
ppi3 <- ppi(scan3)
ppi4 <- ppi(scan4)
ppi5 <- ppi(scan5)
ppi6 <- ppi(scan6)
ppi7 <- ppi(scan7)
ppi8 <- ppi(scan8)


ppi1
param1 <- scan1$params[[1]] #question about different parameters, do we use them at all?? or just 1st and second (default)
param1
ppi1p <- ppi(param1)
ppi1p

plot(ppi8)
plot(ppi1p)

comp <- composite(list(ppi1,ppi2))
plot(comp)
bmap <- basemap(comp)
map(comp,bmap)

#make a vertical bird profile

prof <- system.file("extdata", "profile.h5", package="bioRad")

prof <- system.file("C:Users/mbradar/test-dataset-judy/2016","profile.h5")


##bird profiles: vp##
#retrieve vp locations
retrieve_vp_paths(path="C:/Users/mbradar/Documents/test-dataset-judy/2016/", start_date = "2016-10-07", end_date = "2016-10-07", country = c("nl"))

#read vp's
readvp.list()

#put in ts
ts <- vpts(list.vp[[1]])
#make regular time series
regts <- regularize(ts)
#plot
plot(regts)
plot(vintegrate(regts))
