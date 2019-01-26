library(shiny)
library(leaflet)
library(dplyr)

server <- function(input,output, session){
  
  data <- reactive({
    x <- df
  })
  
  output$mymap <- renderLeaflet({
    df <- data()
    
    arbys.icon <- makeIcon(
      iconUrl = "./Arby's.BMP",
      iconAnchorX = 0
    )
    
    labs <- lapply(seq(nrow(df)), function(i) {
      paste0( '<p>', df[i, "street"], '<p></p>', 
              df[i, "city"], ', ', 
              df[i, "state"],'</p><p>', 
              df[i, "phone"], '</p>' )
    })
    
    m <- leaflet(data = df) %>%
      addTiles %>%
      addMarkers(~longitude, ~latitude, 
                 icon = arbys.icon,
                 label = lapply(labs, HTML),
                 clusterOptions = markerClusterOptions(),
                 labelOptions = labelOptions(noHide = F, 
                                             textsize = "14px"))
    
    m
  })
}