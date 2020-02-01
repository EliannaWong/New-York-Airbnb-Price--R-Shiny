library(leaflet)
library(shiny)
library(RColorBrewer)

shinyUI(fluidPage(
  titlePanel("New York Airbnb Neibourhood & Price"),
  
  navlistPanel(
    "Map",
    tabPanel("Map", leafletOutput("mymap"), hr(), fluidRow( # used to create a row
      column(12, offset = 1,
             checkboxGroupInput("nbh_group",
                                "Neighbourhood Group",
                                c("Bronx","Brooklyn","Manhattan","Queens","Staten Island"),
                                selected = c("Bronx", "Brooklyn", "Manhattan", "Queens", "Staten Island")
             )))),
    
    "Data",
    tabPanel("Data Preview", h1("Data Preview"), fluidRow(
      textOutput("text"), tableOutput("mytable")
    )),
    
    "Data Visualization",
    tabPanel("Housing Number by Neighbourhood", plotOutput("myplot1")),
    tabPanel("Room Type", plotOutput("myplot2")),
    tabPanel("Housing Map", plotOutput("myplot3"))

  )
))