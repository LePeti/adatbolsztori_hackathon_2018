shinyServer(function(input, output){

    dt_idosoros_raw <- fread('data/2008_16.csv')
    dt_keresztmetszeti_raw <- fread('data/2016.csv')

    dt_idosoros <- transfrom_to_jaras_ev_idosoros(dt_idosoros_raw) %>%
        filter_years('2008', '2016') %>%
        calculate_difference('2008', '2016')

    dt_keresztmetszeti <- transform_keresztmetszeti(dt_keresztmetszeti_raw)

    map_jarasok <- readOGR(dsn = "data/adm_hun/", layer = "adm_jarasok")
    
    map_jarasok@data <- as.data.table(map_jarasok@data) %>% 
        copy() %>% 
        .[, jarasnev := substr(NAME, 1, nchar(as.character(NAME)) - 6)] %>% 
        merge(dt_keresztmetszeti, by = "jarasnev", all.x = TRUE)
    
    dt_idosoros_jaras <- reactive({
        dt_idosoros[jarasnev == input$jarasok]
    })

    dt_keresztmetszeti_filtered <- reactive({
        dt_keresztmetszeti[old_ratio <= input$plus_65_ratio & log_szja <= input$szja_bin & log_nm_ar <= input$nm_ar] %>%
            .[order(-log_nm_ar, -log_szja, -old_ratio)] %>%
            .[1:10]
    })

    output$differences <- renderPlot(
        dt_idosoros_jaras() %>%
            plot_diffs()
    )

    output$absolute <- DT::renderDataTable(
        DT::datatable(dt_idosoros_jaras()[, c("valtozo", "2008", "2016")])
    )

    output$hol_lakj <- DT::renderDataTable(
        DT::datatable(dt_keresztmetszeti_filtered(), options = list(autoWidth = TRUE))
    )

    output$jaras_valaszto <- renderUI({
        selectInput(inputId = "jarasok", label = h4("Jarasok:"), choices = as.list(unique(dt_idosoros$jarasnev)))
    })

    output$plus_65 <- renderUI({
        sliderInput("plus_65_ratio", "65 felettiek aranya kisebb mint:",
                    0.12, 0.24, 0.2, 0.02)
    })

    output$szja <- renderUI({
        sliderInput("szja_bin", "Log SzJA alap kisebb mint:",
            7, 12, 11, 0.5)
    })

    output$nm_ar <- renderUI({
        sliderInput("nm_ar", "Log nm ar kisebb mint:",
            12, 16, 14, 1)
    })
    
    output$map <- renderPlot(
        dt_keresztmetszeti_filtered() %>%
            plot_top_10()
    )

})
