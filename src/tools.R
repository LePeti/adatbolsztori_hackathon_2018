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
    col_names <- c("lakasallomany", "epitett_lakasok_szama", "lakonepesseg", "lakonepesseg_0_14", "lakonepesseg_65",
        "lakonepesseg_15_65", "elveszuletesek_szama", "nyilvantartott_allaskeresok_szama", "egy_adozora_juto_adoalap")

    dt[, lapply(.SD, sum, na.rm = TRUE), by = jarasnev, .SDcols = col_names] %>%
        create_old_ratio() %>%
        .[, szja_bin := cut(log(egy_adozora_juto_adoalap), breaks = 5)]

}

create_old_ratio <- function(dt) {
    dt[, old_ratio := lakonepesseg_65/lakonepesseg]
}

