shinyServer(function(input, output){

    dt_idosoros_raw <- fread('data/2008_16.csv')
    dt_keresztmetszeti_raw <- fread('data/2016.csv')

    dt_idosoros <- transfrom_to_jaras_ev_idosoros(dt_idosoros_raw) %>%
        filter_years('2008', '2016') %>%
        calculate_difference('2008', '2016')

    dt_keresztmetszeti <- transform_keresztmetszeti(dt_keresztmetszeti_raw)

    dt_idosoros_jaras <- reactive({
        dt_idosoros[jarasnev == input$jarasok]
    })

    dt_keresztmetszeti_filtered <- reactive({
        dt_keresztmetszeti[old_ratio <= input$plus_65_ratio & log_szja <= input$szja_bin] %>%
            .[order(log_szja, -old_ratio)] %>%
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
        sliderInput("plus_65_ratio", "65 felettiek aranya:",
                    0.12, 0.24, 0.2, 0.02)
    })

    output$szja <- renderUI({
        sliderInput("szja_bin", "Log SzJA alap csoportok:",
            7, 12, 11, 0.5)
    })
})
