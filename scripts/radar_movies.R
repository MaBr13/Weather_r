rm(list=ls())
library(animation)
library(magick)
setwd("D:/weather_r/plots/integrate/spring2")
imgs <- list.files(pattern="*.png")
ffmpeg <- ani.options(ffmpeg="C:/Program Files/ffmpeg/bin/ffmpeg.exe")
saveVideo({#for gif, use saveGIF functionm and change video.name to movie.name, and lose width and height pars
  for(img in imgs){
    im <- magick::image_read(img)
    
    plot(as.raster(im))
  }  
},video.name = "vid_integrated.mp4",interval=.5,ani.width=1000,ani.height=1000)



library(magick)
library(magrittr)
setwd("D:/weather_r/plots/integrate/20190418")
list.files(path="D:/weather_r/plots/integrate/20190418", pattern = '*.png', full.names = TRUE) %>% 
  image_read() %>% # reads each path file
  image_join() %>% # joins image
  #image_animate() %>% # animates, can opt for number of loops
  image_write_video("20190418.mp4",framerate = 3) # write to current dir

library(av)
av::av_encode_video(imgs, 'D:/weather_r/plots/integrate/autumn1/output.mp4', framerate = 1)
                  
httr::with_verbose(exists_ret = aws.s3::head_object(bucket = "exppvol",
object = "long_pulse/UK/CHE/2019/04/07/UKCHE_pvol_20190407T2010_03675.h5",
use_https = T,
check_region = F,
base_url = "fnwi-s0.science.uva.nl:9001")
)