library(ggplot2)
library(dplyr)

df <- read.csv("./Data/salaries.csv")
str(df)
summary(df)

### boxplot

# x: categorical feature
# y: salary_in_usd

#order by [median of salary_in_usd] desc

salaries_box_plot <- function(df, feature, top_num=NULL) {

  formula <- as.formula(paste("salary_in_usd ~", feature))  
  
  median_salaries <- aggregate(formula, data = df, median)
  median_salaries <- median_salaries[order(-median_salaries$salary_in_usd), ]
  
  if (is.null(top_num)) {
    top_feature <- median_salaries
    
  } else {
    top_feature <- median_salaries[1:top_num, ]
  }
  df_top <- df[df[[feature]] %in% top_feature[[feature]], ]
  
  df_top[[feature]] <- factor(df_top[[feature]], levels = top_feature[[feature]])
  
  ggplot(df_top, aes(x = get(feature), y = salary_in_usd)) +
    geom_boxplot(fill = "lightgrey", alpha = 0.7) +
    labs(title = paste("Boxplot of Salary in USD by", feature),
         x = feature,
         y = "Salary in USD") +
    scale_y_continuous(labels = scales::comma) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) 
}

salaries_box_plot(df, "job_title", 20)
salaries_box_plot(df, "employment_type")
salaries_box_plot(df, "experience_level")
salaries_box_plot(df, "employee_residence", 20)
salaries_box_plot(df, "remote_ratio")
salaries_box_plot(df, "company_size")


### bar plot

# x: categorical feature
# y: avg. of salary_in_usd \| counts
# order by [avg. of salary_in_usd] \| counts desc
salaries_bar_plot <- function(df, feature, top_num=NULL) {

  formula <- as.formula(paste("salary_in_usd ~", feature)) 
  
  avg_salaries <- aggregate(formula, data = df, FUN = mean)
  colnames(avg_salaries)[1] <- feature
  
  if (is.null(top_num)) {
    avg_salaries <- avg_salaries[order(-avg_salaries$salary_in_usd), ]
  } else {
    avg_salaries <- avg_salaries[order(-avg_salaries$salary_in_usd), ][1:top_num, ]
  }
  
  avg_salaries[[feature]] <- factor(avg_salaries[[feature]], levels = avg_salaries[[feature]])
  
  ggplot(avg_salaries, aes_string(x =feature, y = "salary_in_usd")) +
    geom_bar(stat = "identity", fill = "yellow", color = "black", alpha = 0.8) +
    labs(title = paste("Bar Plot of Average Salary in USD by", feature),
         x = feature,
         y = "Average Salary in USD") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    scale_y_continuous(labels = scales::comma)
}

salaries_bar_plot(df, "job_title", 20)
salaries_bar_plot(df, "employment_type")
salaries_bar_plot(df, "experience_level")
salaries_bar_plot(df, "employee_residence", 20)
salaries_bar_plot(df, "remote_ratio")
salaries_bar_plot(df, "company_size")

### histogram: salary_in_usd
# x: bins
# y: frequency

histogram_salary_in_usd <- function(df) {
  
  plot <- ggplot(df, aes(x = salary_in_usd)) +
    geom_histogram(binwidth = 20000, fill = "orange", color = "black", alpha = 0.7) +
    labs(title = "Histogram of Salary in USD",
         x = "Salary in USD",
         y = "Frequency") +
    theme_minimal() +
    scale_x_continuous(labels = scales::comma)
  scale_y_continuous(labels = scales::comma)
  
  return(plot)
}
  
salary_in_usd_his_plot <- histogram_salary_in_usd(df)
salary_in_usd_his_plot

### histogram: salary_in_log
# x: bins
# y: frequency
  
histogram_salary_in_log <- function(df) {
  log_df <- df
  log_df$salary_in_log <- log(log_df$salary_in_usd)
  log_df$sin_log_salary <- sin(log_df$salary_in_log)
  
  plot <- ggplot(log_df, aes(x = salary_in_log)) +
    geom_histogram(bins = 20, fill = "lightblue", color = "black", alpha = 0.7) +
    labs(title = "Histogram of Log Salary in USD",
         x = "Log Salary in USD",
         y = "Frequency") +
    theme_minimal() +
    scale_y_continuous(labels = scales::comma)
  
  return(plot)
}

salary_in_log_his_plot <- histogram_salary_in_log(df)
salary_in_log_his_plot

