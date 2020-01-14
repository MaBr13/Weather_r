##########################################
#####Den helder comparison with OWEZ#####
##########################################

##Maja Bradaric, 06.07.2018, University of Amsterdam

library(bioRad)
library(ggmap)
library(tidyverse)
check_docker()
#216:360
#read more pvols at once from one folder
setwd("C:/Users/mbradar/Documents/Weather_r/data/Norwegian_data/pvol/2018/03/11")
setwd("C:/Users/mbradar/Documents/Weather_r/data/uk_test/UKCHE/short/10/pvol")#set a directory where your files are
listpvol <- dir(pattern = "*.h5") # creates the list of all the pvols in the directory
myFiles <- list.files(pattern=".*h5")#alternative
pvols1 <- lapply(listpvol[1:144], read_pvolfile)
#read more pvols at once from multiple folders
listmpvol <- dir("C:/Users/mbradar/Documents/test-dataset-judy/2016/10/07", 
                 recursive=TRUE, full.names=TRUE, pattern="\\.h5$")
pvols <- sapply(listmpvols, read_pvolfile)#using sapply here as it produces matrix instead of a list which lapply gives,
#which makes it easier for data manipulation later
#summaries of pvols
pvols[5] #print general summary of pvol(gives info on how many scans, radar name, nominal time)
pvols[[2]]$scans#print summary of the scans (scan parameters, how many bins and rays in each scan, 
#elevation angle of each scan)
pvols[[1]]$radar #radar name
pvols[[1]]$datetime #nominal time
pvols[[1]]$attributes # (lat, long, time, beam info,wavelength, height and bunch of info that you don't need)
pvols[[1]]$geo #lat, long and height
#extract scans from pvols
allscans1 <- lapply(pvols1, "[[", "scans")#creats a list of scans
allscans <- sapply(allscans1,function(x) x[1:16])
allscans <- allscans %>% discard(is.null)
#extract parameters from scans 
params <- sapply(allscans,"[[","params")
#make a list of ppi's out of the scan list
ppis <- lapply(allscans, project_as_ppi)
plot(ppis[[9]],param="VRAD")
register_google(key = "AIzaSyC-bw1FEcHmDesL-zAPgW9RaWwolld2gRw")
bmap=download_basemap(ppis[[1]])
for (k in 1:length(ppis)){
  el <- paste0(ppis[[k]]$geo$elangle)
  datetime <- paste0(format(ppis[[k]]$datetime, format="%Y%m%d"), "T",format(ppis[[k]]$datetime, format="%H%M"))
  name <- paste("ROM","_", datetime ,"_",el, ".png")
  png(filename=paste0("C:/Users/mbradar/Documents/Weather_r/plots/NW_test_",name), width = 1000, height = 1000, units = "px")
  print(
   plot(ppis[[k]],param="DBZH") +
      labs(title=ppis[[k]]$datetime,x="Longitude",y="Latitude") +
      theme(text = element_text(size = rel(5)), 
            plot.title = element_text(size = rel(5)), 
            legend.text = element_text(size=rel(3))
      )
  )
  dev.off()
}

library(animation)
setwd("C:/Users/mbradar/Documents/Weather_r/plots/DK_test")
imgs <- list.files(pattern="*_0.96.png")
ffmpeg <- ani.options(ffmpeg="C:/Program Files/ffmpeg/bin/ffmpeg.exe")
saveVideo({#for gif, use saveGIF functionm and change video.name to movie.name, and lose width and height pars
  for(img in imgs){
    im <- magick::image_read(img)
    
    plot(as.raster(im))
  }  
},video.name = "test_dbzh_2.mp4",interval=.1,ani.width=1000,ani.height=1000)



anim <- animate(plots)
anim_save(anim,path="C:/Users/mbradar/Documents/Weather_r/plots/UK_test")
comp <- composite_ppi(ppis)
bmap <- download_basemap(comp)
map(comp, bmap)
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
  vols[[k]] <- calculate_vp(listpvol[k],names[k],elev_max=40,range_max = 40000,h_layer=400,nyquist_min = 4)
}

setwd("C:/Users/mbradar/Documents/Weather_r/data/Norwegian_data/vp/2018/03/10")
mypath <- "C:/Users/mbradar/Documents/Weather_r/data/Norwegian_data/vp/2018/03/10"
vps <- dir(pattern = "*.h5")
vps <- select_vpfiles(mypath, date_min="2018-03-10", date_max = "2018-03-10", country = c("NO"), radar=c("BML"))

lvps <- read_vpfiles(vps)
ts <- bind_into_vpts(lvps)
regts <- regularize_vpts(ts)
plot(regts)
plot(regts, quantity='dens')
plot(integrate_profile(regts),quantity="vid")


