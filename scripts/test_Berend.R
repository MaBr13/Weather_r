##########################################
#####Den helder comparison with OWEZ#####
##########################################

##Maja Bradaric, 06.07.2018, University of Amsterdam
rm(list=ls())
library(bioRad)
library(ggmap)
library(tidyverse)
check_docker()
memory.size(max=80000)
#216:360
#read more pvols at once from one folder
setwd("C:/Users/mbradar/Documents/Weather_r/data/UK_data/pvol/DHL/2018/04/15")
setwd("D:/weather_r/data/UK_data/pvol/THU/2019/04/16")#set a directory where your files are
listpvol <- dir(pattern = "*.h5") # creates the list of all the pvols in the directory
myFiles <- list.files(pattern=".*h5")#alternative
pvols1 <- lapply(listpvol[1], read_pvolfile)
library(beepr)
beep()
#read more pvols at once from multiple folders
listmpvol <- dir("C:/Users/mbradar/Documents/test-dataset-judy/2016/10/07", 
                 recursive=TRUE, full.names=TRUE, pattern="\\.h5$")
pvols <- sapply(listmpvols, read_pvolfile)#using sapply here as it produces matrix instead of a list which lapply gives,
#which makes it easier for data manipulation later
#summaries of pvols
pvols[5] #print general summary of pvol(gives info on how many scans, radar name, nominal time)
pvols1[[2]]$scans#print summary of the scans (scan parameters, how many bins and rays in each scan, 
#elevation angle of each scan)
pvols[[1]]$radar #radar name
pvols[[1]]$datetime #nominal time
pvols[[1]]$attributes # (lat, long, time, beam info,wavelength, height and bunch of info that you don't need)
pvols[[1]]$geo #lat, long and height
#extract scans from pvols
allscans <- lapply(pvols1, get_scan, elev=3)#creats a list of scans
allscans <- sapply(allscans1,function(x) x[1:16])
allscans <- allscans %>% discard(is.null)
#extract parameters from scans 
params <- sapply(allscans,"[[","params")
#make a list of ppi's out of the scan list
ppis <- lapply(allscans, project_as_ppi)
ppis <- list()

plot(ppis[[9]],param="VRAD")
register_google(key = "AIzaSyC-bw1FEcHmDesL-zAPgW9RaWwolld2gRw")
bmap=download_basemap(ppis[[1]])
for (k in 1:length(ppis)){
  el <- paste0(ppis[[k]]$geo$elangle)
  datetime <- paste0(format(ppis[[k]]$datetime, format="%Y%m%d"), "T",format(ppis[[k]]$datetime, format="%H%M"))
  name <- paste("DHL","_", datetime ,"_",el, ".png")
  png(filename=paste0("D:/weather_r/plots/",name), width = 1000, height = 1000, units = "px")
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
library(magick)
setwd("D:/weather_r")
imgs <- list.files(pattern="*_ 2 .png")
ffmpeg <- ani.options(ffmpeg="C:/Program Files/ffmpeg/bin/ffmpeg.exe")
saveVideo({#for gif, use saveGIF functionm and change video.name to movie.name, and lose width and height pars
  for(img in imgs){
    im <- magick::image_read(img)
    
    plot(as.raster(im))
  }  
},video.name = "test_dbzh_2.mp4",interval=.1,ani.width=600,ani.height=600)


anim <- animate(plots)
anim_save(anim,path="C:/Users/mbradar/Documents/Weather_r/plots/UK_test")
comp <- composite_ppi(ppis)
bmap <- download_basemap(comp)
map(comp, bmap)

#################################################################################
###########################vol2bird automate#####################################
#################################################################################



#if there are new months to start in a year
for (k in 1:12){
  if(k>1 & k<=9){
  dir.create(paste0("D:/weather_r/data/Dutch_data/vp/DHL/water/2019/","0",paste0(k)))
  }else{
    dir.create(paste0("D:/weather_r/data/Dutch_data/vp/DHL/water/2019/", paste0(k)))
  }
}        


vols <- list() #prepare empty lists and vectors
datetime <- c()
names <- c()
string <- pvols1[[1]]$attributes$what$source
#radar <- sapply(strsplit(string,"....:"),"[",2)
radar <- "ukthu"
radar <- toupper(radar)

folder <- paste0("D:/weather_r/data/UK_data/vp/THU/water/",paste0(format(pvols1[[1]]$datetime,format="%Y")),"/",
                 paste0(format(pvols1[[1]]$datetime,format="%m")),"/",paste0(format(pvols1[[1]]$datetime,format="%d")),"/")
dir.create(folder)

#for DHL water is >200  <=340 degress, land > 340 and <=200
for (k in 1:length(listpvol)){#loop through the files
  datetime[k]<- gsub(paste0(radar,"_pvol_"),'',listpvol[k])
  names[k] <- paste0(radar,"_vp_",datetime[k])
  vols[[k]] <- calculate_vp(listpvol[k],paste0(folder,names[k]),elev_min= 0.5 ,azim_min = 33, 
                            azim_max = 72, range_min=28000, range_max = 45000, n_layer = 25)#range max and n_layer to correspond
                                                                            #vol2bird version that was used in MiniO
}
beep()
setwd("D:/weather_r/data/Belgium/vp1/Jab/sea/2018/10/19")
mypath <- "D:/weather_r/data/Dutch_data/vp/DHL/water/2019/10"
vps <- dir(pattern = "*.h5")
vps <- select_vpfiles(mypath, date_min="2019-10-28", date_max = "2019-10-29", radars = c("nldhl","NLDHL"))

lvps <- read_vpfiles(vps[216:360])
ts <- bind_into_vpts(lvps)
regts <- regularize_vpts(ts,interval = 15, units = "mins")
plot.vpts(regts, barbs_height = 24,barbs_time = 43500,barbs_dens_min = 0)
plot(regts, quantity='dens')
p <- plot(integrate_profile(regts),quantity="vid")

index_duplicates <- which(ts$timesteps == 0) + 1
difftimes <- difftime(datetime[-1], datetime[-length(datetime)], units = "secs")