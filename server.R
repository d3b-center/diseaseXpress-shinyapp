# source functions
source('R/viewDataTable.R')
source('R/loaddata.R')
source('R/getBoxplotByStudy.R')
source('R/getBoxplotByDisease.R')
source('R/themes.R')
source('R/getCorr.R')
source('R/getScatterByStudy.R')
source('R/getScatterByDisease.R')

m <- list(
  b = 100,
  r = 50,
  pad = 4
)

# sample.info <- getSamples()
# sample.info <- as.data.frame(sample.info)
# sample.info$group <- ifelse(sample.info$study_id == "GTEx", "Normals", "Tumors")
# sample.info$disease <- ifelse(is.na(sample.info$disease), sample.info$tissue, sample.info$disease)

shinyServer(function(input, output, session){
  
  # update gene symbols
  observe({
    updateSelectizeInput(session = session, inputId = "gdselectInput0", choices = getGeneSymbols(), server = TRUE)
    updateSelectizeInput(session = session, inputId = "boxplot1selectInput0", choices = getGeneSymbols(), server = TRUE)
    updateSelectizeInput(session = session, inputId = "boxplot2selectInput0", choices = getGeneSymbols(), server = TRUE)
    updateSelectizeInput(session = session, inputId = "dotplotselectInput0", choices = getGeneSymbols(), server = TRUE)
    updateSelectizeInput(session = session, inputId = "dotplotselectInput1", choices = getGeneSymbols(), server = TRUE)
    updateSelectizeInput(session = session, inputId = "scatter2selectInput0", choices = getGeneSymbols(), server = TRUE)
    updateSelectizeInput(session = session, inputId = "scatter2selectInput1", choices = getGeneSymbols(), server = TRUE)
    updateSelectizeInput(session = session, inputId = "corrgenesselectInput3", choices = getGeneSymbols(), server = TRUE)
  })
  
  # update studies
  observe({
    updateSelectizeInput(session = session, inputId = "gdselectInput1", choices = getStudies(), server = TRUE)
    updateSelectizeInput(session = session, inputId = "boxplot1selectInput1", choices = getStudies(), server = TRUE)
    updateSelectizeInput(session = session, inputId = "boxplot2selectInput1", choices = getStudies(), server = TRUE)
    updateSelectizeInput(session = session, inputId = "dotplotselectInput2", choices = getStudies(), server = TRUE)
    updateSelectizeInput(session = session, inputId = "scatter2selectInput2", choices = getStudies(), server = TRUE)
    updateSelectizeInput(session = session, inputId = "corrgenesselectInput0", choices = getStudies(), server = TRUE)
  })
  
  # update collapse studies
  observe({
    studies <- c('none', as.character(input$boxplot2selectInput1))
    updateSelectizeInput(session = session, inputId = "boxplot2selectInput4", choices = studies, server = TRUE)
  })
  
  # update reference
  observe({
    studies <- c('none', as.character(input$boxplot2selectInput1))
    if(input$boxplot2selectInput4 == "none"){
      disease.sub <- unique(sample.info[which(sample.info$study_id %in% studies),'disease'])
      disease.sub <- c('none', disease.sub)
      updateSelectizeInput(session = session, inputId = "boxplot2selectInput5", choices = disease.sub, server = TRUE)
    } else {
      studies.collapsed <- as.character(input$boxplot2selectInput4) 
      studies <- setdiff(studies, studies.collapsed)
      disease.sub <- unique(sample.info[which(sample.info$study_id %in% studies),'disease'])
      disease.sub <- c('none', disease.sub, studies.collapsed)
      updateSelectizeInput(session = session, inputId = "boxplot2selectInput5", choices = disease.sub, server = TRUE)
    }
  })
  
  # update disease
  observe({
    studies <- input$scatter2selectInput2
    disease.sub <- unique(sample.info[which(sample.info$study_id %in% studies),'disease'])
    updateSelectizeInput(session = session, inputId = "scatter2selectInput3", choices = disease.sub, server = TRUE)
  })
  
  observe({
    studies <- input$corrgenesselectInput0
    disease.sub <- unique(sample.info[which(sample.info$study_id %in% studies),'disease'])
    updateSelectizeInput(session = session, inputId = "corrgenesselectInput1", choices = disease.sub, server = TRUE)
  })
  
  # update datatable with query gdtable1
  output$gdtable1 <- DT::renderDataTable({
    if(input$gdsubmit1 == 0){
      return()
    }
    withProgress(session = session, message = "Getting data...", detail = "Takes a while...",{
      isolate({
        genes <- as.character(input$gdselectInput0)
        study <- as.character(input$gdselectInput1)
        norm <- as.character(input$gdselectInput3)
        dat <<- getDataAnnotationByGeneSymbol(myGeneSymbols = genes, myStudy = study, myNorms = norm)
        viewDataTable(dat = dat)
      })
    })
  })
  
  output$download <- downloadHandler(
    'disease_express.csv', 
    content = function(file) {
      write.csv(dat, file)
  })
  
  # boxplot by study
  output$boxplot1plot1 <- renderPlotly({
    if(input$boxplot1submit1 == 0){
      return()
    }
    withProgress(session = session, message = "Creating plot...", detail = "Takes a while...",{
      isolate({
        genes <- input$boxplot1selectInput0
        studies <- input$boxplot1selectInput1
        norm <- input$boxplot1selectInput2
        subset <- input$boxplot1selectInput3
        log <- input$boxplot1checkboxInput0
        getBoxplotByStudy(genes = genes, studies = studies, norm = norm, log = log, subset = subset)
      })
    })
  })
  
  # boxplot by disease
  output$boxplot2plot1 <- renderPlotly({
    if(input$boxplot2submit1 == 0){
      return()
    }
    withProgress(session = session, message = "Creating plot...", detail = "Takes a while...",{
      isolate({
        genes <- input$boxplot2selectInput0
        studies <- input$boxplot2selectInput1
        norm <- input$boxplot2selectInput2
        subset <- input$boxplot2selectInput3
        log <- input$boxplot2checkboxInput0
        collapse <- input$boxplot2selectInput4
        ref <- input$boxplot2selectInput5
        getBoxplotByDisease(genes = genes, studies = studies, norm = norm, log = log, subset = subset, collapse = collapse, ref = ref)
      })
    })
  })
  
  # scatterplot by study
  output$dotplotplot1 <- renderPlotly({
    if(input$dotplotsubmit1 == 0){
      return()
    }
    withProgress(session = session, message = "Creating plot...", detail = "Takes a while...",{
      isolate({
        gene1 <- input$dotplotselectInput0
        gene2 <- input$dotplotselectInput1
        studies <- input$dotplotselectInput2
        norm <- input$dotplotselectInput3
        subset <- input$dotplotselectInput4
        colorby <- input$dotplotselectInput5
        correlation <- input$dotplotselectInput6
        log <- input$dotplotcheckboxInput0
        dotp <<- getScatterByStudy(gene1 = gene1, gene2 = gene2, studies = studies, norm = norm, log = log, 
                          subset = subset, colorby = colorby, correlation = correlation)
        dotp[[1]]
      })
    })
  })
  
  output$dotplottable1 <- renderDataTable({
    if(input$dotplotsubmit1 == 0){
      return()
    }
    isolate({
      cor.table <- dotp[[2]]
      viewDataTable(dat = cor.table)
    })
  })
  
  # scatterplot by disease
  output$scatter2plot1 <- renderPlotly({
    if(input$scatter2submit1 == 0){
      return()
    }
    withProgress(session = session, message = "Creating plot...", detail = "Takes a while...",{
      isolate({
        gene1 <- input$scatter2selectInput0
        gene2 <- input$scatter2selectInput1
        studies <- input$scatter2selectInput2
        disease <- input$scatter2selectInput3
        norm <- input$scatter2selectInput4
        subset <- input$scatter2selectInput5
        colorby <- input$scatter2selectInput6
        correlation <- input$scatter2selectInput7
        log <- input$scatter2checkboxInput0
        dotpp <<- getScatterByDisease(gene1 = gene1, gene2 = gene2, studies = studies, disease = disease, norm = norm, log = log,
                                   subset = subset, colorby = colorby, correlation = correlation)
        dotpp[[1]]
      })
    })
  })
  
  output$scatter2table1 <- renderDataTable({
    if(input$scatter2submit1 == 0){
      return()
    }
    isolate({
      cor.table <- dotpp[[2]]
      viewDataTable(dat = cor.table)
    })
  })
  
  ######### dashboard items ############
  output$dashboardplot1 <- renderPlotly({
    isolate({
      # pie1 <- plyr::count(sample.info$study)
      pie1 <- plyr::count(sample.info$study_id)
      p <- plot_ly(pie1, labels = ~x, values = ~freq, type = 'pie', showlegend = FALSE) %>%
        layout(title = 'Disease-Express Studies', font = list(color = 'black'),
               xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
               yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE)) %>%
        config(displayModeBar = F)
      p
    })
  })
  
  output$dashboardplot2 <- renderPlotly({
    tumors <- plyr::count(sample.info[which(sample.info$group == 'Tumors'),c('study_id','disease')])
    tumors$disease <- reorder(tumors$disease, tumors$freq)
    p <- plot_ly(tumors, x = ~disease, y=~freq, color=~study_id, split = ~study_id, type= 'bar') %>%
      layout(title = "", margin = m, font = list(color = 'black', size = 14),
             xaxis = list(tickangle = -45, title = ""),
             yaxis = list(title = "Number of Samples")) %>% config(displayModeBar = F)
    p
  })
  
  output$dashboardplot3 <- renderPlotly({
    normals <- plyr::count(sample.info[which(sample.info$group == "Normals"),c('study_id','tissue')])
    normals$tissue <- reorder(normals$tissue, normals$freq)
    normals$study_id <- paste0(' | ',normals$study_id)
    p <- plot_ly(normals, x = ~tissue, y=~freq, color=~tissue, split = ~study_id, type= 'bar') %>%
      layout(title = "", showlegend = F, margin = m, font = list(color = 'black', size = 14),
             xaxis = list(tickangle = -45, title = ""),
             yaxis = list(title = "Number of Samples")) %>% config(displayModeBar = F)
    p
  })
  ######### dashboard items ############
  
}) # shinyServer ends