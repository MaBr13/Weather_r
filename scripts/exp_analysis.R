#####################################################
##########Fine-scale movement exp analysis###########
################Data preparation#####################
#####################################################

#Maja Bradaric,08/01/2020, University of Amsterdam

library(bioRad)
library(tidyverse)
library(purrr)
check_docker()

Sys.setenv(TZ="UTC")

###try to use regular vp to see if we can spot changes
mypath <- "D:/weather_r/data/Dutch_data/vp/DHL/water/2018"
vvps <- select_vpfiles(date_min="2018-09-25", date_max = "2018-10-29",radars = "nldhl",directory = mypath)

vps <- read_vpfiles(vvps)
ts <- bind_into_vpts(vps)#bind into vertical profile time series
dfvps <- as.data.frame(ts)#convert vertical profile time series into a data frame
dfvps1 <- dfvps[,c(2:4,6:8,12,23:24)]
dfvps1 <- na.omit(dfvps1)
dfvps1 <- dfvps1[dfvps1$dens != 0, ]
dfvps1$trdir_deg <- ifelse(dfvps1$dd<180, 180+dfvps1$dd, 180-(360-dfvps1$dd))#to change direction into the one that birds are going to
dfvps1$trdir_rad <- dfvps1$dd*(pi/180)#convert to radians

dfs <- split(dfvps1,dfvps1$height,drop = TRUE)#split vps based on height, results is a list
dfs <- lapply(dfs,subset,datetime>=dfvps1$sunset[1]-3600 & datetime<=dfvps1$sunrise[1]+90000)
dfs <- dfs[map(dfs, function(x) dim(x)[1]) > 1]
final <- do.call(rbind, dfs)

dum <- list()
for (k in 1:length(dfs)){
  dfs[[k]]$dum1 <- rep(1,nrow(dfs[[k]]))
  dfs[[k]]$dum <- seq(1,nrow(dfs[[k]]),1)
  dum[[k]] <- as.vector(unlist(subset(dfs[[k]],datetime>=dfvps1$sunset[1] & datetime<=dfvps1$sunrise[1]+86400, select= dum )))
}

for (k in 1:length(dfs)){
  dfs[[k]]$Colour[dfs[[k]]$dens>=0 & dfs[[k]]$dens<=50]="#67a9cf"
  dfs[[k]]$Colour[dfs[[k]]$dens>50 & dfs[[k]]$dens<=100]="#1c9099"
  dfs[[k]]$Colour[dfs[[k]]$dens>100 & dfs[[k]]$dens<=150]="#253494"
  dfs[[k]]$Colour[dfs[[k]]$dens>150 & dfs[[k]]$dens<=200]="#006837"
  dfs[[k]]$Colour[dfs[[k]]$dens>250 & dfs[[k]]$dens<=300]="#31a354"
  dfs[[k]]$Colour[dfs[[k]]$dens>300 & dfs[[k]]$dens<=350]="#78c679"
  dfs[[k]]$Colour[dfs[[k]]$dens>350 & dfs[[k]]$dens<=400]="#fed98e"
  dfs[[k]]$Colour[dfs[[k]]$dens>400 & dfs[[k]]$dens<=450]="#fe9929"
  dfs[[k]]$Colour[dfs[[k]]$dens>450 & dfs[[k]]$dens<=500]="#f03b20"
  dfs[[k]]$Colour[dfs[[k]]$dens>500]="#bd0026"
}
  

