library(ggplot2)

data <- read.csv("./Data/salaries.csv")

# 薪資分布
ggplot(data, aes(x = salary_in_usd)) +
  geom_histogram(binwidth = 50000, fill = "orange", color = "black") +
  labs(title = "Distribution of Salaries in USD",
       x = "Salary in USD",
       y = "Frequency") +
  scale_x_continuous(labels = scales::comma) +
  theme_minimal()

# 工作經驗分佈
ggplot(data, aes(x = experience_level)) +
  geom_bar(fill = "yellow", color = "black") +
  labs(title = "Distribution of Experience Levels",
       x = "Experience Level",
       y = "Count") +
  theme_minimal()

# 工作經驗對於薪資(美元)箱形圖
ggplot(data, aes(x = experience_level, y = salary_in_usd)) +
  geom_boxplot() +
  labs(title = "Experience Level vs Salary in USD",
       x = "Experience Level",
       y = "Salary in USD") +
  scale_y_continuous(labels = scales::comma) +
  theme_minimal()

# 遠端性質對於薪資(美元)箱形圖
ggplot(data, aes(x = factor(remote_ratio), y = salary_in_usd)) +
  geom_boxplot() +
  labs(title = "Remote Ratio vs Salary in USD",
       x = "Remote Ratio",
       y = "Salary in USD") +
  scale_y_continuous(labels = scales::comma) +
  theme_minimal()

# 公司大小對於薪資(美元)直方圖
ggplot(data, aes(x = company_size, y = salary_in_usd, fill = company_size)) +
  geom_bar(stat = "summary", fun = "mean") +
  labs(title = "Average Salary by Company Size",
       x = "Company Size",
       y = "Average Salary in USD")

# ggplot(data, aes(x = reorder(employee_residence, salary_in_usd, median), y = salary_in_usd)) +
#   geom_boxplot() +
#   coord_flip() +
#   labs(title = "Salary Distribution by Employee Residence",
#        x = "Employee Residence",
#        y = "Salary in USD")
# 
# ggplot(data, aes(x = reorder(job_title, salary_in_usd, median), y = salary_in_usd)) +
#   geom_boxplot() +
#   coord_flip() +
#   labs(title = "Salary Distribution by Job Title",
#        x = "Job Title",
#        y = "Salary in USD")
