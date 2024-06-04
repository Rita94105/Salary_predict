library(shiny)
library(bslib)
library(bsicons)

data_preprocessing_ui <- function(){
  div(style = 'overflow-y: auto;',
      fluidRow(
        column(
          width = 12,
          h3("Step 1: Checking the type of data"),
          br(),
          verbatimTextOutput("step1_summary"),
          verbatimTextOutput("step1_str"),
          br(),
        ),
        column(
          width = 12,
          h3("Step 2: Checking data distribution"),
          br(),
          verbatimTextOutput("step2"),
          br(),
        ),
        column(
          width = 12,
          h3("Step 3: Checking missing values"),
          br(),
          verbatimTextOutput("step3"),
          br(),
        ),
        column(
          width = 12,
          h3("Step 4: Checking Outliers"),
          br(),
          verbatimTextOutput("step4"),
          plotOutput("step4_plot"),
          verbatimTextOutput("step4_process"),
          br()
        ),
        column(
          width = 12,
          h3("Step 5: Ordinal Encoding"),
          br(),
          h6("1. experience_level :\n"),
          br(),
          verbatimTextOutput("step5_1"),
          br(),
          h6("2. company_size :\n"),
          br(),
          verbatimTextOutput("step5_2"),
          br()
        ),
        column(
          width = 12,
          h3("Step 6: Target Encoding"),
          br(),
          h6("Category : employment_type, job_title, employee_residence, company_location\n"),
          br(),
          verbatimTextOutput("step6"),
          img(src = "correlation_matrix.png", alt = "Correlation Matrix", height = 800, width = 800)
        ),
        column(
          width = 12,
          h3("Step 7: One-hot Encoding"),
          br(),
          p("During testing, it was found that One-hot Encoding led to an excessive number of features, resulting in decreased accuracy and increased training time. Therefore, it was ultimately not adopted."),
          verbatimTextOutput("step7"),
          br()
        ),
        column(
          width = 12,
          h3("Step 8: Splitting the data into training and testing sets "),
          br(),
          p("The original plan was to use K-means to create new features. However, since all the features within the dataset are categorical in nature, the K-means method is not feasible."),
          verbatimTextOutput("step8_1"),
          p("Therefore, in the end, 80% of the data was selected for training using an index-based approach, while 20% was reserved for testing."),
          verbatimTextOutput("step8_2"),
          br()
        ),
        column(
          width = 12,
          h3("Step 9: Transforming the target variable"),
          br(),
          verbatimTextOutput("step9"),
          br(),
        ),
        column(
          width = 12,
          hr(),
          h3("Others Functions: "),
          br(),
          verbatimTextOutput("function_code")
        )
      )
  )
}