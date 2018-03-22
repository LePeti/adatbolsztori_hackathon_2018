source('global.R')

lakas_dt <- fread('data/lakas_adat.csv')

temp <- tempfile(fileext = ".zip")
download.file("http://ec.europa.eu/eurostat/cache/GISCO/geodatafiles/NUTS_2013_01M_SH.zip", temp)
unzip(temp, exdir = 'data')

EU_NUTS <- readOGR(dsn = "./NUTS_2013_01M_SH/data", layer = "NUTS_RG_01M_2013")
map_nuts3 <- subset(EU_NUTS, STAT_LEVL_ == 3)
country <- substring(as.character(map_nuts3$NUTS_ID), 1, 2)
map_nuts3_hu <- map_nuts3[country == "HU",] %>% 
    merge(lakas_dt, by.x = "NUTS_ID", by.y = "NUTS3")

map_nuts3_hu@data$scaled_lakasadat <- scale(map_nuts3_hu@data$lakasadat) 

plot(map_nuts3_hu)

cols <-	carto.pal(pal1 = "red.pal", n1 = 20)

choroLayer(spdf = map_nuts3_hu, # SpatialPolygonsDataFrame of the regions
           df = map_nuts3_hu@data, # target data frame 
           var = "scaled_lakasadat", # target value
           # breaks = c(0,5,10,15,20,25,30,35,100), # list of breaks
           col = cols, # colors 
           border = "white", # color of the polygons borders
           lwd = 1, # width of the borders
           legend.pos = "right", # position of the legend
           legend.title.txt = "",
           legend.values.rnd = 2, # number of decimal in the legend values
           add = TRUE) # add the layer to the current plot
