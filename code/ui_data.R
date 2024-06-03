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
            p("To satisfy our curiosity and academic requirements, we decided to explore a relevant dataset found on Kaggle: Data Engineer Salary in 2024."),
            p("Our accuracy is already significantly better than other results on Kaggle."),
            p("However, this is a passable result. We need more data or features to optimize our model training to achieve results that most people can accept."),
            p("Nonetheless, during the training process, we found that job_title is the most important feature, indicating that job titles play a crucial role in predicting salaries.")
          )
        )),
      fluidRow(
        column(
          width = 4, lg = 4,
          value_box(
            title = "Type of Job Title",
            textOutput("job_title"),
            showcase = bs_icon("stars"),
            theme = "success"
          )
        ),
        column(
          width = 4, lg = 4,
          value_box(
            title = "Data Rows",
            textOutput("number_of_rows"),
            showcase = bs_icon("person"),
            theme = "secondary"
          )
        ),
        column(
          width = 4, lg = 4,
          value_box(
            title = "Avg Salary in USD",
            textOutput("average_salary"),
            showcase = bs_icon("coin"),
            theme = "info"
          )
        )),
      fluidRow(
        column(
          width = 6,
          card(
            card_header("Histogram of Salary in USD", class = "h6 text-success"),
            plotOutput("histogram_salary_in_usd")
          )
        ),
        column(
          width = 6,
          card(
            card_header("Histogram of Log Salary in USD", class = "h6 text-success"),
            plotOutput("salary_in_log")
          )
        )
      ),
      fluidRow(
        column(
          width = 12,
          card(
            card_header("Salary Distribution and Average", class = "h6 text-success"),
            fluidRow(
              column(1, div(style = "display: flex; align-items: center; height: 75%;",tags$label("Feature:"))),
              column(11, selectInput("feature", NULL, 
                                     choices = c("job_title", "employment_type", "experience_level", "employee_residence", "remote_ratio", "company_size"), selected = "job_title"),)
            ),
            plotOutput("salary_distribution", height = 250),
            plotOutput("salary_average", height = 250)
          )
        )
      )
  )
}

original_data_ui <- function() {
  DT::dataTableOutput("ordinal_data")
}