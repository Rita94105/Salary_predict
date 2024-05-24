library(shiny)
library(bslib)
library(bsicons)

data_ui <- function() {
  div(style='overflow-y: auto;',
      fluidRow(
        column(
          width = 12,
          card(
            card_header("Introduction", class = "h6 text-primary"),
            p("In our Data Science course this semester, we were particularly intrigued by the current landscape of data science-related careers, specifically focusing on compensation trends."),
            p("To satisfy our curiosity and academic requirements, we decided to explore a relevant dataset found on Kaggle: Data Engineer Salary in 2024.")
          )
        ),
        column(
          width = 4,
          value_box(
            title = "Type of Job Title",
            textOutput("job_title"),
            showcase = bs_icon("stars"),
            theme = "success"
          )
        ),
        column(
          width = 4,
          value_box(
            title = "Data Rows",
            textOutput("number_of_rows"),
            showcase = bs_icon("person"),
            theme = "secondary"
          )
        ),
        column(
          width = 4,
          value_box(
            title = "Avg Salary in USD",
            textOutput("average_salary"),
            showcase = bs_icon("coin"),
            theme = "info"
          )
        ),
        column(
          width = 6,
          card(
            card_header("Salary distribution in USD", class = "h6 text-success"),
            plotOutput("salary_bar")
          )
        ),
        column(
          width = 6,
          card(
            card_header("Work experience distribution", class = "h6 text-success"),
            plotOutput("work_bar")
          )
        ),
        column(
          width = 6,
          card(
            card_header("Experience Level vs Salary", class = "h6 text-success"),
            plotOutput("experience_salary")
          )
        ),
        column(
          width = 6,
          card(
            card_header("Remote Ratio vs Salary", class = "h6 text-success"),
            plotOutput("remote_salary")
          )
        )
      )
  )
}

original_data_ui <- function() {
  DT::dataTableOutput("ordinal_data")
}

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