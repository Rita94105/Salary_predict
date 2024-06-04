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
            p("Since the advent of ChatGPT, AI applications have flourished, driving a surge in demand for data-related positions. This phenomenon sparked our interest in the salary structures within the data industry. On Kaggle, we discovered a dataset on Data Engineer salaries, which led us to undertake a project aimed at predicting salary ranges in the data field based on features such as region, job title, years of experience, and company size."),
            p("Our research findings indicate that job title is the most critical factor in determining salaries. This insight holds significant value for both job seekers and employers in the data field, aiding in career planning and recruitment strategies."),
            p("This project not only reveals the factors influencing salaries in the data industry but also provides valuable information for those looking to enter the field, helping them make more informed career decisions.")
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
  fluidRow(
    column(
      width = 12,
      div(
        style = "overflow-x: auto;",
        DT::dataTableOutput("ordinal_data")
      )
    )
  )
}