#####################################################
##########Fine-scale movement exp analysis###########
################Data preparation#####################
#####################################################

#Maja Bradaric,08/01/2020, University of Amsterdam

library(bioRad)
library(tidyverse)
check_docker()

Sys.setenv(TZ="UTC")

###try to use regular vp to see if we can spot changes
mypath <- "C:/Users/mbradar/Documents/Weather_r/data/Dutch_data/vp/DHL"
vvps <- select_vpfiles(date_min="2018-09-20", date_max = "2018-09-21",radars = "NLDHL",directory = mypath)

vps <- read_vpfiles(vvps)
ts <- bind_into_vpts(vps)#bind into vertical profile time series
dfvps <- as.data.frame(ts)#convert vertical profile time series into a data frame
dfvps1 <- dfvps[,c(2:4,6:8,12,23:24)]
dfvps1 <- na.omit(dfvps1)
dfvps1$trdir_deg <- ifelse(dfvps1$dd<180, 180+dfvps1$dd, 360-dfvps1$dd)#to change direction into the one that birds are going to
dfvps1$trdir_rad <- dfvps1$trdir_deg*(pi/180)#convert to radians

dfs <- split(dfvps1,dfvps1$height,drop = TRUE)#split vps based on height, results is a list
dfs <- dfs[lengths(dfs) > 0]
dfs <- Filter(function(x) dim(x)[1] > 1, dfs)
dum <- list()
for (k in 1:length(dfs)){
  dfs[[k]] <- subset(dfs[[k]],datetime>=dfvps1$sunset[1]-3600 & datetime<=sunrise[1]+90000) 
  dfs[[k]]$dum <- seq(1,nrow(dfs[[k]]),1)
  dum[[k]] <- as.vector(unlist(subset(dfs[[k]],datetime>=dfvps1$sunset[1] & datetime<=dfvps1$sunrise[1]+86400, select= dum )))
}


windows(20,5)
for(k in 1:length(dfs)){
  alts <- paste0(dfs[[k]]$height[1])
  datetime <- paste0(format(dfs[[k]]$datetime[1], format="%Y%m%d"))
  name <- paste("trdir","_", datetime ,"_",alts, ".png")
  windows(20,5)
  #png(filename=paste0("C:/Users/mbradar/Documents/Weather_r/plots/",name),width=1000,height = 200)
  feather.plot2(dfs[[k]]$dens,dfs[[k]]$trdir_rad,colour = "black",xlabels = strftime(dfs[[k]]$datetime,format = "%H:%M:%S"))
  rect(dum[[k]][1],-100,tail(dum[[k]],n=1),100,col = rgb(0.5,0.5,0.5,1/4),border = NA)
  savePlot(filename=paste0("C:/Users/mbradar/Documents/Weather_r/plots/",name),type = "png")
  dev.off()
}




datetime <- paste0(format(dfs[[k]]$datetime[1], format="%Y%m%d"))
pdf(file="C:/Users/mbradar/Documents/Weather_r/plots/check2.pdf")
par(mfrow=c(3,1))

for (k in 1:length(im)){
  windows(20,5)
  plot(as.raster(im[k]))
  dev.off()
}
dev.off()

for(k in 1:length(dfs)){
 alts <- paste0(dfs[[k]]$height[1])
 datetime <- paste0(format(dfs[[k]]$datetime[1], format="%Y%m%d %H:%M:%S"))
 name <- paste("trdir","_", datetime ,"_",alts, ".png")
 feather.plot2(dfs[[k]]$dens,dfs[[k]]$trdir_rad,colour = "black",xlabels = strftime(dfs[[k]]$datetime,format = "%H:%M:%S"),main = name)
 rect(dum[[k]][1],-100,tail(dum[[k]],n=1),100,col = rgb(0.5,0.5,0.5,1/4),border = NA)
 
}
dev.off()
dev.off()
ggplot(data=dfvsp400,aes(x=dfvsp400$datetime,y=dfvsp400$dum)) +
      geom_segment(aes(x=dfvsp400$datetime,xend=dfvsp400$datetime,y=rep(0,nrow(dfvsp400)),yend=dfvsp400$dum),arrow=arrow(angle=dfvsp400$dd,length = unit(0.3, "cm")))
