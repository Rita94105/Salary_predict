##### Initialization #####
# encoding type
encoding_type <- "onehot"
# encoding_type <- "target"

# log file
dir.create("./logs", showWarnings = F)
log_path <- paste0(format(Sys.time(), "%Y%m%d_%H%M%S"),
                   "_classification_", encoding_type,"_log.txt")
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

library(caret)
library(caretEnsemble)
logger("Import Packages Complete.")

##### read dataset ##### 
if (encoding_type == "onehot"){
  data <-  read.csv("./Data/salaries.csv")  
} else {
  source("./Preprocessing.R")
}
setDT(data)

##### Data Preprocessing ##### 
THRESHOLD <- data$salary_in_usd %>% median()

# change to binary-classification problem
data[, highsalary := ifelse(salary_in_usd >= THRESHOLD, 1, 0) %>% as.factor]

# remove useless columns
if (encoding_type == "onehot"){
  # one hot encoding
  data <- data[, !c("work_year", "salary", "salary_in_usd", "salary_currency")]
  
  # turn all feature into factor
  data[, (names(data)) := lapply(.SD, as.factor), .SDcols = names(data)]
  
} else {
  # target encoding
  data <- data[, !c("work_year", "experience_level", "employment_type",
                    "job_title", "salary", "salary_in_usd", "salary_currency",
                    "employee_residence", "company_location", "company_size",
                    "salary_in_usd_double")]
}

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
  classProbs = TRUE,            # 對分類問題，儲存類別機率
  summaryFunction = twoClassSummary, # 對分類問題，使用二分類摘要函數
  returnData = TRUE,            # 返回訓練數據
  returnResamp = "final",       # 返回最終的重抽樣結果
  verboseIter = TRUE            # 顯示每個迭代的詳細資訊
)

# label's weights
model_weights <- ifelse(
  train_data$highsalary == 0,
  (1 / table(train_data$highsalary)[1]) * 0.5,
  (1 / table(train_data$highsalary)[2]) * 0.5
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
  make.names(highsalary)~.,
  data = train_data,
  method = "null",
  trControl = ctrl,
  metric = "ROC",
  weights = model_weights,
)

logger("Null Model:")
null_model
cat("=====================================================================\n")

# model
model <- caretList(
  make.names(highsalary)~.,
  data = train_data, 
  metric = "ROC",
  weights = model_weights,
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
logger("Confusion Matrix:")
cm_train <- table(ifelse(ens_model$ens_model$finalModel$fitted.values >= 0.5, 1, 0),
                  ens_model$ens_model$finalModel$data$.outcome)
cm_train

logger("Accuracy:")
accuracy_train <- (cm_train[1, 1] + cm_train[2, 2]) / nrow(train_data)
logger(accuracy_train)

logger("Model Training Complete.")
##### Model Predict #####
logger("Model Prediction")
# pred vs true
test_data$pred <- predict(ens_model, newdata = test_data %>% select(-highsalary), type = "raw")
cm_test <- table(test_data$pred, test_data$highsalary)
logger("Confusion Matrix:")
cm_test

logger("Accuracy:")
accuracy_test <- (cm_test[1, 1] + cm_test[2, 2]) / nrow(test_data)
logger(accuracy_test)

##### feature importance #####
logger("Feature Importance:")
### Overall
vars <- colnames(train_data %>% select(-highsalary))
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

# 查看訓練過程中的詳細資訊（可選）
# cat(readLines("./logs/training_output.txt"), sep = "\n")