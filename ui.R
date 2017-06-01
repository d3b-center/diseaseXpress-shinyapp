library(shiny)
library(shinydashboard)
library(shinyIncubator)
library(shinyBS)
library(elastic)
library(jsonlite)
library(data.table)
library(DT)
library(plotly)

dashboardPage(
  
  # dashboardHeader begins
  dashboardHeader(title = 'Disease EXpress TERminal (DEXTER)', titleWidth = 400), 
  # dashboardHeader ends
  
  # dashboardSidebar begins
  dashboardSidebar(width = 400,
                   
                   # enable vertical scrolling
                   div(style="overflow-y: scroll"),
                   
                   # sidebarMenu begin
                   sidebarMenu(
                     menuItem("Dashboard", icon = icon("dashboard"), tabName = "dashboard"),
                     menuItem("Get Data", icon = icon("database"), tabName = "gd"),
                     menuItem("Expression boxplot", icon = icon("bar-chart"), tabName = "boxplot"),
                     menuItem("Scatter plot", icon = icon("line-chart"), tabName = "dotplot"),
                     menuItem("Expression Barplot", icon = icon("bar-chart"), tabName = "barplot")
                     )
  ),
  # dashboardSidebar ends
  
  # dashboardBody begins
  dashboardBody(
    
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
    ),
    
    div(style="overflow-x: scroll"),
    
    # tabItems begins
    tabItems(
      
      tabItem(tabName = "dashboard",
              fluidRow(
                box(title = "Data Summary", status = "primary", width = 5, collapsed = F, collapsible = T, solidHeader = T, 
                  plotlyOutput(outputId = 'dashboardplot1', width = 300, height = 300)),
                box(title = "Description", status = "primary", width = 7, collapsed = F, collapsible = T, solidHeader = T,
                  includeText("data/intro.txt"))
              ),
              fluidRow(
                box(title = "Tumors", status = 'primary', width = 12, collapsed = T, collapsible = T, solidHeader = T,
                    plotlyOutput(outputId = "dashboardplot2", width = 965, height = 400))
              ),
              fluidRow(
                box(title = "Normals", status = "primary", width = 12, collapsed = T, collapsible = T, solidHeader = T,
                    plotlyOutput(outputId = "dashboardplot3", width = 965, height = 400))
              )
      ),
      
      # Get data page
      tabItem(tabName = "gd",
              fluidRow(
                box(selectInput(inputId = "gdselectInput0", label = "Gene Symbol", choices = "none", multiple = TRUE), width = 2, background = "navy"),
                bsTooltip(id = "gdselectInput0", title = "List of gene symbols", placement = "top", trigger = "focus", options = NULL),
                box(selectInput(inputId = "gdselectInput1", label = "Gene ID", choices = "none", multiple = TRUE), width = 3, background = "navy"),
                bsTooltip(id = "gdselectInput1", title = "List of Ensembl IDs for selected genes", placement = "top", trigger = "focus", options = NULL),
                box(selectInput(inputId = "gdselectInput2", label = "Study", choices = c("TARGET",
                                                                                         "GTEx",
                                                                                         "TCGA",
                                                                                         "PNOC"), multiple = TRUE), width = 2, background = "navy"),
                bsTooltip(id = "gdselectInput2", title = "Choose one or more studies", placement = "top", trigger = "focus", options = NULL),
                box(selectInput(inputId = "gdselectInput3", label = "Normalization", choices = c('',
                                                                                                 'RSEM: FPKM', 
                                                                                                 'RSEM: TPM', 
                                                                                                 'Kallisto: TPM'), selected = NULL), width = 2, background = 'navy'),
                bsTooltip(id = "gdselectInput3", title = "Normalization method to query", placement = "top", trigger = "focus", options = NULL),
                box(selectInput(inputId = "gdselectInput4", label = "Fields", choices = "none", multiple = TRUE), width = 2, background = "navy"),
                bsTooltip(id = "gdselectInput4", title = "Additional fields to return. Leave empty if you dont care.", placement = "top", trigger = "focus", options = NULL),
                box(checkboxGroupInput(inputId = "gdcheckboxInput1", label = "Annotation", choices = c("Sample Info",
                                                                                                       "Patient Info"), selected = FALSE), width = 2, background = "navy"),
                bsTooltip(id = "gdcheckboxInput1", title = "Additional info about the samples", placement = "right", trigger = "hover", options = NULL)
              ),
              fluidRow(
                box(actionButton(inputId = "gdsubmit1", label = " Query "), width = 2, background = "navy")
              ),
              fluidRow(
                DT::dataTableOutput(outputId = "gdtable1")
              )
      ),
      tabItem(tabName = "boxplot",
              fluidRow(
                box(selectInput(inputId = "boxplotselectInput0", label = "ID Type", choices = c('Hugo Symbol'='gene',
                                                                                                'Ensembl Gene ID'='ensg'), multiple = FALSE), width = 3, background = "orange"),
                box(selectInput(inputId = "boxplotselectInput1", label = "List", choices = "none", multiple = FALSE), width = 3, background = "orange"),
                box(selectInput(inputId = "boxplotselectInput2", label = "Study", choices = c("TARGET",
                                                                                              "PNOC",
                                                                                              "GTEx",
                                                                                              "TCGA")), width = 2, background = "orange"),
                box(selectInput(inputId = "boxplotselectInput3", label = "Disease", choices = "none", multiple = TRUE), width = 2, background = "orange"),
                box(selectInput(inputId = "boxplotselectInput4", label = "Colorby", choices = "none"), width = 2, background = "orange")
              ),
              fluidRow(
                box(actionButton(inputId = "boxplotsubmit1", label = "Plot"), width = 2, background = "orange")
              ),
              fluidRow(
                plotlyOutput(outputId = "boxplot1")  
              )
      )
    )
  ) # dashboardBody ends
) # dashboardPage ends