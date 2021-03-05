require(gsheet)
require(uvaRadar)
require(mapview)
require(leaflet)
require(magrittr)
require(lubridate)
require(bioRad)

toRun<-data.frame(radar_code='ukthu',representative_timestamp=c(
                                                               '2019-04-15 22:02:00',
                                                                '2019-04-16 22:02:00',
                                                                '2019-04-17 22:02:00'))
pdf <-
  data.frame(
    min = c(-10, 10, 0),
    max = c(40, 10, 1),
    sym = c(F, T, F),
    par = I(list(
      c('TH', 'DBZ', 'DBZH'),
      c('VRAD','WRAD', 'VRADH', 'ZDR', 'PHIDP'),
      'RHOHV'
    ))
  )

for (i in 1:nrow(toRun)) { # loop over pvols of interest
  pvol <-
    get_pvol(odim_to_radar(toRun$radar_code[i]),
             floor_date(
               as.POSIXct(toRun$representative_timestamp[i], tz = 'UTC'),
               'mins'
             ),
             prefix = 'ukexploration/shortpulse_noisefilter3db/', param='all') # download pvol (need to be in vpn)
  for (scan in 1:3) {#possibly loop over scans (untested)
    params<-names(pvol$scans[[i]]$params)
    for (param in params) { # loop over parameters
      file <- sprintf(
        '~/UK_radars/%s_%s_scan_%s_%s.png',
        radar_to_odim(toRun$radar_code[i]),
        strftime(toRun$representative_timestamp[i], '%Y%m%dT%H%M%S'),
        scan,
        param
      )
      if (!file.exists(file)) { # only run if file does not existe
        message(file)
        pdfs <- pdf[unlist(lapply(pdf$par, '%in%', x = param)),]
        if (nrow(pdfs) != 1) next
        url <- ppi_tile_server_url( # find the url for the tiles
          odim_to_radar(toRun$radar_code[i]),
          floor_date(
            as.POSIXct(toRun$representative_timestamp[i], tz = 'UTC'),
            'mins'
          ),
          scan = scan,
          prefix = '',
          param = param,
          outOfRange = F,
          min = pdfs$min,
          max = pdfs$max,
          symetric = pdfs$sym
        )
        ff <- uvaRadar:::flexColFunAdjustedArguments( # get color scale for legend
          min = pdfs$min,
          max = pdfs$max,
          alpha = 100,
          symetric = pdfs$sym,
          outOfRange = F
        )
        u <-
          seq(pdfs$min * ifelse(pdfs$sym, -1, 1),
              pdfs$max,
              length.out = 30)
        m <- # make leaflet plot  ( can also be opend seperately)
          leaflet() %>%
          addTiles('http://{s}.tile.stamen.com/toner-lite/{z}/{x}/{y}.png') %>%
          addTiles(url) %>%
          setView(lng = pvol$geo$lon, pvol$geo$lat, 9) %>%
          addLegend(
            'bottomleft',
            values = u,
            pal = ff,
            title = param
          )
        mapshot(m,
                file = file) # plot the file
      }
    }
  }
}
