library(smotefamily)

process_outliers <- function(data, columns) {
  for (col in columns) {
    Q1 <- quantile(data[[col]], 0.25, na.rm = TRUE)
    Q3 <- quantile(data[[col]], 0.75, na.rm = TRUE)
    IQR <- Q3 - Q1
    lower_bound <- Q1 - 1.5 * IQR
    upper_bound <- Q3 + 1.5 * IQR
    
    median_val <- median(data[[col]], na.rm = TRUE)
    
    print(paste("---", col))
    print(paste("lower bound:",lower_bound))
    print(paste("upper bound:", upper_bound))
    print(paste("median", median_val))
    outliers <- data[[col]][data[[col]] < lower_bound | data[[col]] > upper_bound]
    print(paste("outliers count:", length(outliers)))
    
    data[[col]][data[[col]] < lower_bound] <- median_val
    data[[col]][data[[col]] > upper_bound] <- median_val
    
    outliers_after <- data[[col]][data[[col]] < lower_bound | data[[col]] > upper_bound]
    print(paste("outliers_after count:", length(outliers_after)))
    
  }
  return(data)
}

process_missing_values <- function(data, columns) {
  for (col in columns) {
    mean_value <- mean(data[[col]], na.rm = TRUE)
    data[[col]][is.na(data[[col]])] <- mean_value
  }
  return(data)
}

do_smote <- function(train_data, target_name) {
  target_index <- which(colnames(train_data) == target_name)
  print(paste("target_index", target_index))
  features <- train_data[, -target_index]
  target <- train_data[[target_name]]
  
  oversampled_result <- SMOTE(features, target, K = 5, dup_size = 0)
  oversampled_data <- oversampled_result[[1]]
  names(oversampled_data)[names(oversampled_data) == 'class'] <- target_name
  
  class_distribution <- table(oversampled_data$SeriousDlqin2yrs)
  print(class_distribution)
  return(oversampled_data)
}

ordinal_encoding <- function(data, old_col, new_col, order) {
  data[[new_col]] <- factor(data[[old_col]], levels = order, ordered = TRUE)
  data[[new_col]] <- as.numeric(data[[new_col]])
  return(data)
}

target_encoding <- function(data, col, target) {
  target_encode_tmp <- build_target_encoding(data, cols_to_encode = col,
                                           target_col = target, functions = c("mean"))
  encode_result <- target_encode(data, target_encoding = target_encode_tmp)
  return(encode_result[[length(encode_result)]])
}

do_one_hot_encoding <- function(data, col_name) {
  category_name <- col_name
  formula_str <- paste("~", category_name, "- 1")
  formula_obj <- as.formula(formula_str)
  encoded_df <- model.matrix(formula_obj, data = data)
  colnames(encoded_df) <- make.names(colnames(encoded_df))
  
  combined_data <- cbind(data, encoded_df)
  return(combined_data)
}

do_kmeans <- function(data, cluster_count) {
  k <- cluster_count
  kmeans_result <- kmeans(data$salary_in_usd, centers = k)
  return(as.factor(kmeans_result$cluster))
}