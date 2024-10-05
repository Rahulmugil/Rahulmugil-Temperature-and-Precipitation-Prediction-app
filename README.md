
# Temperature and Precipitation Prediction Shiny App

This project is a Temperature and Precipitation prediction app built using R and Shiny. It predicts temperature and precipitation based on historical weather data from Kolkata.

## Features
- Predicts **temperature** and **precipitation** for a given date.
- Uses machine learning models trained on historical data.
- Graphical visualization of predictions.

## Models Used
The following pre-trained models are stored as `.rds` files and used by the app:
1. **models/temp_model.rds**: Predicts daily average temperature.
2. **models/precip_model.rds**: Predicts daily precipitation.
3. **models/multi_model.rds**: Predicts both temperature and precipitation simultaneously.

## Prerequisites
1. **R** and **RStudio** (or another R environment).
2. Install the required R packages:
   ```r
   install.packages(c('shiny', 'ggplot2', 'lubridate', 'caret', 'zoo'))
   ```

## How to Run the App
1. **Clone the repository**:
   ```bash
   git clone https://github.com/Rahulmugil/Temperature-and-Precipitation-Prediction-app.git
   ```

2. **Navigate to the project folder**:
   ```bash
   cd Temperature-and-Precipitation-Prediction-app
   ```

3. **Run the Shiny app**:
   In RStudio or another R console, open and run the `app.R` file:
   ```r
   shiny::runApp('app.R')
   ```

## Folder Structure
- `app.R`: The main script that runs the Shiny app.
- `models/`: Contains the pre-trained models as `.rds` files.
- `data/`: Contains the dataset (`kolkata_data.csv`).
- `README.md`: Project documentation.

