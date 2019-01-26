library(shiny)
library(leaflet)

ui <- fluidPage(
  leafletOutput("mymap", width = '100%', height = 400)
)