source('function.R')

library(ggplot2)
library(ggcorrplot)
library(readxl)

server <- function(input, output) {
  #bs_themer()
  
  observe({
    showModal(modalDialog(
      title = "Let predict salary together!",
      HTML("Hi everyone, <br>
             The project focus on the salary of the positions in data field.<br> 
             Hope you have a great day and enojoy our result!"),
      easyClose = TRUE,
      footer = NULL
    ))
  })

  #data <- read.csv("../Data/salaries.csv")
  
  # use when publish on Shinyapps
  data <- read.csv("salaries.csv")
  
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
  
  # Salary Distribution
  output$salary_distribution <- renderPlot({
    feature <- input$feature
    formula <- as.formula(paste("salary_in_usd ~", feature))  
    
    median_salaries <- aggregate(formula, data = data, median)
    median_salaries <- median_salaries[order(-median_salaries$salary_in_usd), ]
    
    if (feature %in% c("job_title", "employee_residence")) {
      top_feature <- median_salaries[1:20, ]
    } else {
      top_feature <- median_salaries
      
    }
    data_top <- data[data[[feature]] %in% top_feature[[feature]], ]
    
    data_top[[feature]] <- factor(data_top[[feature]], levels = top_feature[[feature]])
    
    plot <- ggplot(data_top, aes(x = get(feature), y = salary_in_usd)) +
      geom_boxplot(fill = "lightgrey", alpha = 0.7) +
      labs(title = paste("Boxplot of Salary in USD by", feature),
           x = feature,
           y = "Salary in USD") +
      scale_y_continuous(labels = scales::comma) +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1)) 
    return(plot)
  })
  
  # Salary Average
  output$salary_average <- renderPlot({
    feature <- input$feature
    formula <- as.formula(paste("salary_in_usd ~", feature)) 
    
    avg_salaries <- aggregate(formula, data = data, FUN = mean)
    colnames(avg_salaries)[1] <- feature
    
    if (feature %in% c("job_title", "employee_residence")) {
      avg_salaries <- avg_salaries[order(-avg_salaries$salary_in_usd), ][1:20, ]
    } else {
      avg_salaries <- avg_salaries[order(-avg_salaries$salary_in_usd), ]
    }
    
    avg_salaries[[feature]] <- factor(avg_salaries[[feature]], levels = avg_salaries[[feature]])
    
    plot <- ggplot(avg_salaries, aes_string(x =feature, y = "salary_in_usd")) +
      geom_bar(stat = "identity", fill = "yellow", color = "black", alpha = 0.8) +
      labs(title = paste("Bar Plot of Average Salary in USD by", feature),
           x = feature,
           y = "Average Salary in USD") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
      scale_y_continuous(labels = scales::comma)
    
    return(plot)
  })
  
  # Histogram of Salary Distribution
  output$histogram_salary_in_usd <- renderPlot({
    plot <- ggplot(data, aes(x = salary_in_usd)) +
      geom_histogram(binwidth = 20000, fill = "orange", color = "black", alpha = 0.7) +
      labs(x = "Salary in USD",
           y = "Frequency") +
      theme_minimal() +
      scale_x_continuous(labels = scales::comma)
    scale_y_continuous(labels = scales::comma)
    
    return(plot)
  })
  
  #Histogram of Log Salary in USD
  output$salary_in_log <- renderPlot({
    log_df <- data
    log_df$salary_in_log <- log(log_df$salary_in_usd)
    log_df$sin_log_salary <- sin(log_df$salary_in_log)
    
    plot <- ggplot(log_df, aes(x = salary_in_log)) +
      geom_histogram(bins = 20, fill = "lightblue", color = "black", alpha = 0.7) +
      labs(x = "Log Salary in USD",
           y = "Frequency") +
      theme_minimal() +
      scale_y_continuous(labels = scales::comma)
    
    return(plot)
  })
  
  # Step 1: Checking the type of data
  output$step1_summary <- renderPrint({
    cat("summary(data)\n\n")
    summary(data)
  })
  
  output$step1_str <- renderPrint({
    cat("str(data)\n\n")
    str(data)
  })
  
  # Step 2: Checking data distribution
  output$step2 <- renderPrint({
    cat("class_distribution <- table(data$company_size)\n")
    table(data$company_size)
  })
  
  # Step 3: Checking missing values
  output$step3 <- renderPrint({
    cat("missing_values <- colSums(is.na(data))\n\n")
    colSums(is.na(data))
  })
  
  # Step 4: Checking Outliers
  output$step4 <- renderPrint({
    cat("boxplot(data$salary_in_usd, main = \"Boxplot\")")
  })
  
  output$step4_plot <- renderPlot({
    boxplot(data$salary_in_usd, main = "Boxplot")
  })
  
  output$step4_process <- renderPrint({
    cat("data <- process_outliers(data, c(\"salary_in_usd\"))\n\n")
    data <- process_outliers(data, c("salary_in_usd"))
  })
  
  # Step 5: Ordinal Encoding
  output$step5_1 <- renderPrint({
    cat("experience_levels <- c(\"EN\", \"MI\", \"SE\", \"EX\")",
        "data <- ordinal_encoding(data, \"experience_level\", \"experience_level_encoded\", experience_levels)\n",
        sep = "\n")
  })
  
  output$step5_2 <- renderPrint({
    cat("company_size_levels <- c(\"S\", \"M\", \"L\")\n",
        "data <- ordinal_encoding(data, \"company_size\", \"company_size_encoded\", company_size_levels)",
        sep = "\n")
  })
  
  # Step 6: Target Encoding
  output$step6 <- renderPrint({
    cat("data$employment_type_encoded <-target_encoding(data, \"employment_type\", target_encode_col_name)",
        "data$job_title_encoded <- target_encoding(data, \"job_title\", target_encode_col_name)",
        "data$employee_residence_encoded <- target_encoding(data, \"employee_residence\", target_encode_col_name)",
        "data$company_location_encoded <- target_encoding(data, \"company_location\", target_encode_col_name",
        sep = "\n\n")
  })
  
  # Step 7: One-hot Encoding
  output$step7 <- renderPrint({
    cat("cols_encoding <- c(\"experience_level\",\"employment_type\",\"job_title\",\"employee_residence\",\"company_location\",\"company_size\")",
        "for (col in cols_encoding) {",
        "  data <- do_one_hot_encoding(data, col)",
        "}",
        sep = "\n\n")
  })
  
  # Step 8: Splitting the data into training and testing sets
  output$step8_1 <- renderPrint({
    cat("data$salary_in_usd_cluster <- do_kmeans(data, 10)\n")
  })
  
  output$step8_2 <- renderPrint({
    cat("data$i <- runif(nrow(data))",
        "train_data <- subset(data, i >= 0.2)",
        "test_data <- subset(data, i < 0.2)",
        "train_data$i <- NULL",
        "test_data$i <- NULL",
        sep = "\n")
  })
  
  # Step 9: Transforming the target variable
  output$step9 <- renderPrint({
    cat("signedlog10 <- function(x) {",
        "   ifelse(abs(x) <= 1, 0, sign(x) * log10(abs(x)))",
        "}",
        sep = "\n")
  })
  
  # show function.R
  output$function_code <- renderPrint({
    file <- "function.R"
    cat(readLines(file), sep = "\n")
  })
  
  # training result
  # training result
  output$training_tabs <- renderUI({
    file <- "model_details.xlsx"
    sheets <- excel_sheets(file)
    
    do.call(tabsetPanel, lapply(sheets, function(sheet) {
      tabPanel(
        title = sheet,
        DT::dataTableOutput(outputId = paste0("table_", sheet))
      )
    }))
  })
  
  # Render each sheet as a DataTable
  observe({
    file <- "model_details.xlsx"
    sheets <- excel_sheets(file)
    
    lapply(sheets, function(sheet) {
      output[[paste0("table_", sheet)]] <- DT::renderDataTable({
        data <- read_excel(file, sheet = sheet)
        DT::datatable(data)
      })
    })
  })
  
  # final_model code({
  output$model_code <- renderPrint({
    file <- "final_model.R"
    cat(readLines(file), sep = "\n")
  })
  
  # Original Data
  output$ordinal_data <- DT::renderDataTable({
    DT::datatable(data, options = list(pageLength = 50))
  })
}
