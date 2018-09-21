#####################################################
### function to plot different quantities of vp's ###
#####################################################
plot.vp.quant <- function(df, 
                          tmin_posix, tmax_posix, 
                          quantity, 
                          v.int.quantity,       #vertical integrated quantity (MTR etc)
                          v.dtime = 60,         #time is min to put a horizontal line
                          ylim.mtr = 5000,
                          save=c("on", "off"),
                          par=NULL,
                          pdf.width=7,
                          path=NULL
){
  
  if (save == "on"){
    name <- paste(df$radar, as.Date(tmin_posix), as.Date(tmax_posix), sep="_")
    pdf(paste(path, "/", name, ".pdf", sep=""), width=pdf.width)
  }
  
  if (is.null(par)==TRUE){
    quant.l <- length(c(quantity, v.int.quantity))
    #define arrangement of plots
    if (quant.l == 1){ 
      par(mfrow=c(1,1))
    } else if (quant.l == 2){
      par(mfrow=c(2,1))
    } else if (quant.l == 3 | quant.l == 4) {
      par(mfrow=c(2,2))
    } else if (quant.l == 5 | quant.l == 6){
      par(mfrow=c(3,2))
    } else if (quant.l == 7 | quant.l == 8){
      par(mfrow=c(4,2))
    }
  } else {
    par(mfrow=par)
  }
  
  #limit df
  df <- subset(df, df$dates >= tmin_posix & df$dates <= tmax_posix)
  
  #define vlines
  list.dt <- seq(tmin_posix, tmax_posix, by="min")
  ind <- seq(1,length(list.dt), by=v.dtime)
  
  if (is.null(length(quantity))==TRUE){
    #skip plotting
  }  else {
    #loop to make reflectivity plots
    for(i in 1:length(quantity)){
      par(mar=c(3,3,3,3))
      plot(df,
           quantity = quantity[i],
           sub=paste(df$radar, tmin_posix, tmax_posix, sep=" - "), #substr(df$attributes$what$source, 14, 18)
           ylim=c(0,4000)
      )
      abline(v=list.dt[ind], col="gray", h=seq(0,ylim.mtr, by=1000))
    }
  }
  if (is.null(length(v.int.quantity))==TRUE){
    #skip plotting
  } else {
    #loop to make v. integrated plots
    for(i in 1:length(v.int.quantity)){
      par(mar=c(2,2,2,2))
      plot(bioRad::vintegrate(df),
           quantity=v.int.quantity[i],
           sub=paste(df$radar, tmin_posix, tmax_posix, sep=" - "), #substr(df$attributes$what$source, 14, 18)
           ylim=c(0, ylim.mtr)
      )
      abline(v=list.dt[ind], col="gray", h=seq(0,ylim.mtr, by=1000))
    }
  }
  #save plots
  if (save=="on"){
    dev.off()
  }
}
