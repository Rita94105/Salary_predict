# [Data Engineer Salary Predict](https://rita94105.shinyapps.io/Salary_2024/)

In our Data Science course this semester, we were particularly intrigued by the current landscape of data science-related careers, specifically focusing on compensation trends. To satisfy our curiosity and academic requirements, we decided to explore a relevant dataset found on Kaggle: "Data Engineer Salary in 2024."

## Contributors

|     | Name   | ID        | Workload             |
|-----|--------|-----------|----------------------|
| 1   | 陳文遠 | 112971012 | Data processing      |
| 2   | 王世儒 | 112971006 | Model training       |
| 3   | 任芝萱 | 112971020 | Shiny app developing |

## [Data](https://www.kaggle.com/datasets/chopper53/data-engineer-salary-in-2024)

### About Data Set

This dataset provides insights into data engineer salaries and employment attributes for the year 2024. It includes information such as salary, job title, experience level, employment type, employee residence, remote work ratio, company location, and company size.

The dataset allows for analysis of salary trends, employment patterns, and geographic variations in data engineering roles. It can be used by researchers, analysts, and organizations to understand the evolving landscape of data engineering employment and compensation.

### Feature Description

-   work_year: The year in which the data was collected (2024).
-   experience_level: The experience level of the employee, categorized as SE (Senior Engineer), MI (Mid-Level Engineer), or EL (Entry-Level Engineer).
-   employment_type: The type of employment, such as full-time (FT), part-time (PT), contract (C), or freelance (F).
-   job_title: The title or role of the employee within the company, for example, AI Engineer.
-   salary: The salary of the employee in the local currency (e.g., 202,730 USD).
-   salary_currency: The currency in which the salary is denominated (e.g., USD).
-   salary_in_usd: The salary converted to US dollars for standardization purposes.
-   employee_residence: The country of residence of the employee.
-   remote_ratio: The ratio indicating the extent of remote work allowed in the position (0 for no remote work, 1 for fully remote).
-   company_location: The location of the company where the employee is employed.
-   company_size: The size of the company, often categorized by the number of employees (S for small, M for medium, L for large).

### Our Target
We try to use the features of the dataset to predict the salaries of data science-related jobs.

## Exploratory Data Analysis(EDA)

### Boxplot

-   x: categorical feature

-   y: salary_in_usd

-   order by [median of salary_in_usd] descending

### Barplot

-   x: categorical feature

-   y: [avg. of salary_in_usd] or [counts]

-   order by [avg. of salary_in_usd] or [counts] descending

### Histogram: salary_in_usd

-   x: bins

-   y: frequency

### Histogram: signedlog10(salary_in_usd)

-   x: bins

-   y: frequency

## Data Preprocessing

### Library

1.  [smotfamily](https://cran.r-project.org/web/packages/smotefamily/smotefamily.pdf)
2.  [ggplot2](https://cran.r-project.org/web/packages/ggplot2/ggplot2.pdf)

### Process

1.  Checking the type of data
2.  Dropping the duplicate data
3.  Counting the number of rows
4.  Dropping the missing or null value
5.  Detecting outliers
6.  SMOTE
7.  Ordinal Encoding
8.  Target Encoding
9.  One-hot encoding
10. Clustering data by kmeans
11. Spliting data by salary_in_usd 150000

We use the sine logarithm to transform our prediction target.
``` r
# sin log function
signedlog10 <- function(x) {
  ifelse(abs(x) <= 1, 0, sign(x) * log10(abs(x)))
}
```

## Model training and results

### Target Encoding

We use target encoding to calculate the mean of signedlog10(salary_in_usd) for each feature.

After target encoding, we generate the correlation matrix for the features.

``` r
library(ggcorrplot)
correlation_matrix <- cor(data %>% select(-salary_in_usd))
ggcorrplot(correlation_matrix, lab = T)
```

### Training

We use random forest and gradient boosting to build an ensemble learning model to predict signedlog10(salary_in_usd).

``` r
library(randomForest)
library(gbm)

library(caret)
library(caretEnsemble)

# cross validation
ctrl <- trainControl(
  method = "cv",                
  number = 5,                   
  savePredictions = "final",    
  returnData = TRUE,            
  returnResamp = "final",       
  verboseIter = TRUE            
)

# grid search
param_grid <- expand.grid(
  n.trees = 150,
  interaction.depth = 5,
  shrinkage = 0.1,
  n.minobsinnode = 10
)

# model
model <- caretList(
  salary_in_usd~.,
  data = train_data, 
  metric = "RMSE",
  verbose = T,
  trControl = ctrl,
  tuneList = list(
    rf = caretModelSpec("rf", tuneGrid = data.frame(mtry = 2)),
    gbm = caretModelSpec("gbm", tuneGrid = param_grid)
  )
)

# ensemble model
ens_model <- caretEnsemble(model)
```

### Feature Importance

dataframe

### Measurement

MAE:

RMSE:

scatter plot: true vs pred

### Prediction

MAE:

RMSE:

scatter plot: true vs pred

### Compare with Kaggle
1. Our Performance

|     | Train / Test   | MAE        | RMSE             |
|-----|--------|-----------|----------------------|
| 1   | Train | 0 | 0      |
| 2   | Test | 0 | 0       |

3. [AIML salaries 2022-2024 AutoViz+CatBoost+SHAP](https://www.kaggle.com/code/dima806/aiml-salaries-2022-2024-autoviz-catboost-shap)

- RMSE score for train 51.4 kUSD/year, and for test 52.0 kUSD/year

3. [Neural Network Regression Models](https://www.kaggle.com/code/samuelmason23/neural-network-regression-models)

- train MAE: 40320.1875

- test MAE: 40320.18831030768

- test RMSE: 57857.07162184822

### Improvement

## Reference
