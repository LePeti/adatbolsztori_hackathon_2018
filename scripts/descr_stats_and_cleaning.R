source('global.R')

dt16 <- fread('data/2016.csv')
dt0816 <- fread('data/2008_16.csv')

str(dt16)
# NOTE: Értékesített használt lakások átlagos nm-ára (Ft/m2) "character"


# Fontosabb valtozok eloszlasa es hianyzo adatok
# Hianyzo adatok
map(dt16, ~sum(.x == "" | is.na(.x)))
# keves adat hianyzik csak

ggplot(dt16, aes(`Értékesített használt lakások száma (db)`)) +
    geom_histogram()

ggplot(dt16, aes(log(`Értékesített használt lakások száma (db)`))) +
    geom_histogram()

ggplot(dt16, aes(log(`Értékesített használt lakások száma (db)`))) +
    geom_histogram(bins = 10) +
    scale_x_continuous(limits = c(0,10), breaks = pretty_breaks(10))
# a legtobb telepulesen csak 10 koruli hasznalt lakast adtak/vettek
# lehet hogy nem erdemes telepules szinten nezelodni: jaras es megye is ertelmezheto VAGY BP (esetleg nagyobb varosok, megyeszekhelyek)

dt16_megye <- dt16[, .(num_ert_lakas = sum(`Értékesített használt lakások száma (db)`, na.rm = TRUE)),
                   by = .(megye = `Megyenév`)]

dt16_jaras <- dt16[, .(num_ert_lakas = sum(`Értékesített használt lakások száma (db)`, na.rm = TRUE)),
                   by = .(jaras = `Járásnév`)]

ggplot(dt16_megye, aes(x = megye, y = num_ert_lakas)) +
    geom_col()

ggplot(dt16_jaras, aes(x = jaras, y = num_ert_lakas)) +
    geom_col()


# Menekulttaboros telepulesek arvaltozasai
menekult_taborok <- c("Debrecen", "Békéscsaba", "Nyírbátor", "Kiskunhalas", "Győr", "Fót", "Balassagyarmat", "Vámosszbadi", "Bicske", "Körmend")
oszlop_nev <- grep("Átlagosnmár*", names(dt0816), value = TRUE)
dt_menekult <- dt0816[`Településnév` %in% menekult_taborok, c("Településnév", oszlop_nev), with = FALSE] %>%
    melt("Településnév", variable.factor = FALSE) %>%
    .[, ev := as.integer(substr(variable, nchar(variable) - 3, nchar(variable)))] %>%
    setnames("Településnév", "telepules") %>%
    .[!is.na(ev)]

ggplot(dt_menekult, aes(ev, value, colour = telepules)) +
    geom_line()
