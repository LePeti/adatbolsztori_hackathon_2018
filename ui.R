shinyUI(fluidPage(

    title = "Lakhely Kereso",

    sidebarLayout(

    # Sidebar panel for inputs ----
        sidebarPanel(

      # Input: Slider for the number of bins ----
            sliderInput(inputId = "bins",
                        label = "Number of bins:",
                        min = 1,
                        max = 50,
                        value = 30)

        ),

        mainPanel(
            tabsetPanel(type = "tabs",
                        tabPanel("Ahol vagyok"),

                        tabPanel("Hova menjek?")
            )
        )
    )
))
