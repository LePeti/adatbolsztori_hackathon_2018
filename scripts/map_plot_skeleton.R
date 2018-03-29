source('global.R')

lakas_dt <- fread('data/lakas_adat.csv')

temp <- tempfile(fileext = ".zip")
download.file("http://ec.europa.eu/eurostat/cache/GISCO/geodatafiles/NUTS_2013_01M_SH.zip", temp)
unzip(temp, exdir = 'data')

EU_NUTS <- readOGR(dsn = "data/NUTS_2013_01M_SH/data", layer = "NUTS_RG_01M_2013")
map_nuts3 <- subset(EU_NUTS, STAT_LEVL_ == 3)
country <- substring(as.character(map_nuts3$NUTS_ID), 1, 2)
map_nuts3_hu <- map_nuts3[country == "HU",] %>% 
    merge(lakas_dt, by.x = "NUTS_ID", by.y = "NUTS3")

map_nuts3_hu@data$scaled_lakasadat <- scale(map_nuts3_hu@data$lakasadat) 

plot(map_nuts3_hu)

cols <-	carto.pal(pal1 = "red.pal", n1 = 20)

layoutLayer(title = 'Magyarország', # title of the map
            author = 'Data Driven',  # no author text
            sources = '', # no source text
            scale = NULL, # no scale
            col = NA, # no color for the title box 
            coltitle = 'black', # color of the title
            frame = FALSE,  # no frame around the map
            bg = 'grey', # background of the map
            extent = map_nuts3_hu) # set the extent of the map

choroLayer(spdf = map_nuts3_hu, # SpatialPolygonsDataFrame of the regions
           df = map_nuts3_hu@data, # target data frame 
           var = "scaled_lakasadat", # target value
           # breaks = c(0,5,10,15,20,25,30,35,100), # list of breaks
           col = cols, # colors 
           border = "white", # color of the polygons borders
           lwd = 1, # width of the borders
           legend.pos = "right", # position of the legend
           legend.title.txt = "", # title of the legend
           legend.values.rnd = 2, # number of decimal in the legend values
           add = TRUE) # add the layer to the current plot

labelLayer(spdf = map_nuts3_hu, # SpatialPolygonsDataFrame used to plot he labels
           df = map_nuts3_hu@data, # data frame containing the lables
           txt = "scaled_lakasadat", # label field in df
           col = "#690409", # color of the labels
           cex = 0.9, # size of the labels
           font = 2) # label font

unzip('data/CENSUS_UNITS_PT_2011_SH.zip', exdir = 'data')
census_units <- readOGR(dsn = 'data/CENSUS_UNITS_2011_PT/data', layer = 'CENSUS_UNIT_PT_2011')
plot(census_units)

unzip('data/COMM-01M-2013-SH.zip', exdir = 'data')
comm <- readOGR(dsn = 'data/COMM_01M_2013_SH/data', layer = 'COMM_RG_01M_2013')
comm_hu <- subset(comm, substring(as.character(COMM_ID), 1, 2) == "HU")
plot(comm_hu)

unzip('data/FUA_RG_100K_2015_2018.zip', exdir = 'data/FUA_RG_100K_2015_2018')
fua <- readOGR(dsn = 'data/FUA_RG_100K_2015_2018', layer = 'FUA_RG_100K_2015_2018')
fua_hu <- subset(fua, as.character(CNTR_CODE) == "HU")
plot(fua_hu)


map_jarasok <- readOGR(dsn = "data/adm_hun/", layer = "adm_jarasok")

map_jarasok@data <- as.data.table(map_jarasok@data) %>% 
    copy() %>% 
    .[, jarasnev := substr(NAME, 1, nchar(as.character(NAME)) - 6)] %>% 
    merge(dt_keresztmetszeti, by = "jarasnev", all.x = TRUE)

plot(map_jarasok)

cols <-	carto.pal(pal1 = "red.pal", n1 = 20)

choroLayer(spdf = map_jarasok, # SpatialPolygonsDataFrame of the regions
           df = map_jarasok@data, # target data frame 
           var = "egy_adozora_juto_adoalap", # target value
           # breaks = c(0,5,10,15,20,25,30,35,100), # list of breaks
           col = cols, # colors 
           border = "white", # color of the polygons borders
           lwd = 1, # width of the borders
           legend.pos = "right", # position of the legend
           legend.title.txt = "", # title of the legend
           legend.values.rnd = 2, # number of decimal in the legend values
           add = TRUE) # add the layer to the current plot
