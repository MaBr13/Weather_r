##########################################
#####Den helder comparison with OWEZ#####
##########################################

##Maja Bradaric, 06.07.2018, University of Amsterdam

library(bioRad)
checkDocker()

#read more pvols at once from one folder
setwd("C:/radar_data/2016a/10/07/18")#set a directory where your files are
listpvol <- dir(pattern = "*.h5") # creates the list of all the pvols in the directory
myFiles <- list.files(pattern=".*h5")#alternative
pvols <- lapply(listpvol, read.pvol)
#read more pvols at once from multiple folders
listmpvol <- dir("C:/Users/mbradar/Documents/test-dataset-judy/2016/10/07", 
                 recursive=TRUE, full.names=TRUE, pattern="\\.h5$")
pvols <- sapply(listmpvols, read_pvolfile)#using sapply here as it produces matrix instead of a list which lapply gives,
#which makes it easier for data manipulation later
#summaries of pvols
pvols[1] #print general summary of pvol(gives info on how many scans, radar name, nominal time)
pvols[[1]]$scans #print summary of the scans (scan parameters, how many bins and rays in each scan, 
#elevation angle of each scan)
pvols[[1]]$radar #radar name
pvols[[1]]$datetime #nominal time
pvols[[1]]$attributes # (lat, long, time, beam info,wavelength, height and bunch of info that you don't need)
pvols[[1]]$geo #lat, long and height
#extract scans from pvols
allscans <- sapply(pvols, "[[", "scans")#creats a list of scans
#extract parameters from scans 
params <- sapply(allscans,"[[","params")
#make a list of ppi's out of the scan list
ppis <- lapply(allscans, ppi)
plot(ppis[[1]])
#vol2bird automate
vols <- list() #prepare empty lists and vectors
datetime <- c()
names <- c()
radar <- c()
string <- c()


for (k in 1:length(listpvol)){#loop through the files
  string[[k]] <- pvols[[k]]$attributes$what$source
  radar[[k]] <- sapply(strsplit(string[[k]],"....:"),"[",2)
  
  datetime[k]<- paste0(format(pvols[[k]]$datetime, format="%Y%m%d"), 
                       "T",format(pvols[[k]]$datetime, format="%H%M" ),"Z")
  names[k] <- paste0(radar[k],"_vp_",datetime[k],".h5")
  vols[[k]] <- vol2bird(listpvol[k],names[k])
}

mypath <- "C:/test-dataset-judy/2016/10/07/23"
vps <- select_vpfiles(mypath, date_min="2016-10-07", date_max = "2016-10-07", country = c("nl"), radar=c("dbl"))

lvps <- read_vpfiles(vps)
ts <- vpts(lvps)
regts <- regularize_vpts(ts)
plot(regts)
plot(integrate_profile(regts))
