library(shiny)
library(bslib)
library(bsicons)

data_preprocessing_ui <- function(){
  div(style = 'overflow-y: auto;',
      fluidRow(
        column(
          width = 12,
          box(
            title = "Step 1: Checking the type of data", status = "primary", solidHeader = TRUE, width = 12,
            verbatimTextOutput("step1_summary"),
            verbatimTextOutput("step1_str"),
            br(),
          )
        ),
        column(
          width = 12,
          box(
            title = "Step 2: Checking data distribution", status = "primary", solidHeader = TRUE, width = 12,
            verbatimTextOutput("step2"),
            br(),
          )
        ),
        column(
          width = 12,
          box(
            title = "Step 3: Checking missing values", status = "primary", solidHeader = TRUE, width = 12,
            verbatimTextOutput("step3"),
            br(),
          )
        ),
        column(
          width = 12,
          box(
            title = "Step 4: Checking Outliers", status = "primary", solidHeader = TRUE, width = 12,
            verbatimTextOutput("step4"),
            plotOutput("step4_plot"),
            verbatimTextOutput("step4_process"),
            br()
          )
        ),
        column(
          width = 12,
          box(
            title = "Step 5: Ordinal Encodinga", status = "primary", solidHeader = TRUE, width = 12,
            br(),
            h6("1. experience_level :\n"),
            br(),
            verbatimTextOutput("step5_1"),
            br(),
            h6("2. company_size :\n"),
            br(),
            verbatimTextOutput("step5_2"),
            br()
          )
        ),
        column(
          width = 12,
          box(
            title = "Step 6: Target Encoding", status = "primary", solidHeader = TRUE, width = 12,
            br(),
            h6("Category : employment_type, job_title, employee_residence, company_location\n"),
            br(),
            verbatimTextOutput("step6"),
            br()
          )
        ),
        column(
          width = 12,
          box(
            title = "Step 7: One-hot Encoding", status = "primary", solidHeader = TRUE, width = 12,
            verbatimTextOutput("step7"),
            br()
          )
        ),
        column(
          width = 12,
          box(
            title = "Step 8: Splitting the data into training and testing sets ", status = "primary", solidHeader = TRUE, width = 12,
            verbatimTextOutput("step8"),
            br()
          )
        ),
        column(
          width = 12,
          hr(),
          box(
            title = "Others Functions: ", status = "primary", solidHeader = TRUE, width = 12,
            br(),
            verbatimTextOutput("function_code")
          )
        )
      )
  )
}