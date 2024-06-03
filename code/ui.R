library(shiny)
library(bslib)
library(bsicons)

source("ui_data.R")
source("ui_data_preprocessing.R")
source("ui_training.R")
source("ui_prediction.R")
source("ui_code.R")

footer_ui <- function() {
  div(class = "footer",
      style = "padding: 10px; text-align: center; ;",
      p("The project is led by ",
        a(href = "https://www.changlabtw.com/pi-243732347837528.html",target = "_blank", "Dr. Chang"),
        " in 2024"))
}

ui <- navbarPage(
  title = div(img(src="cs.png", height = "30px", weight = "30px"), "Salary Prediction 2024", style = "padding-top: 30px; padding-right: 20px;"),
  theme = bs_theme(version = 5, bootswatch = "minty"),
  navbarMenu(
    title = "Data Exploration",
    tabPanel("Introduction", data_ui()),
    tabPanel("Data Preprocessing", data_preprocessing_ui()),
    tabPanel("Original Data", original_data_ui()),
  ),
  navbarMenu(
    title = "Training and Prediction", 
    tabPanel("Training",training_ui()),
    tabPanel("Prediction",prediction_ui()),
    tabPanel("Model Code", code_ui())
  ),
  footer_ui()
)