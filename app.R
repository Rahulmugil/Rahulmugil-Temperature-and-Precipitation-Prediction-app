# Install necessary libraries if not already installed
if (!require(shiny)) install.packages('shiny', dependencies=TRUE)
if (!require(ggplot2)) install.packages('ggplot2', dependencies=TRUE)
if (!require(lubridate)) install.packages('lubridate', dependencies=TRUE)
if (!require(plotly)) install.packages('plotly', dependencies=TRUE)

library(shiny)
library(ggplot2)
library(lubridate)
library(plotly)

# Load the temperature, precipitation, and multilinear models
temp_model <- readRDS("models/temp_model.rds")
precip_model <- readRDS("models/precip_model.rds")
multi_model <- readRDS("models/multi_model.rds")

# Function to predict temperature
predict_temperature <- function(date) {
  year <- as.numeric(format(date, "%Y"))
  month <- as.numeric(format(date, "%m"))
  day_of_year <- as.numeric(format(date, "%j"))
  
  new_data <- data.frame(Year = year, Month = month, DayOfYear = day_of_year)
  predicted_temp <- predict(temp_model, new_data)
  
  return(predicted_temp)
}

# Function to predict precipitation
predict_precipitation <- function(date) {
  year <- as.numeric(format(date, "%Y"))
  month <- as.numeric(format(date, "%m"))
  day_of_year <- as.numeric(format(date, "%j"))
  
  new_data <- data.frame(Year = year, Month = month, DayOfYear = day_of_year)
  predicted_precip <- predict(precip_model, new_data)
  
  return(predicted_precip)
}

# Function to predict both temperature and precipitation (multilinear model)
predict_both <- function(date) {
  year <- as.numeric(format(date, "%Y"))
  month <- as.numeric(format(date, "%m"))
  day_of_year <- as.numeric(format(date, "%j"))
  
  new_data <- data.frame(Year = year, Month = month, DayOfYear = day_of_year)
  prediction <- predict(multi_model, new_data)
  
  return(list(temperature = prediction[1], precipitation = prediction[2]))
}

# Define UI
ui <- fluidPage(
  titlePanel("Temperature and Precipitation Prediction Dashboard"),
  sidebarLayout(
    sidebarPanel(
      dateRangeInput("dateRange", 
                     "Select Date Range:", 
                     start = Sys.Date() - 30, 
                     end = Sys.Date(),
                     min = as.Date("2000-01-01"),
                     max = as.Date("2030-12-31")),
      selectInput("predictionType", 
                  "Select Prediction Type:", 
                  choices = c("Temperature", "Precipitation", "Both")),
      actionButton("predict", "Predict")
    ),
    mainPanel(
      h3("Prediction Results"),
      verbatimTextOutput("predictionOutput"),
      plotlyOutput("tempPlot"),
      plotlyOutput("precipPlot")
    )
  )
)

# Define server logic
server <- function(input, output) {
  
  predictions <- reactive({
    req(input$predict)  # Ensure the action button is pressed
    
    selected_dates <- seq(input$dateRange[1], input$dateRange[2], by = "day")
    prediction_type <- input$predictionType
    
    # Initialize empty lists for storing predictions
    temp_preds <- numeric(length(selected_dates))
    precip_preds <- numeric(length(selected_dates))
    
    for (i in seq_along(selected_dates)) {
      date <- selected_dates[i]
      
      # Switch based on the selected prediction type
      if (prediction_type == "Temperature") {
        temp_preds[i] <- predict_temperature(date)
        
      } else if (prediction_type == "Precipitation") {
        precip_preds[i] <- predict_precipitation(date)
        
      } else if (prediction_type == "Both") {
        both_preds <- predict_both(date)
        temp_preds[i] <- both_preds$temperature
        precip_preds[i] <- both_preds$precipitation
      }
    }
    
    return(list(dates = selected_dates, temperature = temp_preds, precipitation = precip_preds))
  })
  
  output$predictionOutput <- renderPrint({
    req(predictions())
    pred <- predictions()
    
    if (input$predictionType == "Temperature" || input$predictionType == "Both") {
      cat("Temperature Predictions:\n")
      print(data.frame(Date = pred$dates, Temperature = round(pred$temperature, 2)))
    }
    
    if (input$predictionType == "Precipitation" || input$predictionType == "Both") {
      cat("Precipitation Predictions:\n")
      print(data.frame(Date = pred$dates, Precipitation = round(pred$precipitation, 2)))
    }
  })
  
  output$tempPlot <- renderPlotly({
    req(predictions())
    pred <- predictions()
    
    if (input$predictionType == "Temperature" || input$predictionType == "Both") {
      temp_data <- data.frame(Date = pred$dates, Temperature = pred$temperature)
      
      p <- ggplot(temp_data, aes(x = Date, y = Temperature)) +
        geom_line(color = "blue") +
        geom_point(size = 3, color = "blue") +
        labs(title = "Predicted Temperature Over Time", x = "Date", y = "Temperature (°C)") +
        theme_minimal()
      
      ggplotly(p)
    }
  })
  
  output$precipPlot <- renderPlotly({
    req(predictions())
    pred <- predictions()
    
    if (input$predictionType == "Precipitation" || input$predictionType == "Both") {
      precip_data <- data.frame(Date = pred$dates, Precipitation = pred$precipitation)
      
      p <- ggplot(precip_data, aes(x = Date, y = Precipitation)) +
        geom_line(color = "green") +
        geom_point(size = 3, color = "green") +
        labs(title = "Predicted Precipitation Over Time", x = "Date", y = "Precipitation (mm)") +
        theme_minimal()
      
      ggplotly(p)
    }
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)

