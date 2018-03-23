shinyServer(function(input, output){

    dt_raw <- fread('data/2008_16.csv')
    dt_jaras_ev <- transfrom_to_jaras_ev_idosoros(dt_raw) %>%
        filter_years('2008', '2016') %>%
        calculate_difference('2008', '2016')

    dt_jaras_ev_customer <- reactive({
        dt_jaras_ev[jarasnev == input$jarasok]
    })

    output$differences <- renderPlot(
        dt_jaras_ev_customer() %>%
            plot_diffs()
    )

    output$absolute <- DT::renderDataTable(
        DT::datatable(dt_jaras_ev_customer()[, c("valtozo", "2008", "2016")])
    )

    output$jaras_valaszto <- renderUI({
        selectInput(inputId = "jarasok", label = h4("Jarasok:"), choices = as.list(unique(dt_jaras_ev$jarasnev)))
    })
})
