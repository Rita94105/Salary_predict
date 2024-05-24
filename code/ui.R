library(shiny)
library(bslib)
library(bsicons)

data_ui <- function() {
  div(style='overflow-y: scroll;',
  layout_columns(
    card(card_header("Introduction", class = "h6 text-primary"),
         p("In our Data Science course this semester, we were particularly intrigued by the current landscape of data science-related careers, specifically focusing on compensation trends."),
         p("To satisfy our curiosity and academic requirements, we decided to explore a relevant dataset found on Kaggle: Data Engineer Salary in 2024.")),
    value_box(title = "Type of Job Title",
              textOutput("job_title"),
              showcase = bs_icon("stars"),
              theme = "success"),
    value_box(title = "Data Rows",
              textOutput("number_of_rows"),
              showcase = bs_icon("person"),
              theme = "secondary"),
    value_box(title = "Avg Salary in USD",
              textOutput("average_salary"),
              showcase = bs_icon("coin"),
              theme = "info"),
    card(card_header("Salary distribution in USD", class = "h6 text-success"),
         plotOutput("salary_bar")),
    card(card_header("Wrok experience distribution", class = "h6 text-success"),
         plotOutput("work_bar")),
    card(card_header("Experience Level vs Salary", class = "h6 text-success"),
         plotOutput("experience_salary")),
    card(card_header("Remote Ratio vs Salary", class = "h6 text-success"),
         plotOutput("remote_salary")),
    col_widths = c(12, 4, 4, 4, 6, 6, 6, 6),
    row_heights = c(1.25, 1, 1.5, 1.5),
    max_height = "130vh",
  )
  )
}

original_data_ui <- function() {
  DT::dataTableOutput("ordinal_data")
}

ui <- page_navbar(
  #title = div(img(src="cs.png", height = "30px", weight = "30px"),"Salary Prediction 2024",style=" padding-top: 30px; padding-right: 20px;"),
  title = "Salary Prediction 2024",
  theme = bs_theme(version = 5, bootswatch = "minty"),
  nav_menu(
    title = "Data",
    nav_panel("Introductin", data_ui()),
    nav_panel("Original Data", original_data_ui()),
    nav_panel("Cleaned Data", "Tab content 3")
  ),
  nav_menu(title = "Traning",
           nav_panel("Random Forest", "Tab content 4"),
           nav_panel("GBM", "Tab content 5")
  ),
  nav_menu(title = "Prediction",
           nav_panel("Salary Prediction", "Tab content 6")
  )
)