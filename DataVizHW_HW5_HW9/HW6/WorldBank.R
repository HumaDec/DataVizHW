library(shiny)
library(ggplot2)
library(dplyr)
library(readr)

world_bank_data <- read.csv("/Users/emmahorton/DataScience/DataViz/Homework/HW6/WorldBankData.csv")
world_bank_data <- select(world_bank_data, Year, LifeExpectancy, Fertility, Region)
world_bank_data <- na.omit(world_bank_data)

ui <- fluidPage(
  sidebarPanel(
    sliderInput(
      inputId = "Year", 
      label = "Select Year:",
      min = min(world_bank_data$Year),
      max = max(world_bank_data$Year),
      value = min(world_bank_data$Year),
      step = 1,
      animate = animationOptions(interval = 1, loop = FALSE)    )
  ),
  mainPanel(
    plotOutput('bubbleplot')
  )
)

server <- function(input, output, session) {
  output$bubbleplot <- renderPlot({
    data <- filter(world_bank_data, Year == input$Year)
    ggplot(data = data, aes(x = LifeExpectancy, y = Fertility)) +
      geom_point()
  })
}

shinyApp(ui, server)
