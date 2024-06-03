library(shiny)
library(bslib)
library(bsicons)

training_ui <- function(){
  div(style = 'overflow-y: auto; margin-left: 10px; margin-right: 10px;',
      fluidRow(
        column(
          width = 12,
          wellPanel(
            h3("Training"),
            br(),
            h6(
              "1. Using ",
              a("randomForest", href = "https://cran.r-project.org/web/packages/randomForest/index.html", target = "_blank"),
              " and gradient boosting (",
              a("gbm", href = "https://cran.r-project.org/web/packages/gbm/gbm.pdf", target = "_blank"),
              ") to build an ensemble learning model( through packages ",
              a("caret", href = "https://cran.r-project.org/web/packages/caret/vignettes/caret.html", target = "_blank"),
              "and ",
              a("caretEnsemble", href = "https://cran.r-project.org/web/packages/caretEnsemble/vignettes/caretEnsemble.pdf", target = "_blank"),
              ") to predict signedlog10(salary_in_usd)."),
            tags$ul(
              tags$li("caretList(): A convenience function for fitting multiple caret::train() models to the same dataset."),
              tags$li("caretStack(): Make linear or non-linear combinations of these models, with a caret::train() model as a meta-model, and caretEnsemble(), building a robust linear combination of models using a GLM.")
            ),
            h6("2. Use cross-validation (5-fold) and grid search to find the best hyperparameters"),
            h6("3. Use RMSE of salary_in_usd to evaluate the performance of model"),
            tags$ul(
              tags$li("Null Model: linear regression(only intercept)"),
              tags$li("Ensemble Model: random forest + gradient boosting")
            ),
            div(
              style = "overflow-x: auto;",
              uiOutput("training_tabs")
            ),
            br()
          )
        )
      )
  )
}