library(shiny)
library(bslib)
library(bsicons)

source("ui_data.R")

ui <- navbarPage(
  title = div(img(src="cs.png", height = "30px", weight = "30px"), "Salary Prediction 2024", style = "padding-top: 30px; padding-right: 20px;"),
  theme = bs_theme(version = 5, bootswatch = "minty"),
  navbarMenu(
    title = "Data",
    tabPanel("Introduction", data_ui()),
    tabPanel("Original Data", original_data_ui()),
    tabPanel("Cleaned Data", "Tab content 3")
  ),
  navbarMenu(
    title = "Training",
    tabPanel("Random Forest", "Tab content 4"),
    tabPanel("GBM", "Tab content 5")
  ),
  navbarMenu(
    title = "Prediction",
    tabPanel("Salary Prediction", "Tab content 6")
  )
)