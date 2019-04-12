library(bioRad)

setwd("C:/Users/mbradar/Documents/Weather_r/data/uk_test/")#set a directory where your files are
file <- dir(pattern = "*.h5")
pvol <- read_pvolfile("C:/Users/mbradar/Documents/Weather_r/data/uk_test/merged_odim.h5")
pvol$scans #print summary of the scans (scan parameters, how many bins and rays in each scan, 
#elevation angle of each scan)
pvol$radar[1] #radar name
pvol$datetime #nominal time
pvol$attributes # (lat, long, time, beam info,wavelength, height and bunch of info that you don't need)
pvol$geo

scan1 <- pvol$scans[[1]]
scan2 <- pvol$scans[[2]]
scan3 <- pvol$scans[[3]]
scan4 <- pvol$scans[[4]]
scan5 <- pvol$scans[[5]]

ppi1 <- project_as_ppi(scan1,range_max=100000)
ppi2 <- project_as_ppi(scan2,range_max=100000)
ppi3 <- project_as_ppi(scan3,range_max=100000)
ppi4 <- project_as_ppi(scan4,range_max=100000)
ppi5 <- project_as_ppi(scan5,range_max=100000)
comp <- composite_ppi(list(ppi1, ppi2,ppi3,ppi4,ppi5))

plot(ppi3,param="VRAD")

plot(comp)
plot(ppi1)
setwd("C:/radar_data/")
calculate_vp("C:/radar_data/uk_odim_pvol_noisetr_appl.h5","C:/radar_data/uk_odim_vp_noisetr_appl.h5" )
vp <- read_vpfiles("C:/Users/mbradar/Documents/uk_odim_vp_noisetr_appl.h5")
ts <- vpts(vp)
regts <- regularize_vpts(ts)
plot(regts)
plot(integrate_profile(regts))