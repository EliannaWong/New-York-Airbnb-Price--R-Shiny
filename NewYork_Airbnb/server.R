library(shiny)
library(ggplot2)
library(dplyr)
library(RColorBrewer)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    output$text <- renderText({
        "This is a brief preview of the 100 observations of New York Airbnb Neibourhood and Price"
    })

    output$mytable <- renderTable({
        # Import data
        NY <- read.csv("../AB_NYC_2019.csv")
        NY_nbh <- NY %>% select(id, neighbourhood_group, latitude, longitude, price)
        head(NY_nbh, 100)
    })
    
    output$myplot1 <- renderPlot({
        # Import data
        NY <- read.csv("../AB_NYC_2019.csv")
        # Select neighbourhood_group, count the number and make them as a dataframe
        data1 <- NY %>% select(neighbourhood_group)%>%table() %>% as.data.frame()
        names(data1) = c("neighbourhood_group", "nums")
        ggplot(data1, aes(x="", y=nums, fill= neighbourhood_group)) + 
            geom_bar(width = 1, stat = "identity") + 
            coord_polar("y", start=0) +
            labs(title = "Neighbourhoods in New York") + 
            scale_fill_brewer(palette="Oranges") +
            theme(plot.title = element_text(hjust = 0.5, size = rel(2)))
    })
    
    
    output$myplot2 <- renderPlot({
        # Import data
        NY <- read.csv("../AB_NYC_2019.csv")
        # Select neighbourhood_group and room_type, count the number and make them as a dataframe
        data2 <- NY %>% select(neighbourhood_group, room_type) %>% table() %>% as.data.frame()
        names(data2) = c("neighbourhood_group","room_type","nums")
        ggplot(data2, aes(fill = neighbourhood_group, y=nums, x=room_type)) + 
            geom_bar(position="dodge", stat="identity") + 
            labs(title = "Room Types In Neighbourhood Groups", x = "Room Type", y = "Count" ) +
            scale_fill_brewer(palette="Oranges") +
            theme(plot.title = element_text(hjust = 0.5, size = rel(2)))
    })
    
    
    output$myplot3 <- renderPlot({
        # The distribution of different neibourhood groups
        data3 <- NY_nbh()
        ggplot(data3, aes(x = longitude, y = latitude, color = neighbourhood_group)) +
            geom_point() + scale_color_brewer(palette = "Oranges") +
            labs(title = "General Housing Map", x = "Longitude", y = "Latitude") +
            theme(plot.title = element_text(hjust = 0.5, size = rel(2)))
    })
    
    
    NY_nbh <- reactive({
        NY <- read.csv("../AB_NYC_2019.csv")
        NY_nbh <- NY %>% select(neighbourhood_group, latitude, longitude, price, id)
    })
    
    
    output$mymap <- renderLeaflet({
        # Create the map objects and add circle marker
        nbh_group <- input$nbh_group
        NY_nbh <- NY_nbh() %>%
            filter(neighbourhood_group %in% nbh_group)
        NY_nbh$prc_range = cut(NY_nbh$price,
                           breaks = c(0,50,100,150,200,1000), right = FALSE,
                           labels = c("Low [0-50)", "Economy [50-100)","Medium [100-150)","High [150-200)","Luxury >=100"))
        pal = colorFactor(palette = "Oranges", domain = NY_nbh$prc_range)
        leaflet(data = NY_nbh) %>% addProviderTiles("OpenStreetMap.DE") %>% 
            addCircleMarkers(lng = ~longitude,
                             lat = ~latitude,
                             color = ~pal(prc_range),
                             label = paste("Price=",NY_nbh$price,"Type=",NY_nbh$prc_range),
                             clusterOptions = markerClusterOptions()) %>%
            addLegend(position = "bottomright", pal = pal, values = ~prc_range)
    })

})
