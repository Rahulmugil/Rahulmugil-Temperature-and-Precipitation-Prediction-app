# Set working directory (if necessary)
# setwd("C:/Users/rahul/Downloads/project")

# Install necessary libraries if not already installed
if (!require(shiny)) install.packages('shiny', dependencies=TRUE)
if (!require(ggplot2)) install.packages('ggplot2', dependencies=TRUE)
if (!require(lubridate)) install.packages('lubridate', dependencies=TRUE)

library(shiny)
library(ggplot2)
library(lubridate)

# Load the temperature, precipitation, and multilinear models from the 'models' folder
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
  
  return(list(temperature = prediction[, 1], precipitation = prediction[, 2]))
}

# Define UI
ui <- fluidPage(
  titlePanel("Weather Prediction Dashboard"),
  sidebarLayout(
    sidebarPanel(
      dateInput("dateInput", 
                "Select a Date:", 
                value = Sys.Date(),
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
      plotOutput("tempPlot"),
      plotOutput("precipPlot")
    )
  )
)

# Define server logic
server <- function(input, output) {
  
  predictions <- reactive({
    req(input$predict)  # Ensure the action button is pressed
    
    selected_date <- input$dateInput
    prediction_type <- input$predictionType
    
    # Switch based on the selected prediction type
    if (prediction_type == "Temperature") {
      predicted_temp <- predict_temperature(selected_date)
      return(list(temperature = predicted_temp, precipitation = NULL))
      
    } else if (prediction_type == "Precipitation") {
      predicted_precip <- predict_precipitation(selected_date)
      return(list(temperature = NULL, precipitation = predicted_precip))
      
    } else if (prediction_type == "Both") {
      predicted_both <- predict_both(selected_date)
      return(list(temperature = predicted_both$temperature, precipitation = predicted_both$precipitation))
    }
  })
  
  output$predictionOutput <- renderPrint({
    req(predictions())
    pred <- predictions()
    
    if (!is.null(pred$temperature)) {
      cat("Predicted Temperature: ", round(pred$temperature, 2), "°C\n")
    }
    
    if (!is.null(pred$precipitation)) {
      cat("Predicted Precipitation: ", round(pred$precipitation, 2), "mm\n")
    }
  })
  
  output$tempPlot <- renderPlot({
    req(predictions())
    pred <- predictions()
    
    if (!is.null(pred$temperature)) {
      ggplot(data.frame(Date = input$dateInput, Temperature = pred$temperature), aes(x = Date, y = Temperature)) +
        geom_line(color = "blue") +
        geom_point(size = 3, color = "blue") +
        labs(title = "Predicted Temperature", x = "Date", y = "Temperature (°C)") +
        theme_minimal()
    }
  })
  
  output$precipPlot <- renderPlot({
    req(predictions())
    pred <- predictions()
    
    if (!is.null(pred$precipitation)) {
      ggplot(data.frame(Date = input$dateInput, Precipitation = pred$precipitation), aes(x = Date, y = Precipitation)) +
        geom_line(color = "green") +
        geom_point(size = 3, color = "green") +
        labs(title = "Predicted Precipitation", x = "Date", y = "Precipitation (mm)") +
        theme_minimal()
    }
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)