for(k in 1:length(dfs)){
  alts <- paste0(dfs[[k]]$height[1])
  datetime <- paste0(format(dfs[[k]]$datetime[1], format="%Y%m%d"))
  name <- paste("trdir","_", datetime ,"_",alts, ".png")
  windows(20,5)
  #png(filename=paste0("C:/Users/mbradar/Documents/Weather_r/plots/",name),width=1000,height = 200)
  if(is_empty(dum[[k]])){ #added to avoid plotting the "night time" if all the values are outside of that time frame
    feather.plot2(dfs[[k]]$ff,dfs[[k]]$trdir_rad,colour = dfs[[k]]$Colour,xlabels = strftime(dfs[[k]]$datetime,format = "%H:%M:%S"),fp.type = "m")
    legend("bottomright",cex=0.5,fill=c("#67a9cf","#1c9099","#253494","#006837","#31a354","#78c679","#fed98e","#fe9929","#f03b20","#bd0026"),
           legend=c("0-50","50-100","100-150","150-200","200-250","250-300","300-350","350-400","400-450","450-500"), col=dfs[[k]]$Colour,title = "Density Nr.birds/km3",horiz = TRUE)
  }else{
    feather.plot2(dfs[[k]]$ff,dfs[[k]]$trdir_rad,colour = dfs[[k]]$Colour,xlabels = strftime(dfs[[k]]$datetime,format = "%H:%M:%S"),fp.type = "m")
    rect(dum[[k]][1],-100,tail(dum[[k]],n=1),100,col = rgb(0.2,0.2,0.2,1/10),border = NA)
    legend("bottomright",cex=0.5,fill=c("#67a9cf","#1c9099","#253494","#006837","#31a354","#78c679","#fed98e","#fe9929","#f03b20","#bd0026"),
           legend=c("0-50","50-100","100-150","150-200","200-250","250-300","300-350","350-400","400-450","450-500"), col=dfs[[k]]$Colour,title = "Density Nr.birds/km3",horiz = TRUE)
  }
  savePlot(filename=paste0("C:/Users/mbradar/Documents/Weather_r/plots/",name),type = "png")
  dev.off()
}




datetime1 <- paste0(format(dfs[[1]]$datetime[1], format="%Y%m%d"))
name1 <- paste("nightly_directions","_", datetime1, ".pdf")
pdf(file=paste0("C:/Users/mbradar/Documents/Weather_r/plots/",name1))
par(mfrow=c(3,1))
for(k in 1:length(dfs)){
 alts <- paste0(dfs[[k]]$height[1])
 datetime <- paste0(format(dfs[[k]]$datetime[1], format="%Y%m%d"))
 name <- paste("trdir","_", datetime ,"_",alts, ".png")
 if(is_empty(dum[[k]])){ #added to avoid plotting the "night time" if all the values are outside of that time frame
   feather.plot2(dfs[[k]]$ff,dfs[[k]]$trdir_rad,colour = dfs[[k]]$Colour,xlabels = strftime(dfs[[k]]$datetime,format = "%H:%M:%S"), fp.type = "m", main=name)
   legend("bottomright",cex=0.5,fill=c("#67a9cf","#1c9099","#253494","#006837","#31a354","#78c679","#fed98e","#fe9929","#f03b20","#bd0026"),
          legend=c("0-50","50-100","100-150","150-200","200-250","250-300","300-350","350-400","400-450","450-500"), col=dfs[[k]]$Colour,title = "Density Nr.birds/km3",horiz = TRUE)
 }else{
   feather.plot2(dfs[[k]]$ff,dfs[[k]]$trdir_rad,colour = dfs[[k]]$Colour,xlabels = strftime(dfs[[k]]$datetime,format = "%H:%M:%S"), fp.type = "m", main=name)
   rect(dum[[k]][1],-100,tail(dum[[k]],n=1),100,col = rgb(0.2,0.2,0.2,1/4),border = NA)
   legend("bottomright",cex=0.5,fill=c("#67a9cf","#1c9099","#253494","#006837","#31a354","#78c679","#fed98e","#fe9929","#f03b20","#bd0026"),
          legend=c("0-50","50-100","100-150","150-200","200-250","250-300","300-350","350-400","400-450","450-500"), col=dfs[[k]]$Colour,title = "Density Nr.birds/km3",horiz = TRUE)
 }
 
}
dev.off()

regts <- regularize_vpts(ts)
windows(20,15)
plot(regts,main=datetime1,barbs = F)
savePlot(filename=paste0("D:/weather_r/plots/water/alt_dens_",datetime1),type = "png")
dev.off()
