library(shiny)
ui <- fluidPage(
  titlePanel("Greetings App"),
  sidebarLayout(
    sidebarPanel(
      textInput("name", "What's your name?")
    ),
    mainPanel(
      textOutput("greeting")
    )
  )
)

server <- function(input, output, session) {
  output$greeting <- renderText({
    paste0("Hello ", input$name)
  })
}

shinyApp(ui = ui, server = server)