# [Data Engineer Salary Predict](https://rita94105.shinyapps.io/Salary_2024/)

In our Data Science course this semester, we were particularly intrigued by the current landscape of data science-related careers, specifically focusing on compensation trends. To satisfy our curiosity and academic requirements, we decided to explore a relevant dataset found on Kaggle: "Data Engineer Salary in 2024."

## Contributors

|     | Name   | ID        | Workload             |
|-----|--------|-----------|----------------------|
| 1   | 陳文遠 | 112971012 | Data processing      |
| 2   | 王世儒 | 112971006 | Model training       |
| 3   | 任芝萱 | 112971020 | Shiny app developing |

## [Data](https://www.kaggle.com/datasets/chopper53/data-engineer-salary-in-2024)

### About Dataset

This dataset provides insights into data engineer salaries and employment attributes for the year 2024. It includes information such as salary, job title, experience level, employment type, employee residence, remote work ratio, company location, and company size.

The dataset allows for analysis of salary trends, employment patterns, and geographic variations in data engineering roles. It can be used by researchers, analysts, and organizations to understand the evolving landscape of data engineering employment and compensation.

### Feature Description

|     | Feature Name   | Type        | Description             |
|--------|--------|-----------|----------------------|
| 1   | work_year | [❌deprecated] | The year in which the data was collected (2024). |
| 2   |  experience_level | ordinal |    The experience level of the employee, categorized as SE (Senior Engineer), MI (Mid-Level Engineer), or EL (Entry-Level Engineer).   |
| 3   |  employment_type| ordinal |   The type of employment, such as full-time (FT), part-time (PT), contract (C), or freelance (F).    |
| 4   |  job_title| nominal |   The title or role of the employee within the company, for example, AI Engineer.    |
| 5   |  salary| [❌deprecated] |    The salary of the employee in the local currency (e.g., 202,730 USD).   |
| 6   |  salary_currency| [❌deprecated] |   The currency in which the salary is denominated (e.g., USD).    |
| 7   |  salary_in_usd| numerical <br> (🔍predicted) |    The salary converted to US dollars for standardization purposes.   |
| 8   |  employee_residence| nominal |    The country of residence of the employee.   |
| 9   |  remote_ratio| ordinal |    The ratio indicating the extent of remote work allowed in the position (0 for no remote work, 1 for fully remote).   |
| 10   |  company_location| nominal |    The location of the company where the employee is employed.   |
| 11   |  company_size| ordinal |    The size of the company, often categorized by the number of employees (S for small, M for medium, L for large).   |

### Our Target
We try to use these features of the dataset to predict the salaries of data science-related jobs.

## Exploratory Data Analysis(EDA)

| Graph Type   | Horizontal Axis (x)  | Vertical Axis (y)  | Note |
|--------|-----------|----------------------|--------|
| Boxplot   | categorical feature  | salary_in_usd   | order by median descending |
| Barplot   | categorical feature  | avg. of salary_in_usd or counts   | order by value descending |
| Histogram | bins of salary_in_usd  | frequency   |  |
| Histogram | bins of signedlog10(salary_in_usd)  | frequency   |  |

## Data Preprocessing

### Library

