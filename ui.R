library("shinydashboard")

header <- dashboardHeader(
    title = "Mi vót?"
)

sidebar <- dashboardSidebar(
    sidebarMenu(
        menuItem("Hol vagyok?", tabName = "hol_vagyok", icon = icon("home")),
        menuItem("Hova menjek?", tabName = "hova_menjek", icon = icon("suitcase")),
        uiOutput("jaras_valaszto"),
        uiOutput("plus_65"),
        uiOutput("szja"),
        uiOutput("nm_ar")


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
                         div(style = 'overflow-x: scroll', DT::dataTableOutput('hol_lakj'))),
                     box(plotOutput('map'), width = 12)
            )
        )
    )
)

dashboardPage(
    header,
    sidebar,
    body,
    skin = "blue",
    title = "Mi vót"
)
