library("shinydashboard")

header <- dashboardHeader(
    title = "Re-engager"
)

sidebar <- dashboardSidebar(
    sidebarMenu(
        id = "main_tabs",

        menuItem(
            "plots", tabName = "plots", icon = icon("tachometer")
            , selected = TRUE
        ),

        menuItem(
            "reports", tabName = "reports", icon = icon("file")
            , selected = FALSE
        ),

        dateInput(
            inputId = 'start_date',
            label = h4('start date'),
            value = as.Date('2018-02-06'),
            max = Sys.Date() - 7
        ),

        textInput(
            inputId = 'customer_name',
            label = h4('customer name'),
            value = 'edigital'
        ),

        checkboxInput(
            inputId = 'refetch_checkbox',
            label = 'refetch data'
        ),

        actionButton(
            inputId = 'run',
            label = 'Run'
        )
    )
)

body <- dashboardBody(
    tabItems(
        tabItem(
            "plots",
            fluidRow(
                plotDownloadUI("opened_percent_of_delivered"),
                plotDownloadUI("fslo_distribution")
            ),
            fluidRow(
                plotDownloadUI("last_send_histogram"),
                plotDownloadUI("eps_distribution")
            ),
            fluidRow(
                plotDownloadUI("weekly_campaigns_open_rate", boxwidth = 12)
            ),
            fluidRow(
                plotDownloadUI("last_click_histogram")
            ),
            fluidRow(
                plotDownloadUI("weekly_campaigns_click_rate", boxwidth = 12)
            )
        ),
        tabItem(
            "reports",
            # fluidRow(
            #     downloadButton("downloadReport", label = "Download")
            # ),
            fluidRow(
                uiOutput("markdown")
            )
        )
    )
)

dashboardPage(
    header,
    sidebar,
    body,
    skin = "blue",
    title = "Re-engager custom report"
)
