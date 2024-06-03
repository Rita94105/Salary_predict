source('./function.R')
library(data.table)
library(dataPreparation)

# work_year: The year in which the data was collected (2024).
# experience_level: The experience level of the employee, categorized as SE (Senior Engineer), MI (Mid-Level Engineer), or EL (Entry-Level Engineer).
# employment_type: The type of employment, such as full-time (FT), part-time (PT), contract (C), or freelance (F).
# job_title: The title or role of the employee within the company, for example, AI Engineer.
# salary: The salary of the employee in the local currency (e.g., 202,730 USD).
# salary_currency: The currency in which the salary is denominated (e.g., USD).
# salary_in_usd: The salary converted to US dollars for standardization purposes.
# employee_residence: The country of residence of the employee.
# remote_ratio: The ratio indicating the extent of remote work allowed in the position (0 for no remote work, 1 for fully remote).
# company_location: The location of the company where the employee is employed.
# company_size: The size of the company, often categorized by the number of employees (S for small, M for medium, L for large).

data <- read.csv("./Data/salaries.csv")

summary(data)

str(data)

target_name <- "salary_in_usd"

class_distribution <- table(data$company_size)
print(class_distribution)

# check missing values
missing_counts <- colSums(is.na(data))
print(missing_counts)

# check outliers: salary/salary_in_usd
boxplot(data$salary_in_usd, main = "Boxplot")

data <- process_outliers(data, c("salary_in_usd"))

# remote_ratio: 0, 50, 100 -> encoding?

# ordinal: experience_level, company_size

experience_levels <- c("EN", "MI", "SE", "EX")
data <- ordinal_encoding(data, "experience_level", "experience_level_encoded", experience_levels)
data$experience_level_encoded

company_size_levels <- c("S", "M", "L")
data <- ordinal_encoding(data, "company_size", "company_size_encoded", company_size_levels)
data$company_size_encoded

# category: employment_type,job_title,employee_residence,company_location

data$salary_in_usd_double <- as.double(data$salary_in_usd)
target_encode_col_name <- "salary_in_usd_double"

# employment_type: Target encoding
data$employment_type_encoded <-target_encoding(data, "employment_type", target_encode_col_name)

# job_title: Target encoding
data$job_title_encoded <- target_encoding(data, "job_title", target_encode_col_name)

# employee_residence: Target encoding
data$employee_residence_encoded <- target_encoding(data, "employee_residence", target_encode_col_name)

# company_location: Target encoding
data$company_location_encoded <- target_encoding(data, "company_location", target_encode_col_name)

