# [Group01] Data Engineer Salary Predict

## Contributors 
||Name|ID|Workload|
|-|---|---|---|
|1| 陳文遠|112971012|Data processing|
|2| 王世儒|112971006|Model training|
|3| 任芝萱|112971020|Shiny app developing|

## Description

In our Data Science course this semester, we were particularly intrigued by the current landscape of data science-related careers, specifically focusing on compensation trends. To satisfy our curiosity and academic requirements, we decided to explore a relevant dataset found on Kaggle: "Data Engineer Salary in 2024."

## [Data](https://www.kaggle.com/datasets/chopper53/data-engineer-salary-in-2024)

### About Data Set

  This dataset provides insights into data engineer salaries and employment attributes for the year 2024.
  It includes information such as salary, job title, experience level, employment type, employee residence, remote work ratio, company location, and company size.
  
  The dataset allows for analysis of salary trends, employment patterns, and geographic variations in data engineering roles.
  It can be used by researchers, analysts, and organizations to understand the evolving landscape of data engineering employment and compensation.

### Feature Description
  - work_year: The year in which the data was collected (2024).
  - experience_level: The experience level of the employee, categorized as SE (Senior Engineer), MI (Mid-Level Engineer), or EL (Entry-Level Engineer).
  - employment_type: The type of employment, such as full-time (FT), part-time (PT), contract (C), or freelance (F).
  - job_title: The title or role of the employee within the company, for example, AI Engineer.
  - salary: The salary of the employee in the local currency (e.g., 202,730 USD).
  - salary_currency: The currency in which the salary is denominated (e.g., USD).
  - salary_in_usd: The salary converted to US dollars for standardization purposes.
  - employee_residence: The country of residence of the employee.
  - remote_ratio: The ratio indicating the extent of remote work allowed in the position (0 for no remote work, 1 for fully remote).
  - company_location: The location of the company where the employee is employed.
  - company_size: The size of the company, often categorized by the number of employees (S for small, M for medium, L for large).

## Data Preprocessing

### Library
### Process
1. Checking the type of data
2. Dropping the duplicate data
3. Counting the number of rows
4. Dropping the missing or null value
5. Detecting outliers
6. One-hot encoding
7. Data cluster by kmeans
8. Spliting data by salary_in_usd 150000

## Model training and results

### Library

### Random Forest

### GBM

## Reference
