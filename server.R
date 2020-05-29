#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(ggplot2)
library(leaflet)
library(dplyr)
library(shinydashboard)

server <- function(input, output){

  selectdata <- reactive({
  })
  # Map
  output$mymap <- renderLeaflet({
    sdf <- df[df$yearJST == input$flt_year,]
    g_id <- unique(sdf$id)
    pal <- colorFactor(topo.colors(length(unique(sdf$id))), sdf$id)
    
    m <- leaflet() %>% addTiles() %>% 
      addProviderTiles("Esri.WorldGrayCanvas") %>%
      setView(lat=30, lng=139, zoom=3) %>%
      leaflet::addLegend(position='topright', pal=pal, values=g_id, title = "id") %>%
      leaflet::addLayersControl(position= 'topleft',overlayGroups=g_id)
    
    # any of functions of leaflet need to be before for loop
    for(i in 1:length(g_id)){
      mdf <-  filter(sdf,id == g_id[i])
      m <- m %>%
        addCircles(data=mdf,weight = 1, radius =~majorAxis30 * 1000,
                   lng=~lng,lat=~lat, color = pal(g_id[i]),
                   popup=paste(mdf$id,mdf$name, as.POSIXlt(mdf$timeUTC,tz="Japan"),
                               paste0(mdf$centerPressure,"[hPa]"), sep=","),
                   group = as.character(g_id[i])) %>%  # grouping. can be deleted
        # track line  this is not in group. don't want to delete it.
        addPolylines(data=mdf,
                     lng=~lng,lat=~lat,weight="1", color = pal(g_id[i]))  
    }
    m
  })
  
  #Plot
  output$monthly <- renderPlot({
    # aggregate count by grouping factor
    P <- df %>% group_by(yearJST,monthJST) %>% summarize(count = n_distinct(id))
    g <- ggplot(P, aes( x =as.factor(monthJST), y = count
                        ,group = yearJST, color=as.factor(yearJST))) +
                geom_line() + xlab('month') + labs(color='year')  
    plot(g)
  }) # change fill argument base on user intput from raido box
  output$yearly <- renderPlot({
    P <- df %>% group_by(yearJST,level,land) %>% summarize(count = n_distinct(id))
    
    if ( input$radio == 1 ){  # none
      g <- ggplot(P, aes( x =as.factor(yearJST), y = count))
    }
    if ( input$radio == 2 ){  # land
      g <- ggplot(P, aes( x =as.factor(yearJST), y = count, fill = as.factor(land))) + 
        labs(fill = 'land')
    }
    if ( input$radio == 3 ){  # level
      g <- ggplot(P, aes( x =as.factor(yearJST), y = count, fill = as.factor(level))) +
         labs(fill='level')
    }
    g <- g + geom_bar(stat = "identity") + xlab('year') 
   plot(g)
})
  # look up table output using DT
  output$table <- renderDataTable({
    dt <- df[df$yearJST == input$flt_year,]
    dt <- select(dt, 1,4,5,6,9,10,11)
    dt
  })
}