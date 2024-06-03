library(shiny)
library(bslib)
library(bsicons)


code_ui <- function(){
  div(style = 'overflow-y: auto; margin-left: 10px; margin-right: 10px;',
      fluidRow(
        column(
          width = 12,
          h3("Final Model"),
          br(),
          verbatimTextOutput("model_code"))
      )
  )
}