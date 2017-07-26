library(RDiseaseXpress)
library(shiny)
library(shinyjs)
library(shinydashboard)
library(shinyIncubator)
library(shinyBS)
library(data.table)
library(DT)
library(plotly)
library(RColorBrewer)
library(wesanderson)
library(reshape2)

dashboardPage(
  
  # dashboardHeader begins
  dashboardHeader(title = 'DiseaseXpress', titleWidth = 400), 
  # dashboardHeader ends
  
  # dashboardSidebar begins
  dashboardSidebar(width = 400,
                   
                   # enable vertical scrolling
                   div(style="overflow-y: scroll"),
                   
                   # sidebarMenu begin
                   sidebarMenu(
                     menuItem("Dashboard", icon = icon("dashboard"), tabName = "dashboard"),
                     menuItem("Get Data", icon = icon("database"), tabName = "gd"),
                     menuItem("Expression boxplot", icon = icon("bar-chart"), tabName = "boxplot",
                              menuSubItem(text = "Boxplot-study", tabName = "boxplot-1", icon = icon("bar-chart")),
                              menuSubItem(text = "Boxplot-disease", tabName = "boxplot-2", icon = icon("bar-chart"))),
                     menuItem("Scatter plot", icon = icon("line-chart"), tabName = "dotplot",
                              menuSubItem(text = "Scatter-study", tabName = "scatter-1", icon = icon("line-chart")),
                              menuSubItem(text = "Scatter-disease", tabName = "scatter-2", icon = icon("line-chart"))),
                     menuItem("Tools", icon = icon("gears"), tabName = "tools",
                              menuSubItem(text = "Most correlated genes", tabName = "corrgenes", icon = icon("database")))
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
                  plotlyOutput(outputId = 'dashboardplot1', width = "auto", height = 300)),
                box(title = "Description", status = "primary", width = 7, collapsed = F, collapsible = T, solidHeader = T,
                  includeText("data/intro.txt"))
              ),
              fluidRow(
                box(title = "Tumors", status = 'primary', width = 12, collapsed = T, collapsible = T, solidHeader = T,
                    plotlyOutput(outputId = "dashboardplot2", width = "auto", height = "auto"))
              ),
              fluidRow(
                box(title = "GTEx Normals", status = "primary", width = 12, collapsed = T, collapsible = T, solidHeader = T,
                    plotlyOutput(outputId = "dashboardplot3", width = "auto", height = "auto"))
              )
      ),
      
      # Get data page
      tabItem(tabName = "gd",
              fluidRow(
                box(selectInput(inputId = "gdselectInput0", label = "Gene Symbol", choices = "none", multiple = TRUE), width = 2, background = "navy"),
                bsTooltip(id = "gdselectInput0", title = "List of gene symbols", placement = "top", trigger = "hover", options = NULL),
                box(selectInput(inputId = "gdselectInput1", label = "Study", choices = "none", multiple = TRUE), width = 2, background = "navy"),
                bsTooltip(id = "gdselectInput1", title = "Choose one or more studies", placement = "top", trigger = "hover", options = NULL),
                box(selectInput(inputId = "gdselectInput3", label = "Normalization", choices = c('RSEM: FPKM'='rsem', 
                                                                                                 'RSEM: TPM'='sample_rsem_isoform', 
                                                                                                 'Kallisto: TPM'='sample_abundance'), selected = NULL), width = 3, background = 'navy'),
                bsTooltip(id = "gdselectInput3", title = "Normalization method to query", placement = "top", trigger = "hover", options = NULL)              
              ),
              fluidRow(
                box(actionButton(inputId = "gdsubmit1", label = "Query", width = '100%'), width = 2, background = "navy"),
                bsTooltip(id = "gdsubmit1", title = "Query disease express", placement = "bottom", trigger = "hover", options = NULL)
              ),
              fluidRow(
                DT::dataTableOutput(outputId = "gdtable1")
              ),
              fluidRow(
                column(2, div(style = "height:50px"), downloadButton('download','Download Data')),
                bsTooltip(id = "download", title = "First Query then Download!", placement = "top", trigger = "hover", options = NULL)
              )
      ),
      
      tabItem(tabName = "boxplot-1",
              fluidRow(
                box(selectInput(inputId = "boxplot1selectInput0", label = "Gene Symbol", choices = "none"),
                    bsTooltip(id = "boxplot1selectInput0", title = "Select one gene", placement = "top", trigger = "hover", options = NULL), width = 2, background = "navy"),
                box(selectInput(inputId = "boxplot1selectInput1", label = "Study", choices = "none", multiple = TRUE), 
                    bsTooltip(id = "boxplot1selectInput1", title = "Select one or more studies", placement = "top", trigger = "hover", options = NULL), width = 2, background = "navy"),
                box(selectInput(inputId = "boxplot1selectInput2", label = "Normalization", choices = c('RSEM FPKM' = 'rsem')),
                    bsTooltip(id = "boxplot1selectInput2", title = "Select one Normalization", placement = "top", trigger = "hover", options = NULL), width = 3, background = "navy"),
                box(selectInput(inputId = "boxplot1selectInput3", label = "Tumor Subset", choices = c('Primary','Recurrent','All')), 
                    bsTooltip(id = "boxplot1selectInput3", title = "Select tumor type", placement = "top", trigger = "hover", options = NULL), width = 2, background = "navy"),
                box(checkboxInput(inputId = "boxplot1checkboxInput0", label = "Log", value = FALSE), 
                    bsTooltip(id = "boxplot1checkboxInput0", title = "Convert to log2", placement = "top", trigger = "hover", options = NULL), width = 2, background = "navy")              
              ),
              fluidRow(
                box(actionButton(inputId = "boxplot1submit1", label = "Get Boxplot", width = "100%"), 
                    bsTooltip(id = "boxplot1submit1", title = "Click to create boxplot", placement = "bottom", trigger = "hover", options = NULL), width = 2, background = "navy")
              ),
              br(), br(),
              plotlyOutput(outputId = "boxplot1plot1", width = "auto", height = "auto")
      ),
      
      tabItem(tabName = "boxplot-2",
              fluidRow(
                box(selectInput(inputId = "boxplot2selectInput0", label = "Gene Symbol", choices = "none"),
                    bsTooltip(id = "boxplot2selectInput0", title = "Select one gene", placement = "top", trigger = "hover", options = NULL), width = 2, background = "navy"),
                box(selectInput(inputId = "boxplot2selectInput1", label = "Study", choices = "none", multiple = TRUE), 
                    bsTooltip(id = "boxplot2selectInput1", title = "Select one or more studies", placement = "top", trigger = "hover", options = NULL), width = 2, background = "navy"),
                box(selectInput(inputId = "boxplot2selectInput2", label = "Normalization", choices = c('RSEM FPKM' = 'rsem')), 
                    bsTooltip(id = "boxplot2selectInput2", title = "Select one normalization", placement = "top", trigger = "hover", options = NULL), width = 3, background = "navy"),
                box(selectInput(inputId = "boxplot2selectInput3", label = "Tumor Subset", choices = c('Primary','Recurrent','All')), 
                    bsTooltip(id = "boxplot2selectInput3", title = "Select tumor type", placement = "top", trigger = "hover", options = NULL), width = 2, background = "navy"),
                box(checkboxInput(inputId = "boxplot2checkboxInput0", label = "Log", value = FALSE), 
                    bsTooltip(id = "boxplot2checkboxInput0", title = "Convert to log2", placement = "top", trigger = "hover", options = NULL), width = 2, background = "navy")
              ),
              fluidRow(
                box(selectInput(inputId = "boxplot2selectInput4", label = "Collapse study", choices = "none"), 
                    bsTooltip(id = "boxplot2selectInput4", title = "collapse a study to one box", placement = "top", trigger = "hover", options = NULL), width = 2, background = "navy"),
                box(selectInput(inputId = "boxplot2selectInput5", label = "Reference", choices = "none"), 
                    bsTooltip(id = "boxplot2selectInput5", title = "select which box appears first", placement = "top", trigger = "hover", options = NULL), width = 2, background = "navy")
              ),
              fluidRow(
                box(actionButton(inputId = "boxplot2submit1", label = "Get Boxplot", width = "100%"), 
                    bsTooltip(id = "boxplot2submit1", title = "Click to create boxplot", placement = "bottom", trigger = "hover", options = NULL), width = 2, background = "navy")
              ),
              br(), br(),
              plotlyOutput(outputId = "boxplot2plot1", width = "auto", height = "auto")
      ),
      
      tabItem(tabName = "scatter-1",
              fluidRow(
                box(selectInput(inputId = "dotplotselectInput0", label = "Gene 1", choices = "none"), 
                    bsTooltip(id = "dotplotselectInput0", title = "Select one gene", placement = "top", trigger = "hover", options = NULL), width = 2, background = "navy"),
                box(selectInput(inputId = "dotplotselectInput1", label = "Gene 2", choices = "none"), 
                    bsTooltip(id = "dotplotselectInput1", title = "Select one gene", placement = "top", trigger = "hover", options = NULL), width = 2, background = "navy"),
                box(selectInput(inputId = "dotplotselectInput2", label = "Study", choices = "none", multiple = TRUE), 
                    bsTooltip(id = "dotplotselectInput2", title = "Select one or more studies", placement = "top", trigger = "hover", options = NULL), width = 2, background = "navy"),
                box(selectInput(inputId = "dotplotselectInput3", label = "Normalization", choices = c('RSEM FPKM' = 'rsem')), 
                    bsTooltip(id = "dotplotselectInput3", title = "Select one normalization", placement = "top", trigger = "hover", options = NULL), width = 2, background = "navy"),
                box(selectInput(inputId = "dotplotselectInput4", label = "Tumor Subset", choices = c('Primary','Recurrent','All')), 
                    bsTooltip(id = "dotplotselectInput4", title = "Select tumor type", placement = "top", trigger = "hover", options = NULL), width = 2, background = "navy")
              ),
              fluidRow(
                box(checkboxInput(inputId = "dotplotcheckboxInput0", label = "Log", value = FALSE), 
                    bsTooltip(id = "dotplotcheckboxInput0", title = "Convert to log2", placement = "top", trigger = "hover", options = NULL), width = 2, background = "navy"),
                box(selectInput(inputId = "dotplotselectInput5", label = "Colorby", choices = c('Study'='study','Tumor Subset'='definition','Disease/Tissue'='disease')), 
                    bsTooltip(id = "dotplotselectInput5", title = "Color the points?", placement = "top", trigger = "hover", options = NULL), width = 2, background = "navy"),
                box(selectInput(inputId = "dotplotselectInput6", label = "Correlation", choices = c('pearson','spearman')), 
                    bsTooltip(id = "dotplotselectInput6", title = "Select correlation method", placement = "top", trigger = "hover", options = NULL), width = 2, background = "navy")
              ),
              fluidRow(
                box(actionButton(inputId = "dotplotsubmit1", label = "Get dotplot", width = "100%"), 
                    bsTooltip(id = "dotplotsubmit1", title = "Create correlation plot", placement = "bottom", trigger = "hover", options = NULL), width = 2, background = "navy")
              ),
              br(), br(),
              plotlyOutput(outputId = "dotplotplot1", width = "auto", height = "auto"),
              DT::dataTableOutput(outputId = "dotplottable1")
      ),
      
      tabItem(tabName = "scatter-2",
              fluidRow(
                box(selectInput(inputId = "scatter2selectInput0", label = "Gene 1", choices = "none"), 
                    bsTooltip(id = "scatter2selectInput0", title = "Select one gene", placement = "top", trigger = "hover", options = NULL), width = 2, background = "navy"),
                box(selectInput(inputId = "scatter2selectInput1", label = "Gene 2", choices = "none"), 
                    bsTooltip(id = "scatter2selectInput1", title = "Select one gene", placement = "top", trigger = "hover", options = NULL), width = 2, background = "navy"),
                box(selectInput(inputId = "scatter2selectInput2", label = "Study", choices = "none", multiple = TRUE), 
                    bsTooltip(id = "scatter2selectInput2", title = "Select one or more studies", placement = "top", trigger = "hover", options = NULL), width = 2, background = "navy"),
                box(selectInput(inputId = "scatter2selectInput3", label = "Disease/Tissue", choices = "none", multiple = TRUE), 
                    bsTooltip(id = "scatter2selectInput3", title = "Select one or more diseases/tissues", placement = "top", trigger = "hover", options = NULL), width = 2, background = "navy"),
                box(selectInput(inputId = "scatter2selectInput4", label = "Normalization", choices = c('RSEM FPKM' = 'rsem')), 
                    bsTooltip(id = "scatter2selectInput4", title = "Select normalization", placement = "top", trigger = "hover", options = NULL), width = 2, background = "navy"),
                box(selectInput(inputId = "scatter2selectInput5", label = "Tumor Subset", choices = c('Primary','Recurrent','All')), 
                    bsTooltip(id = "scatter2selectInput5", title = "Select tumor type", placement = "top", trigger = "hover", options = NULL), width = 2, background = "navy")
              ),
              fluidRow(
                box(checkboxInput(inputId = "scatter2checkboxInput0", label = "Log", value = FALSE), 
                    bsTooltip(id = "scatter2checkboxInput0", title = "Convert to log2", placement = "top", trigger = "hover", options = NULL), width = 2, background = "navy"),
                box(selectInput(inputId = "scatter2selectInput6", label = "Colorby", choices = c('Study'='study','Tumor Subset'='definition','Disease/Tissue'='disease')), 
                    bsTooltip(id = "scatter2selectInput6", title = "Color the points?", placement = "top", trigger = "hover", options = NULL), width = 2, background = "navy"),
                box(selectInput(inputId = "scatter2selectInput7", label = "Correlation", choices = c('pearson','spearman')), 
                    bsTooltip(id = "scatter2selectInput7", title = "Select correlation method", placement = "top", trigger = "hover", options = NULL), width = 2, background = "navy")
              ),
              fluidRow(
                box(actionButton(inputId = "scatter2submit1", label = "Get dotplot", width = "100%"), 
                    bsTooltip(id = "scatter2submit1", title = "Select correlation method", placement = "bottom", trigger = "hover", options = NULL), width = 2, background = "navy")
              ),
              br(), br(),
              plotlyOutput(outputId = "scatter2plot1", width = "auto", height = "auto"),
              DT::dataTableOutput(outputId = "scatter2table1")
      ),
      
      tabItem(tabName = "corrgenes",
              fluidRow(
                box(selectInput(inputId = "corrgenesselectInput0", label = "Study", choices = "none"), 
                    bsTooltip(id = "corrgenesselectInput0", title = "Select one study", placement = "top", trigger = "hover", options = NULL), width = 2, background = "navy"),
                box(selectInput(inputId = "corrgenesselectInput1", label = "Disease/Tissue", choices = "none"), 
                    bsTooltip(id = "corrgenesselectInput1", title = "Select one disease/tissue", placement = "top", trigger = "hover", options = NULL), width = 2, background = "navy"),
                box(selectInput(inputId = "corrgenesselectInput2", label = "Tumor Subset", choices = c('Primary','Recurrent','All')), 
                    bsTooltip(id = "corrgenesselectInput2", title = "Select tumor type", placement = "top", trigger = "hover", options = NULL), width = 2, background = "navy"),
                box(selectInput(inputId = "corrgenesselectInput3", label = "Gene", choices = "none"), 
                    bsTooltip(id = "corrgenesselectInput3", title = "Select Gene", placement = "top", trigger = "hover", options = NULL), width = 2, background = "navy"),
                box(selectInput(inputId = "corrgenesselectInput4", label = "Normalization", choices = c('RSEM FPKM' = 'rsem')), 
                    bsTooltip(id = "corrgenesselectInput4", title = "Select normalization", placement = "top", trigger = "hover", options = NULL), width = 2, background = "navy"),
                box(textInput(inputId = "corrgenestextInput1", label = "Number", value = "10"), 
                    bsTooltip(id = "corrgenestextInput1", title = "Number of correlations", placement = "top", trigger = "hover", options = NULL), width = 2, background = "navy")
              ), 
              br(), br(),
              DT::dataTableOutput(outputId = "toolstable1")
      )
    )
  ) # dashboardBody ends
) # dashboardPage ends