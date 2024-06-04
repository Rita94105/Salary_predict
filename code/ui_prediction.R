library(shiny)
library(bslib)
library(bsicons)

prediction_ui <- function(){
  div(style='overflow-y: auto;',
      h3("Prediction"),
      br(),
        fluidRow(
          column(
            width = 12,
            card(
            card_header("Compare with Kaggle's prediction", class = "h6 text-primary"),
            HTML("<h5><b>Our accuracy is better than others!</b></h5>"),
            h6("1.",
               a("AIML salaries 2022-2024 AutoViz+CatBoost+SHAP", href = "https://www.kaggle.com/code/dima806/aiml-salaries-2022-2024-autoviz-catboost-shap", target = "_blank"),
              tags$ul(
                tags$li("RMSE score for train 51.4 kUSD/year, and for test 52.0 kUSD/year")
              ),
              "2.",
              a("Neural Network Regression Models", href = "https://www.kaggle.com/code/samuelmason23/neural-network-regression-models", target = "_blank"),
              tags$ul(
                 tags$li("test RMSE: 57857.07162184822")
                ))
            ))),
        fluidRow(
          column(
            width = 12,
            card(
              card_header("Improve methods", class = "h6 text-success"),
              h6("More data or features to optimize our model training to achieve results that most people can accept."),
            )
          )),
        fluidRow(
          column(
            width = 12,
            card(
              card_header("Conclusion", class = "h6 text-success"),
              h6("job_title is the most important feature, indicating that job titles play a crucial role in predicting salaries")
            )
        )),
        fluidRow(
          column(
            width = 6,
            card(
              card_header("Scatter plot: true vs pred in Training data"),
              img(src="scatterplot_train_data.png",style="height:100%;width:100%")
            )
          ),
          column(
            width = 6,
            card(
              card_header("Scatter plot: true vs pred in Testing data"),
              img(src="scatterplot_test_data.png", style="height:100%;width:100%"),
            )
          ),
        )
    )
}