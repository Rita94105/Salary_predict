source('./function.R')

data <- read.csv("./Data/salaries.csv")

cols_encoding <- c("experience_level","employment_type","job_title","employee_residence",
                   "company_location","company_size")


# do one-hot encoding
for (col in cols_encoding) {
  data <- do_one_hot_encoding(data, col)
}

# k-means
data$salary_in_usd_cluster <- do_kmeans(data, 10)
colnames(data)