1.  [smotfamily](https://cran.r-project.org/web/packages/smotefamily/smotefamily.pdf)
2.  [ggplot2](https://cran.r-project.org/web/packages/ggplot2/ggplot2.pdf)
3.  [dataPreparation](https://cran.r-project.org/web/packages/dataPreparation/index.html)
4.  [data.table](https://cran.r-project.org/web/packages/data.table/index.html)

### Process

1.  Checking the type of data
2.  Dropping the duplicate data
3.  Counting the number of rows
4.  Dropping the missing or null value
5.  Detecting outliers
6.  SMOTE
7.  Ordinal Encoding
8.  Target Encoding
9.  function signedlog10(): transform our prediction target.
``` r
# sin log function
signedlog10 <- function(x) {
  ifelse(abs(x) <= 1, 0, sign(x) * log10(abs(x)))
}
```

## Model Training and Results

### Target Encoding

We use target encoding to calculate the mean of **signedlog10(salary_in_usd)** for each feature.

After target encoding, we use [ggcorrplot](https://cran.r-project.org/web/packages/ggcorrplot/ggcorrplot.pdf) to generate the correlation matrix for the features.

![](/output/correlation_matrix.png)

``` r
library(ggcorrplot)
correlation_matrix <- cor(data %>% select(-salary_in_usd))
ggcorrplot(correlation_matrix, lab = T)+
  labs(title = "correlation matrix",
       x = "",
       y = "")+
  theme_bw()+
  theme(axis.text.x = element_text("BL", "bold", "black", size = 10, angle = 45, hjust = 1),
        axis.text.y = element_text("BL", "bold", "black", size = 10, hjust = 1),
        title = element_text("BL", "bold", size = 10))
```

### Training

1. We use [randomForest](https://cran.r-project.org/web/packages/randomForest/index.html) and gradient boosting ([gbm](https://cran.r-project.org/web/packages/caret/gbm.html)) to build an ensemble learning model to predict **signedlog10(salary_in_usd)**.

2. Ensemble Learning: Use [caret](https://cran.r-project.org/web/packages/caret/index.html) and [caretEnsemble](https://cran.r-project.org/web/packages/caretEnsemble/index.html)
- Functions for creating ensembles of caret models: caretList() and caretStack(). caretList() is a convenience function for fitting multiple caret::train() models to the same dataset. caretStack() will make linear or non-linear combinations of these models, using a caret::train() model as a meta-model, and caretEnsemble() will make a robust linear combination of models using a GLM.

4. We also use cross-validation (5-fold) and grid search to find the best hyperparameters.
5. We use **RMSE of salary_in_usd** to evaluate the performance of model.

- null model: use linear regression(only intercept)
```r
null_model <- lm(salary_in_usd~1, data = train_data)
summary(null_model)

null_rmse <- RMSE(train_data$salary_in_usd %>% arcsignedlog10,
                  null_model$fitted.values %>% arcsignedlog10)
```

- ensemble model = random forest + gradient boosting
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
rf_grid <- expand.grid(
  mtry = c(2)
)

gbm_grid <- expand.grid(
  n.trees = 150,
  interaction.depth = 3,
  shrinkage = 0.1,
  n.minobsinnode = 10
)

# model_list
model_list <- caretList(
  salary_in_usd~.,
  data = train_data, 
  metric = "RMSE",
  verbose = T,
  trControl = ctrl,
  tuneList = list(
    rf = caretModelSpec("rf", tuneGrid = rf_grid),
    gbm = caretModelSpec("gbm", tuneGrid = gbm_grid)
  )
)

# ensemble model
ens_model <- caretEnsemble(model_list)
```

### Feature Importance

| feature_name	| overall	| rf	| gbm |
|---|---|---|---|
| job_title👑	| 41.94337184	| 41.65463988	| 44.24573465 |
| employee_residence	| 29.53998588	| 29.47609937	| 30.04942006 |
| experience_level	| 25.94155302	| 26.09243964	| 24.73837574 |
| company_size	| 1.397332208	| 1.513988644	| 0.467108035 |
| remote_ratio	| 1.177757053	| 1.262832468	| 0.499361506 |
| employment_type	| 0	| 0	| 0 |

### Measurement

| Train / Test           | RMSE             |
|--------|----------------------|
| Train  | 46728.5916975186       |

scatter plot: true vs pred
![](/output/scatterplot_train_data.png)

### Prediction

| Train / Test         | RMSE             |
|--------|----------------------|
| Test | 47087.3351748348        |

scatter plot: true vs pred
![](/output/scatterplot_test_data.png)

### Compare with other results on Kaggle
1. Our Performance👑

| Train / Test           | RMSE             |
|--------|----------------------|
| Train |  46728.5916975186      |
| Test |  47087.3351748348        |

2. [AIML salaries 2022-2024 AutoViz+CatBoost+SHAP](https://www.kaggle.com/code/dima806/aiml-salaries-2022-2024-autoviz-catboost-shap)

- RMSE score for train 51.4 kUSD/year, and for test 52.0 kUSD/year

3. [Neural Network Regression Models](https://www.kaggle.com/code/samuelmason23/neural-network-regression-models)

- test RMSE: 57857.07162184822

## Conclusion
Our accuracy is already significantly better than other results on Kaggle. 

However, this is a passable result. We need more data or features to optimize our model training to achieve results that most people can accept. 

Nonetheless, during the training process, we found that job_title is the most important feature, indicating that job titles play a crucial role in predicting salaries.

## Reference
