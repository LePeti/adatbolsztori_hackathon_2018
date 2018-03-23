transfrom_to_jaras_ev_idosoros <- function(dt) {
    # dt: dt0816
    col_names <- grep("atlagos_nm*|atlagar*|lakasallomany*|epitettlakasok*|eladottlakas*",
     names(dt), value = TRUE)

    dt[, lapply(.SD, sum, na.rm = TRUE), by = jarasnev, .SDcols = col_names] %>%
        melt(id.vars = "jarasnev", variable.factor = FALSE, na.rm = TRUE) %>%
        separate_year_varname() %>%
        dcast(jarasnev + valtozo ~ ev, value.var = 'value')

}

filter_years <- function(dt, min_year, max_year) {
    col_names <- grep(paste(min_year, max_year, sep = "|"), names(dt), value = TRUE)
    dt[, c("jarasnev", "valtozo", col_names), with = FALSE]
}

separate_year_varname <- function(dt) {
    dt[, `:=`(valtozo = substr(variable, 1, nchar(variable) - 5),
              ev = substr(variable, nchar(variable) - 3, nchar(variable)))]
}

calculate_difference <- function(dt, min_year, max_year) {
    dt[, `:=`(abs_diff = get(max_year) - get(min_year),
              rel_diff = (get(max_year) / get(min_year) - 1))]
}

plot_diffs <- function(dt) {
    ggplot(dt, aes(valtozo, rel_diff)) +
        geom_col() +
        scale_y_continuous(labels = scales::percent) +
        labs(x = "", y = "relativ valtozas") +
        theme_light()
}

transform_keresztmetszeti <- function(dt) {
    # dt: dt016
    col_names <- c("nm_ar", "lakasallomany", "epitett_lakasok_szama",
        "lakonepesseg", "lakonepesseg_0_14", "lakonepesseg_65", "lakonepesseg_15_65", "elveszuletesek_szama",
        "nyilvantartott_allaskeresok_szama", "egy_adozora_juto_adoalap")

    dt[, nm_ar := as.numeric(sub(",", ".", ertekesitett_hasznalt_lakasok_atlagos_nm_ara))] %>%
        .[, lapply(.SD, sum, na.rm = TRUE), by = jarasnev, .SDcols = col_names] %>%
        create_old_ratio() %>%
        .[, log_szja := log(egy_adozora_juto_adoalap)] %>%
        .[, log_nm_ar := log(nm_ar)]

}

create_old_ratio <- function(dt) {
    dt[, old_ratio := lakonepesseg_65/lakonepesseg]
}

transform_keresztmetszeti_2 <- function(dt) {
    col_names <- c("nm_ar", "lakasallomany", "epitett_lakasok_szama",
        "lakonepesseg", "lakonepesseg_0_14", "lakonepesseg_65", "lakonepesseg_15_65", "elveszuletesek_szama",
        "nyilvantartott_allaskeresok_szama", "egy_adozora_juto_adoalap")

    dt[, nm_ar := as.numeric(sub(",", ".", ertekesitett_hasznalt_lakasok_atlagos_nm_ara))] %>%
        .[, lapply(.SD, sum, na.rm = TRUE), by = jarasnev, .SDcols = col_names]
}

linear_model <- function(dt) {
    lm(nm_ar ~ lakasallomany + epitett_lakasok_szama + lakonepesseg + lakonepesseg_0_14 + lakonepesseg_65 + lakonepesseg_15_65 + elveszuletesek_szama + nyilvantartott_allaskeresok_szama + egy_adozora_juto_adoalap, data = dt)
}

plot_top_10 <- function(dt) {
    plot(map_jarasok)
    
    cols <-	carto.pal(pal1 = "red.pal", n1 = 20)
    
    choroLayer(spdf = map_jarasok, # SpatialPolygonsDataFrame of the regions
               df = dt, # target data frame 
               var = "egy_adozora_juto_adoalap", # target value
               # breaks = c(0,5,10,15,20,25,30,35,100), # list of breaks
               col = cols, # colors 
               border = "white", # color of the polygons borders
               lwd = 1, # width of the borders
               legend.pos = "right", # position of the legend
               legend.title.txt = "", # title of the legend
               legend.values.rnd = 2, # number of decimal in the legend values
               add = TRUE) # add the layer to the current plot   
}
