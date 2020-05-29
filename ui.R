#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shinydashboard)
library(leaflet)
library(scales)
library(DT)

header <- dashboardHeader(
  title = "Japan typhoon trail"
)

sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Map",tabName ="map"),
    menuItem("Plot",tabName = "plot")
  )
)

body <- dashboardBody(
  tabItems(
    tabItem("map",        # map tab
            column(width=10,
              leafletOutput("mymap", height = 420), #leaflet
              box(width = NULL,
                dataTableOutput("table", height = "auto")) # table
            ),
            column(width =2,
                   box(width = NULL, solidHeader = TRUE, status = "primary",collapsible = TRUE,
                   "This map visualizes overlaid typhoon trails for a year selected below" , 
                   br(),br(),
                   "You can choose specific tracks with layer control on the top left", br(),br(),
                   selectInput('flt_year', label= 'select year', choices = unique(df$yearJST))
                  ),
                  br(),br(),br(),br(),br(),br(),br(),br(),br(), # change lines
                  "The table shows data set which is source of map above." , 
                  br(), 
                  "This app all depends on the public data.", br(),
                  "For more detail, such as definition of each variables, please refer below link.",
                  tags$p(
                    tags$a(href = "https://www.data.jma.go.jp/fcd/yoho/typhoon/position_table/index.html",
                           "Japan Meteorological Agency"),
                  br(),br(),br(),br(),
                  "This app is created by shinny.", br(),
                  "You can also access source code at ..",
                  tags$p(
                      tags$a(href = "https://github.com/toshi1979/DevDataProduct",
                             "GitHub")
                  )
            )
          )
    ),
    tabItem("plot", # plot tab
            box(title = "Yearly trend of typhoon occurance",width = NULL,
                solidHeader = TRUE, status = "primary",collapsible = TRUE,
                radioButtons("radio", h3("split by"),
                             choices = list("none" =1, "land" = 2, "level" = 3
                                            ),selected = 1),
            plotOutput("yearly", height = 400)
            ),
            box(title = "Monthly trend of typhoon occurance per year",width = NULL,
                solidHeader = TRUE, status = "primary",collapsible = TRUE,
            plotOutput("monthly",height = 400)
            )
    )
    )
)
    
dashboardPage(
  header,
  sidebar,
  body
)
