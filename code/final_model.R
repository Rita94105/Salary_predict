##### Initialization #####

# random state
set.seed(12345)

# sin log function
signedlog10 <- function(x) {
  ifelse(abs(x) <= 1, 0, sign(x) * log10(abs(x)))
}

# arc sin log function
arcsignedlog10 <- function(x) {
  return(sign(x) * 10^abs(x))
}

# Logger
logger <- function(msg){
  msg <- paste(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), msg, "\n")
  cat(msg)
}

# log file
dir.create("./logs", showWarnings = F)
log_path <- paste0(format(Sys.time(), "%Y%m%d_%H%M%S"),
                   "_predict_salary_log.txt")
log_path <- file.path("logs", log_path)

# to.excel
to.excel <- list()

# 將輸出重定向到文件
sink(log_path)

# Import Packages
library(tidyverse)
library(magrittr)
library(data.table)
library(ggcorrplot)
library(openxlsx)

library(randomForest)
library(gbm)

library(caret)
library(caretEnsemble)

# theme.best
theme.best <- theme_bw()+
  theme(text = element_text("BL", "bold", size = 15 * 1.5),
        title = element_text("BL", "bold", size = 20),
        axis.text.x = element_text("BL", "bold", "black", size = 15),
        axis.text.y = element_text("BL", "bold", "black", size = 15),
        plot.caption = element_text(hjust = 0),
        strip.text = element_text(size = 15 * 1.2),
        strip.text.x = element_text(size = 30),
        legend.position = "bottom",
        legend.justification = "left",
        legend.background = element_rect(linewidth = 1, linetype = "solid", color = "gray")
  )

logger("Import Packages Complete.")

##### read dataset ##### 
source("./Preprocessing.R")
setDT(data)

##### Data Preprocessing ##### 

# use sin log
data[, salary_in_usd := signedlog10(salary_in_usd)]

# remove useless columns
data <- data[, !c("work_year", "experience_level", "employment_type",
                  "job_title", "salary", "salary_currency",
                  "employee_residence", "company_location", "company_size",
                  "salary_in_usd_double")]

# remove outliers of y
Q1 <- quantile(data$salary_in_usd, 0.25, na.rm = T)
Q3 <- quantile(data$salary_in_usd, 0.75, na.rm = T)
IQR <- Q3 - Q1
lower_bound <- Q1 - 1.5 * IQR
upper_bound <- Q3 + 1.5 * IQR
data <- data[salary_in_usd > lower_bound & salary_in_usd < upper_bound]

# correlation matrix
correlation_matrix <- cor(data %>% select(-salary_in_usd))
ggcorrplot(correlation_matrix, lab = T)+
  labs(title = "correlation matrix",
       x = "",
       y = "")+
  theme_bw()+
  theme(axis.text.x = element_text("BL", "bold", "black", size = 10, angle = 45, hjust = 1),
        axis.text.y = element_text("BL", "bold", "black", size = 10, hjust = 1),
        title = element_text("BL", "bold", size = 10))

ggsave('./output/correlation_matrix.png',
       dpi = 200, width = 20, height = 20, units = c('cm'))

# according to the correlation matrix, remove "company_location_encoded"
data <- data[, company_location_encoded := NULL]

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
  returnData = T,            # 返回訓練數據
  returnResamp = "final",       # 返回最終的重抽樣結果
  verboseIter = T            # 顯示每個迭代的詳細資訊
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

# null model: use linear regression(only intercept)
logger("Null Model:")
null_model <- lm(salary_in_usd~1, data = train_data)
summary(null_model)

null_rmse <- RMSE(train_data$salary_in_usd %>% arcsignedlog10,
                  null_model$fitted.values %>% arcsignedlog10)

logger(paste0("RMSE: ", null_rmse))

cat("=====================================================================\n")

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

cat("=====================================================================\n")

# ensemble model
logger("Ensemble Model:")
ens_model <- caretEnsemble(model_list)
ens_model

train_data$pred <- ens_model$ens_model$finalModel$fitted.values

