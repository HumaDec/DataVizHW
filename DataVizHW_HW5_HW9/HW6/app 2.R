library(shiny)

ui <- fluidPage(
  textInput("name", "What's your name?"),
  textOutput("greeting")
)
#Original Server 1
#server1 <- function(input, output, server) {
  #input$greeting <- renderText(paste0("Hello ", name))
#}

#Corrected Server1 
#server <- function(input, output, server) {
  #output$greeting <- renderText(paste0("Hello ", input$name))
#}

#Original Server 2
#server2 <- function(input, output, server) {
  #greeting <- paste0("Hello ", input$name)
  #output$greeting <- renderText(greeting)
#}

# Corrected Server 2
#server <- function(input, output, server) {
  #string <- reactive(paste0("Hello ", input$name))
  #output$greeting <- renderText(string())
#}

#Original Server 3
# server3 <- function(input, output, server) {
# output$greting <- paste0("Hello", input$name)
# }

# Corrected Sever 3
#server <- function(input, output, server) {
  #output$greeting <- renderText({
    #paste0("Hello", input$name)
  #})
#}

# Run the application 
shinyApp(ui = ui, server = server)
