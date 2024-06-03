##### Initialization #####
# encoding type
encoding_type <- "onehot"
encoding_type <- "target"

# sin log function
signedlog10 <- function(x) {
  ifelse(abs(x) <= 1, 0, sign(x) * log10(abs(x)))
}

# log file
dir.create("./logs", showWarnings = F)
log_path <- paste0(format(Sys.time(), "%Y%m%d_%H%M%S"),
                   "_regression_", encoding_type,"_log.txt")
log_path <- file.path("logs", log_path)

# 將輸出重定向到文件
sink(log_path)

# Logger
logger <- function(msg){
  msg <- paste(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), msg, "\n")
  cat(msg)
}

if (encoding_type == "onehot"){
  logger("Use One Hot Encoding") 
} else {
  logger("Use Target Encoding")
}

# Import Packages
library(tidyverse)
library(magrittr)
library(data.table)

library(randomForest)
library(gbm)
library(class)

library(caret)
library(caretEnsemble)
logger("Import Packages Complete.")

##### read dataset ##### 
if (encoding_type == "onehot"){
  data <- read.csv("./Data/salaries.csv")
} else {
  source("./Preprocessing.R")
}
setDT(data)

##### Data Preprocessing ##### 

# use sin log
data[, salary_in_usd := signedlog10(salary_in_usd)]
# data[, salary_in_usd := NULL]

# remove useless columns
if (encoding_type == "onehot"){
  # one hot encoding
  data <- data[, !c("work_year", "salary", "salary_currency")]
  
  # turn all feature into factor
  cols <- names(data[, !c("salary_in_usd")])
  data[, (cols) := lapply(.SD, as.factor), .SDcols = cols]
  
} else {
  # target encoding
  data <- data[, !c("work_year", "experience_level", "employment_type",
                    "job_title", "salary", "salary_currency",
                    "employee_residence", "company_location", "company_size",
                    "company_location_encoded",
                    "salary_in_usd_double")]
}

# remove outliers of y
Q1 <- quantile(data$salary_in_usd, 0.25, na.rm = T)
Q3 <- quantile(data$salary_in_usd, 0.75, na.rm = T)
IQR <- Q3 - Q1
lower_bound <- Q1 - 1.5 * IQR
upper_bound <- Q3 + 1.5 * IQR
data <- data[salary_in_usd > lower_bound & salary_in_usd < upper_bound]

##### Train Test Split #####
# train:test = 8:2
data$i <- runif(nrow(data))
train_data <- subset(data, i >= 0.2)
test_data <- subset(data, i < 0.2)
train_data$i <- NULL
test_data$i <- NULL

logger("Data Preprocessing Complete.")

##### Model Training #####
logger("Start Model Training...")

# cross validation
ctrl <- trainControl(
  method = "cv",                # 使用交叉驗證
  number = 5,                   # 交叉驗證的折數
  savePredictions = "final",    # 儲存最後的預測值
  returnData = TRUE,            # 返回訓練數據
  returnResamp = "final",       # 返回最終的重抽樣結果
  verboseIter = TRUE            # 顯示每個迭代的詳細資訊
)

# grid search
param_grid <- expand.grid(
  n.trees = 150,
  interaction.depth = 5,
  shrinkage = 0.1,
  n.minobsinnode = 10
)

# null model
null_model <- train(
  salary_in_usd~.,
  data = train_data,
  method = "null",
  trControl = ctrl,
  metric = "RMSE"
)
null_model

logger("Null Model:")
null_model
cat("=====================================================================\n")

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

cat("=====================================================================\n")

# ensemble model
ens_model <- caretEnsemble(model)

logger("Ensemble Model:")
ens_model

# times
ens_model$models$rf$times[1:2]
ens_model$models$gbm$times[1:2]

# best hyperparameters
ens_model$models$rf$bestTune
ens_model$models$gbm$bestTune

# measurements
ens_model$models$rf$resample
ens_model$models$gbm$resample

# confusion matrix
logger("RMSE:")
logger(RMSE(ens_model$ens_model$finalModel$fitted.values,
            ens_model$ens_model$finalModel$data$.outcome))

logger("Model Training Complete.")
##### Model Predict #####
logger("Model Prediction")
# pred vs true
logger("RMSE:")
test_data$pred <- predict(ens_model, newdata = test_data %>% select(-salary_in_usd), type = "raw")
logger(RMSE(test_data$salary_in_usd, test_data$pred))

##### feature importance #####
logger("Feature Importance:")
### Overall
vars <- colnames(train_data %>% select(-salary_in_usd))
original_vars <- c("experience_level", "employment_type", "job_title",
                   "employee_residence", "remote_ratio", "company_location",
                   "company_size")

importance <- varImp(ens_model, scale = T)

importance_values <- sapply(original_vars, function(var) {
  sum(importance[grep(var, rownames(importance)), "overall"])
})

# 創建一個資料框顯示合併後的特徵重要性
importance_df <- data.frame(
  Feature = original_vars,
  Importance = importance_values
)

# 排序並顯示結果
importance_df <- importance_df %>% arrange(desc(Importance))
importance_df

### Detail
importance <- varImp(ens_model, scale = T)
importance <- data.frame(feature_name = row.names(importance),
                         importance)

importance %>% arrange(-overall) %>% head(10)

cat("=====================================================================\n")

# 關閉文件輸出
sink()

# ggplot(data = test_data, aes(x = salary_in_usd, y = salary_in_usd- pred))+
#   geom_point()+
#   stat_smooth(method="loess")+
#   geom_hline(yintercept=0, col="red", linetype="dashed")
# 
# library(ggcorrplot)
# 
# ggcorrplot(cor(data %>% select(-salary_in_usd)), lab = T)

# 查看訓練過程中的詳細資訊（可選）
# cat(readLines("./logs/training_output.txt"), sep = "\n")