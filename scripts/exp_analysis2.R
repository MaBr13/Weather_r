rm(list=ls())
library(bioRad)
library(ggmap)
register_google()
library(tidyverse)
check_docker()
memory.size(max=80000)



# ----
setwd("D:/weather_r/data/UK_data/pvol/CHE/2019/04/19")#set a directory where your files are
listpvol <- dir(pattern = "*.h5") # creates the list of all the pvols in the directory
pvol <- lapply(listpvol[2], read_pvolfile)
setwd("D:/weather_r/data/Belgium/pvol/Jab/2018/03/10")
listvp <- dir(pattern="*.h5")
vps <- lapply(listvp[144:288],read_vpfiles)

my_ppi <- list()
for(k in 1:length(pvols)){
  my_ppi[[k]] <- integrate_to_ppi(pvols[[k]],vps[[k]],res=1000)
}


bm <- download_basemap(my_ppi[[1]],maptype="satellite",source = "google")

for (k in 1:length(my_ppi)){
  datetime <- paste0(format(my_ppi[[k]]$datetime, format="%Y%m%d"), "T",format(my_ppi[[k]]$datetime, format="%H%M"))
  name <- paste("DHL_",datetime,"_integrated", ".png")
  if(is.na(my_ppi[[k]]$data$vid)){
    windows(7,7)
    print(
    plot(bm,main=datetime)
    )
    savePlot(filename=paste0("D:/weather_r/plots/UK_plots/",name),type = "png")
    dev.off()
  }else{
  windows(7,7)
  print(
  bioRad::map(my_ppi[[k]],bm,param="vid",alpha=0.5)+
    ggtitle(datetime)
  )
  savePlot(filename=paste0("D:/weather_r/plots/UK_plots/",name),type = "png")
  dev.off()
  }
}


