source('./function.R')

data <- read.csv("./Data/salaries.csv")

# do one-hot encoding
cols_encoding <- c("experience_level","employment_type","job_title","employee_residence",
                   "company_location","company_size")

for (col in cols_encoding) {
  data <- do_one_hot_encoding(data, col)
}

# k-means
# data$salary_in_usd_cluster <- do_kmeans(data, 10)
colnames(data)

# split data by salary_in_usd 150000
high_salary_data <- subset(data, salary_in_usd > 150000)
low_salary_data <- subset(data, salary_in_usd <= 150000)
nrow(high_salary_data)
nrow(low_salary_data)
