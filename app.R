library(shiny)
library(leaflet)
library(tidyverse)

# kp <- read_csv("coronapay_geo.csv") %>% 
#   rename(lat = yandexLocation.latitude,
#          lon = yandexLocation.longitude)

kp <- jsonlite::fromJSON("https://api.koronapay.com/agents/?addressTruncateLevel=locality&limit=5000&offset=0&language=ru&locationService=yandex&fields=shortName%2Caddress%2CyandexLocation%2Cschedule%2Cphone%2Cservices%2CrootId&addressObjectId=TR&services=16+or+17",
                         flatten =  TRUE) %>% 
  rename(lat = yandexLocation.latitude,
         lon = yandexLocation.longitude)

ui <- bootstrapPage(
  
  titlePanel("Адреса отделений Coronapay в Турции"),
  leaflet::leafletOutput('map', width = '100%', height = '100%'),
  absolutePanel(top = 10, right = 10, id = 'controls',
                textInput('address', "Введите фрагмент адреса (чувствительно к регистру): ")
                
  ),
  tags$style(type = "text/css", "
    html, body {width:100%;height:100%}     
    #controls{background-color:white;padding:20px;}
  ")
)

server <- function(input, output, session) {
  
  output$map <- leaflet::renderLeaflet({
    kp %>% 
      filter(grepl(input$address,address)) %>% 
      leaflet() %>% 
      setView(35, 39, zoom = 6) %>% 
      addTiles() %>% 
      addMarkers(lng= ~lon, lat= ~lat, popup = ~schedule)
  })
}

shinyApp(ui, server)