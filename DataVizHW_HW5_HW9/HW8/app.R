library(shiny)
library(ggplot2)
library(dplyr)
library(plotly)
library(readr)
library(shinyWidgets)
library(rsconnect)



rsconnect::setAccountInfo(name='emmahorton', token='AD500A31136FA4F279EB939C92B27998', secret='9kHm4LlAFL6E6z5AHJpGoy+ucmO9VRd0aG08cSb5')


worldbank <- read.csv("WorldBankData.csv") %>%
  na.omit() %>%
  select(Year, LifeExpectancy, Fertility, Region, Country, Population)


regionlabels <- unique(worldbank$Region)
countrylabels <- unique(worldbank$Country)

ui <- fluidPage(
  titlePanel("Life Expectancy App"),
  sidebarLayout(
    sidebarPanel(
      sliderInput(
        inputId = 'year',
        label = 'Select Year',
        min = min(worldbank$Year),
        max = max(worldbank$Year),
        value = min(worldbank$Year),
        step = 1,
        animate = animationOptions(interval = 500, loop = FALSE),
        sep = ""
      ),
      prettyRadioButtons("what", "Select what to plot:", 
                         choices = list("All Countries" = "all", 
                                        "Countries from Specific World Regions" = "region", 
                                        "Selected Countries" = "country")
      ),
      conditionalPanel("input.what == 'region'", 
                       selectInput("region", "Choose World Region", choices = regionlabels, multiple = TRUE)
      ),
      conditionalPanel("input.what == 'country'", 
                       selectInput("country", "Choose Countries", choices = countrylabels, multiple = TRUE),
                       awesomeCheckbox("trace", "Leave Trace")
      )
    ),
    mainPanel(
      plotlyOutput("scatter", height = 550)
    )
  )
)

server <- function(input, output, session) {
  
  updateSelectInput(session, 'region', choices = regionlabels)
  updateSelectInput(session, 'country', choices = countrylabels)
  
  plotdata <- eventReactive(list(input$what, input$region, input$country), {
    switch(input$what,
           "all" = worldbank %>% mutate(Region = factor(Region, levels = regionlabels, labels = regionlabels)),
           "region" = worldbank %>% filter(Region %in% req(input$region)) %>% mutate(Region = factor(Region, levels = regionlabels, labels = regionlabels)),
           "country" = worldbank %>% filter(Country %in% req(input$country))
    )
  })
  
  output$scatter <- renderPlotly({
    df1 <- if (!input$trace) {
      plotdata() %>% filter(Year == as.numeric(input$year))
    } else {
      plotdata() %>% filter(Year %in% seq(1960, as.numeric(input$year))) %>% mutate(Population = 1, Year = head(Year, 1))
    }
    
    p <- plot_ly(df1, type = "scatter", mode = "markers", x = ~Fertility, y = ~LifeExpectancy, 
                 size = ~Population, color = ~Region, text = ~Country,
                 marker = list(opacity = 0.5, sizemode = 'diameter', sizeref = 2), 
                 hoverinfo = "text") %>% 
      layout(
        xaxis = list(range = c(0.82, 9.1)),
        yaxis = list(title = "Life Expectancy", range = c(18, 89)),
        legend = list(orientation = 'h', x = 0.05, y = -0.18)
      ) %>%
      add_annotations(text = ~Year, x = 0.05, y = 0.03,
                      yref = "paper", xref = "paper",
                      xanchor = "left", yanchor = "bottom",
                      showarrow = FALSE,
                      font = list(color = gray(0.9), size = 100)
      ) %>%
      add_annotations(
        text = "Life Expectancy and Fertility in the World",
        x = 0.5,
        y = 1.07,
        yref = "paper",
        xref = "paper",
        xanchor = "center",
        yanchor = "center",
        showarrow = FALSE,
        font = list(size = 26)
      )
    
    p %>% config(displayModeBar = FALSE)
  })
}

shinyApp(ui = ui, server = server)

rsconnect::deployApp()
