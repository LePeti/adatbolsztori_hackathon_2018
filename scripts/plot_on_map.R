source('global.R')

muzeum_dt <- fread('data/muzeum_latogatasok.csv') %>% 
    setnames(c('Terület', 'Múzeumi látogatók száma (fő)'), 
             c('terulet', 'latogatasok_szama')) %>% 
    .[!is.na(latogatasok_szama), latogatasok_szama, 
      by = .(subregion = gsub("( |,).*","", terulet))] %>% 
    .[order(subregion)]

# df <- read.csv('https://raw.githubusercontent.com/plotly/datasets/master/2011_us_ag_exports.csv')
# df$hover <- with(df, paste(state, '<br>', 'Beef', beef, 'Dairy', dairy, '<br>',
#                            'Fruits', total.fruits, 'Veggies', total.veggies,
#                            '<br>', 'Wheat', wheat, 'Corn', corn))
# # give state boundaries a white border
# l <- list(color = toRGB('white'), width = 2)
# # specify some map projection/options
# g <- list(
#     scope = 'usa',
#     projection = list(type = 'albers usa'),
#     showlakes = TRUE,
#     lakecolor = toRGB('white')
# )
# 
# p <- plot_geo(df, locationmode = 'USA-states') %>%
#     add_trace(
#         z = ~total.exports, text = ~hover, locations = ~code,
#         color = ~total.exports, colors = 'Purples'
#     ) %>%
#     colorbar(title = 'Millions USD') %>%
#     layout(
#         title = '2011 US Agriculture Exports by State<br>(Hover for breakdown)',
#         geo = g
#     )
# p


download.file('http://biogeo.ucdavis.edu/data/gadm2.8/rds/HUN_adm1.rds', 'data/HUN_adm1.rds', mode = 'wb')
download.file('http://biogeo.ucdavis.edu/data/gadm2.8/rds/HUN_adm2.rds', 'data/HUN_adm2.rds', mode = 'wb')

hun_adm1 <-  readRDS('data/HUN_adm1.rds')
hun_adm2 <-  readRDS('data/HUN_adm2.rds')

hun_adm2@data <- as.data.table(hun_adm2@data) %>% 
    copy() %>% 
    .[, subregion := gsub("(ii).*","i", paste0(NAME_2, 'i'))] %>% 
    merge(muzeum_dt, by = "subregion", all.x = TRUE) %>% 
    .[is.na(latogatasok_szama), latogatasok_szama := 0]

# Layout plot
layoutLayer(title = 'Magyarország', # title of the map
            author = 'Data Driven',  # no author text
            sources = '', # no source text
            scale = NULL, # no scale
            col = NA, # no color for the title box 
            coltitle = 'black', # color of the title
            frame = FALSE,  # no frame around the map
            bg = 'grey', # background of the map
            extent = hun_adm2) # set the extent of the map

plot(hun_adm2, col = 'grey', border = 'black', lwd = 0.5)

# Label plot of the 10 most populated countries
labelLayer(spdf = hun_adm2, # SpatialPolygonsDataFrame used to plot he labels
           df = hun_adm2@data, # data frame containing the lables
           txt = "latogatasok_szama", # label field in df
           col = "#690409", # color of the labels
           cex = 0.9, # size of the labels
           font = 2) # label font

# Set a custom color palette
cols <- carto.pal(pal1 = "blue.pal", # first color gradient
                  n1 = 20)

# Plot the compound annual growth rate
choroLayer(spdf = hun_adm2, # SpatialPolygonsDataFrame of the regions
           df = hun_adm2@data, # data frame with compound annual growth rate
           var = "latogatasok_szama", # compound annual growth rate field in df
           breaks = c(5000, 10000, 20000, 30000, 40000), # list of breaks
           col = cols, # colors 
           border = "grey40", # color of the polygons borders
           lwd = 0.5, # width of the borders
           legend.pos = "right", # position of the legend
           legend.title.txt = "Legend", # title of the legend
           legend.values.cex = 0.05,
           #legend.values.rnd = 2, # number of decimal in the legend values
           add = TRUE) # add the layer to the current plot

library(rgdal)

#download the file
temp <- tempfile(fileext = ".zip")
download.file("http://ec.europa.eu/eurostat/cache/GISCO/geodatafiles/NUTS_2013_01M_SH.zip", temp)
unzip(temp)

#load the data and filter it to Hungary and NUTS2 level
EU_NUTS = readOGR(dsn = "./NUTS_2013_01M_SH/data", layer = "NUTS_RG_01M_2013")
map_nuts2 <- subset(EU_NUTS, STAT_LEVL_ == 2) # set NUTS level
country <- substring(as.character(map_nuts2$NUTS_ID), 1, 2)
map <- c("HU") # limit it to Hungary
map_nuts2a <- map_nuts2[country %in% map,]
map_nuts3 <- subset(EU_NUTS, STAT_LEVL_ == 3) # set NUTS level
country <- substring(as.character(map_nuts3$NUTS_ID), 1, 2)
map_nuts3a <- map_nuts3[country %in% map,]

#plot it
plot(map_nuts2a, col = colorRampPalette(c("white", "red"))(nrow(map_nuts2a@data)))
plot(map_nuts3a, col = colorRampPalette(c("white", "red"))(nrow(map_nuts3a@data)))

library(cartography)

plot(map_nuts3a)

cols <-	 carto.pal(pal1 = "green.pal", n1 = nrow(map_nuts2a@data)+1)
nuts2_id = map_nuts2a@data[,"NUTS_ID"]
value = runif(nrow(map_nuts2a@data),0,50)
hun_nuts2_df = data.frame(nuts2_id, value)

choroLayer(spdf = map_nuts2a, # SpatialPolygonsDataFrame of the regions
           df = hun_nuts2_df, # target data frame 
           var = "value", # target value
           breaks = c(0,5,10,15,20,25,30,35,100), # list of breaks
           col = cols, # colors 
           border = "white", # color of the polygons borders
           lwd = 2, # width of the borders
           legend.pos = "right", # position of the legend
           legend.title.txt = "",
           legend.values.rnd = 2, # number of decimal in the legend values
           add = TRUE) # add the layer to the current plot

labelLayer(spdf = map_nuts2a, # SpatialPolygonsDataFrame used to plot he labels
           df = hun_nuts2_df, # data frame containing the lables
           txt = "nuts2_id", # label field in df
           col = "black", # color of the labels
           cex = 0.9, # size of the labels
           font = 2)  # label font