train_rmse <- RMSE(train_data$salary_in_usd %>% arcsignedlog10,
                   train_data$pred %>% arcsignedlog10)

logger(paste0("RMSE: ", train_rmse))

# scatterplot: pred vs true
train_min <- min(train_data$pred %>% arcsignedlog10 %>% min, 
                 train_data$salary_in_usd %>% arcsignedlog10 %>% min)

train_max <- max(train_data$pred %>% arcsignedlog10 %>% max, 
                 train_data$salary_in_usd %>% arcsignedlog10 %>% max)

ggplot(data = train_data,
       aes(x = salary_in_usd %>% arcsignedlog10,
           y = pred %>% arcsignedlog10))+
  geom_point(size = 3, alpha  = .5)+
  geom_abline(intercept = 1, col = "red", size = 1, linetype = "dashed")+
  labs(title = "true vs pred of train_data",
       x = "salary_in_usd",
       y = "pred. of salary_in_usd")+
  scale_x_continuous(limits = c(train_min, train_max), labels = scales::comma)+
  scale_y_continuous(limits = c(train_min, train_max), labels = scales::comma)+
  theme.best

ggsave('./output/scatterplot_train_data.png',
       dpi = 200, width = 20, height = 20, units = c('cm'))

##### Feature Importance #####
logger("Feature Importance:")
importance <- varImp(ens_model)
importance <- data.table(feature_name = row.names(importance),
                         importance)

importance <- importance[order(-overall)]
importance[, feature_name := feature_name %>% str_replace_all("_encoded", "")]
importance

logger("Model Training Complete.")

##### Cross-Validation & bestTune #####
logger("Cross-Validation & bestTune")
logger("Overall")
ens_model$error

logger("random forest")
ens_model$models$rf$results
ens_model$models$rf$resample

logger("gradient boosting")
ens_model$models$gbm$results
ens_model$models$gbm$resample

##### Model Predict #####
logger("Model Prediction")
test_data$pred <- predict(ens_model, 
                          newdata = test_data %>% select(-salary_in_usd),
                          type = "raw")

test_rmse <- RMSE(test_data$salary_in_usd %>% arcsignedlog10,
                  test_data$pred %>% arcsignedlog10)

logger(paste0("RMSE: ", test_rmse))

# scatterplot: pred vs true
test_min <- min(test_data$pred %>% arcsignedlog10 %>% min, 
                test_data$salary_in_usd %>% arcsignedlog10 %>% min)

test_max <- max(test_data$pred %>% arcsignedlog10 %>% max, 
                test_data$salary_in_usd %>% arcsignedlog10 %>% max)

ggplot(data = test_data,
       aes(x = salary_in_usd %>% arcsignedlog10,
           y = pred %>% arcsignedlog10))+
  geom_point(size = 3, alpha  = .5)+
  geom_abline(intercept = 1, col = "red", size = 1, linetype = "dashed")+
  labs(title = "true vs pred of test_data",
       x = "salary_in_usd",
       y = "pred. of salary_in_usd")+
  scale_x_continuous(limits = c(test_min, test_max), labels = scales::comma)+
  scale_y_continuous(limits = c(test_min, test_max), labels = scales::comma)+
  theme.best

ggsave('./output/scatterplot_test_data.png',
       dpi = 200, width = 20, height = 20, units = c('cm'))

to.excel[["rmse"]] <- data.table(
  train = train_rmse,
  test = test_rmse
  )

to.excel[["ensemble model"]] <- ens_model$error
to.excel[["rf"]] <- ens_model$models$rf$results
to.excel[["cv_rf"]] <- ens_model$models$rf$resample
to.excel[["gbm"]] <- ens_model$models$gbm$results
to.excel[["cv_gbm"]] <- ens_model$models$gbm$resample
to.excel[["feature_importance"]] <- importance

write.xlsx(to.excel,
           "./output/model_details.xlsx",
           encoding = "UTF-8",
           rowNames = F)

cat("=====================================================================\n")

# 關閉文件輸出
sink()