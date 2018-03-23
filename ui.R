library("shinydashboard")

header <- dashboardHeader(
    title = "Mi vot?"
)

sidebar <- dashboardSidebar(
    sidebarMenu(
        menuItem("Hol vagyok?", tabName = "hol_vagyok", icon = icon("dashboard")),
        menuItem("Hova menjek?", tabName = "hova_menjek", icon = icon("th")),
        uiOutput("jaras_valaszto"),
        uiOutput("plus_65"),
        uiOutput("szja")


    )
)

body <- dashboardBody(
    tabItems(
        tabItem(tabName = "hol_vagyok",
            fluidRow(box(plotOutput('differences'), width = 8),
                     box(DT::dataTableOutput('absolute'), width = 4))
        ),
        tabItem(tabName = "hova_menjek",
            fluidRow(box(width = NULL, status = "primary",
                div(style = 'overflow-x: scroll', DT::dataTableOutput('hol_lakj')))
            )
        )
    )
)

dashboardPage(
    header,
    sidebar,
    body,
    skin = "blue",
    title = "Mi vot"
)
