library(shiny)
library(leaflet)
library(tidyverse)

kp <- jsonlite::fromJSON("https://api.koronapay.com/agents/?addressTruncateLevel=locality&limit=5000&offset=0&language=ru&locationService=yandex&fields=shortName%2Caddress%2CyandexLocation%2Cschedule%2Cphone%2Cservices%2CrootId&addressObjectId=TR&services=16+or+17",
                         flatten =  TRUE) %>% 
  rename(lat = yandexLocation.latitude,
         lon = yandexLocation.longitude)

ui <- bootstrapPage(
  # TODO: change to sidebar layout
  titlePanel("Адреса отделений Coronapay в Турции"),
  leaflet::leafletOutput('map', width = '100%', height = '100%'),
  absolutePanel(top = 10, right = 10, id = 'controls',
                textInput('address', 
                          "Введите фрагмент адреса (чувствительно к регистру): "),
                actionButton("go", "Искать")
                
  ),
  tags$style(type = "text/css", "
    html, body {width:100%;height:100%}     
    #controls{background-color:white;padding:20px;}
    #map {visibility:inherit;}
  ")
)

server <- function(input, output, session) {
  
  filtered <- eventReactive(input$go, {
    kp %>% 
      filter(grepl(input$address, address))
  })

  output$map <- leaflet::renderLeaflet({
   kp %>% 
      leaflet() %>% 
      setView(35, 39, zoom = 6) %>% 
      addTiles() %>% 
      addMarkers(lng= ~lon, lat= ~lat, popup = ~schedule)
  })
  
  observe(leafletProxy("map", data=filtered()) %>%
            clearMarkers() %>%
            addMarkers()
  )
}

shinyApp(ui, server)
