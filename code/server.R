library(ggplot2)

server <- function(input, output) {
  bs_themer()
  
  observe({
    showModal(modalDialog(
      title = "Let predict salary together!",
      HTML("Hi everyone, We are group 2! <br>
             The project focus on the salary of the positions in data field.<br> 
             Hope you have a great day and enojoy our result!"),
      easyClose = TRUE,
      footer = NULL
    ))
  })

  #data <- read.csv("../Data/salaries.csv")
  
  # use when publish on Shinyapps
  data <- read.csv("salaries.csv")
  
  # salary distribution
  output$salary_bar <- renderPlot({
    ggplot(data, aes(x = salary_in_usd)) +
      geom_histogram(binwidth = 50000, fill = "#ffce67", color = "black") +
      labs(x = "Salary in USD",
           y = "Frequency") +
      scale_x_continuous(labels = scales::comma) +
      theme_minimal()
  })
  
  #work experience distribution
  output$work_bar <- renderPlot({
    ggplot(data, aes(x = experience_level)) +
      geom_bar(fill = "#E9ECEF", color = "black") +
      labs(title = "Distribution of Experience Levels",
           x = "Experience Level",
           y = "Count") +
      theme_minimal()
  })
  
  #Experience Level vs Salary in USD
  output$experience_salary <- renderPlot({
    data$experience_level_factor <- factor(data$experience_level, levels = c("EN", "MI", "SE", "EX"))
    ggplot(data, aes(x = experience_level_factor, y = salary_in_usd)) +
      geom_boxplot() +
      labs(x = "Experience Level",
           y = "Salary in USD") +
      scale_y_continuous(labels = scales::comma) +
      theme_minimal()
  })
  
  #Remote Ratio vs Salary in USD
  output$remote_salary <- renderPlot({
    ggplot(data, aes(x = factor(remote_ratio), y = salary_in_usd)) +
      geom_boxplot() +
      labs(x = "Remote Ratio",
           y = "Salary in USD") +
      scale_y_continuous(labels = scales::comma) +
      theme_minimal()
  })
  
  # Compute values for value boxes
  output$job_title <- renderText({
      length(unique(data$job_title))
    })
  
  output$number_of_rows <- renderText({
      nrow(data)
    })
  
  output$average_salary <- renderText({
      sum(data$salary_in_usd) / nrow(data)
    })
  
  # Original Data
  output$ordinal_data <- DT::renderDataTable({
    DT::datatable(data, options = list(pageLength = 50))
  })
}