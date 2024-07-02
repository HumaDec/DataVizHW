library(shiny)
library(ggplot2)
library(dplyr)
library(readr)

world_bank_data <- read.csv("/Users/emmahorton/DataScience/DataViz/Homework/HW6/WorldBankData.csv")
world_bank_data <- select(world_bank_data, Year, LifeExpectancy, Fertility, Region, Country)
world_bank_data <- na.omit(world_bank_data)

Regions <- c("All Regions", unique(world_bank_data$Region))
Countries <- c("All Countries", unique(world_bank_data$Country))

ui <- fluidPage(
  sidebarPanel(
    sliderInput(
      inputId = "Year", 
      label = "Select Year:",
      min = min(world_bank_data$Year),
      max = max(world_bank_data$Year),
      value = min(world_bank_data$Year),
      step = 1,
      animate = animationOptions(interval = 1, loop = FALSE),
      ticks = FALSE,
      sep = ""
    ),
    uiOutput("RegionSelector"),
    uiOutput("CountrySelector")
  ),
  mainPanel(
    plotOutput('bubbleplot')
  )
)

server <- function(input, output, session) {
  
  output$RegionSelector <- renderUI({
    selectInput(
      inputId = "Region",
      label = "Select Region",
      choices = Regions,  
      selected = "All Regions"
    )
  })
  
  output$CountrySelector <- renderUI({
    req(input$Region)  
    
    if (input$Region == "All Regions") {
      choices <- Countries
    } else {
      filtered_countries <- unique(world_bank_data$Country[world_bank_data$Region == input$Region])
      choices <- c("All Countries", filtered_countries)
    }
    
    selectInput(
      inputId = "Country",
      label = "Select Country",
      choices = choices,
      selected = "All Countries"
    )
  })
  
  output$bubbleplot <- renderPlot({
    req(input$Region, input$Country)
    
    if (input$Region == "All Regions" && input$Country == "All Countries") {
      data <- filter(world_bank_data, Year == input$Year)
    } else if (input$Region == "All Regions") {
      data <- filter(world_bank_data, Year == input$Year, Country == input$Country)
    } else if (input$Country == "All Countries") {
      data <- filter(world_bank_data, Year == input$Year, Region == input$Region)
    } else {
      data <- filter(world_bank_data, Year == input$Year, Region == input$Region, Country == input$Country)
    }
    
    ggplot(data = data, aes(x = LifeExpectancy, y = Fertility)) +
      geom_point() +
      labs(
        title = paste("Life Expectancy vs. Fertility Rate in", input$Year),
        x = "Life Expectancy",
        y = "Fertility Rate"
      )
  })
}

shinyApp(ui, server)
