#set time zone of working environment to the same as the bird profile data
Sys.setenv(TZ='UTC')

#load required library
library(bioRad)
#load in function
source("PATH/TO/plot.vp.quant.R")

#set time stamp
tmin.posix <- as.POSIXct("2016-10-05 12:00", format="%Y-%m-%d %H:%M", tz="UTC", origin="1970-01-01 00:00")
tmax.posix <- as.POSIXct("2016-10-10 12:00", format="%Y-%m-%d %H:%M", tz="UTC", origin="1970-01-01 00:00")

#plot
plot.vp.quant(df=regts,                       ##regular timeserie of bird profiles
              tmin_posix = tmin.posix, tmax_posix = tmax.posix, ##start and end time of the time frame you want to plot
              quantity = c("dens","DBZH"),    ##quantity you want to plot (see ?plot.vpts)
              v.dtime = 60*6,                 ##vertical lines in plot, needs to be a multiple of 60 (so here you'll have a vertical line every 6 hours)
              par=c(3,1),                     ##organization of the plots: c(number of rows, number of columns), so here 3 rows and 1 column
              v.int.quantity = c("mtr"),      ##plot integrated quantities (see ?vintegrate)
              ylim.mtr = 12000,               ##maximum of y-axis of the MTR plot
              save=FALSE,                     ##when TRUE, the plot will be saved
              path="PATH/TO/LOCATION/") ##location where you want to have the plot saved
