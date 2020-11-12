## Loading Crime Data published by Statistics Canada at https://open.canada.ca/data/en/dataset/b068d330-4d34-49dc-8efb-017dfb45edcf

url <- "https://www150.statcan.gc.ca/n1/tbl/csv/35100131-eng.zip"
download.file(url, "CanadaCrimeDataset.zip")
CrimeData <- read.csv(unz("CanadaCrimeDataset.zip", "35100131.csv"))

## sub_CrimeData is a subset of the most relevant columns in the main dataset

sub_CrimeData <- CrimeData[,c(1,2,4,11)]

## Pulling out drop-down list options from the dataset

GeoListOptions <- unique(sub_CrimeData$GEO)
CrimeTypeOptions <- unique(sub_CrimeData$Type.of.offence)

## Loading libraries

library(shiny)
library("ggplot2")

## UI logic goes here..

ui <- fluidPage(

    # Application title
    titlePanel("Canada Crime Data (1960 - 2000)"),
    
    sidebarLayout(
        sidebarPanel(
            selectInput("Geo",
                        "Select province:",
                        GeoListOptions),
            selectInput("CrimeType", "Select type of offense:", CrimeTypeOptions)
        ),
        
        # Show a plot of the generated distribution
        mainPanel(
            plotOutput("Plot")
        )
    )
)

# Server logic goes here..
server <- function(input, output) {

    PlotData <- reactive({
        sub_CrimeData[sub_CrimeData$GEO == input$Geo & sub_CrimeData$Type.of.offence == input$CrimeType,]
        })
    
    output$Plot <- renderPlot({
        g <- ggplot(PlotData(), aes(REF_DATE, VALUE)) + labs(y = "Crime Count", x = "Year") + geom_point()
        g <- g + xlim(1960, 2000) 
        ## Adding a smoother to determine linear trend in the data
        g <- g + geom_smooth()
        g
        })
}

# Run the application 
shinyApp(ui = ui, server = server)
