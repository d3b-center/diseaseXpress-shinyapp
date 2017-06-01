# source functions
source('R/viewDataTable.R')
source('R/connect_to_server.R')
source('R/elastic_4_gene.R')
source('R/elastic_4_transcript.R')
source('R/elastic_4_kallisto.R')
source('R/loaddata.R')

m <- list(
  b = 100,
  r = 50,
  pad = 4
)

shinyServer(function(input, output, session){
  
  # update gene symbols
  observe({
    updateSelectizeInput(session = session, inputId = "gdselectInput0", choices = gene_ann$gene_symbol, server = TRUE)
  })
  
  # update gene ids
  observe({
    mynames <- as.character(input$gdselectInput0)
    mynames <- gene_ann[which(gene_ann$gene_symbol %in% mynames),'gene_id']
    updateSelectizeInput(session = session, inputId = "gdselectInput1", choices = mynames, server = TRUE)
  })
  
  # observe({
  #   if(input$boxplotselectInput2 != "none"){
  #     x <- as.character(input$boxplotselectInput2)
  #     x <- plot_vars[which(plot_vars$study %in% x),'V2']
  #     updateSelectizeInput(session = session, inputId = "boxplotselectInput3", choices = x, server = TRUE)
  #   }
  # })
  # 
  # observe({
  #   if(length(input$boxplotselectInput3)>0){
  #     x <- as.character(input$boxplotselectInput3)
  #     y <- plot_vars[which(plot_vars$V2 %in% x),'V1']
  #     updateSelectizeInput(session = session, input = "boxplotselectInput4", choices = y, server = TRUE)
  #   }
  # })
  
  observe({
    if(input$gdselectInput3=="RSEM: FPKM"){
      updateSelectInput(session = session, inputId = "gdselectInput4", choices = c("Gene Biotype"="gene_info.biotype"))
    }
    if(input$gdselectInput3=="RSEM: TPM" | input$gdselectInput3=="Kallisto: TPM"){
      updateSelectInput(session = session, inputId = "gdselectInput4", choices = c("Transcript Biotype"="gene_info.transcripts.biotype"))
    }
  })
  
  
  # update datatable with query gdtable1
  output$gdtable1 <- DT::renderDataTable({
    if(input$gdsubmit1 == 0){
      return()
    }
    isolate({
      genes <- as.character(input$gdselectInput1)
      study <- as.character(input$gdselectInput2)
      samp_ids <- sample.info[which(sample.info$study %in% study),'analysis_id']
      fields <- as.character(input$gdselectInput4)
      index <- 'disease_express'
      type <- 'genes'
      
      if(input$gdselectInput3 == "RSEM: FPKM"){
        dat <- get.gene.data(index = index, type = type, genes = genes, fields = fields, samp_ids = samp_ids)
      }
      if(input$gdselectInput3 == "RSEM: TPM"){
        dat <- get.transcript.data(index = index, type = type, genes = genes, fields = fields, samp_ids = samp_ids)
      }
      if(input$gdselectInput3 == "Kallisto: TPM"){
        dat <- get.transcript.data.kallisto(index = index, type = type, genes = genes, fields = fields, samp_ids = samp_ids)
      }
      
      viewDataTable(dat = dat)
    })
  })
  
  output$dashboardplot1 <- renderPlotly({
    isolate({
      pie1 <- plyr::count(sample.info$study)
      p <- plot_ly(pie1, labels = ~x, values = ~freq, type = 'pie', showlegend = FALSE) %>%
        layout(title = 'Disease-Express Studies',
               xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
               yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE)) %>% 
        config(displayModeBar = F)
      p
    })
  })
  
  output$dashboardplot2 <- renderPlotly({
    tumors <- plyr::count(sample.info[which(sample.info$group == 'Tumors'),c('study','disease')])
    tumors$disease <- reorder(tumors$disease, tumors$freq)
    tumors$study <- paste0(' | ',tumors$study)
    p <- plot_ly(tumors, x = ~disease, y=~freq, color=~disease, split = ~study, type= 'bar') %>%
      layout(title = "", showlegend = F, margin = m,
             xaxis = list(tickangle = -45, title = ""),
             yaxis = list(title = "Number of Samples")) %>%
      config(displayModeBar = F)
    p
  })
  
  output$dashboardplot3 <- renderPlotly({

    normals <- plyr::count(sample.info[which(sample.info$group == "Normals"),c('study','tissue')])
    normals$tissue <- reorder(normals$tissue, normals$freq)
    normals$study <- paste0(' | ',normals$study)
    p <- plot_ly(normals, x = ~tissue, y=~freq, color=~tissue, split = ~study, type= 'bar') %>%
      layout(title = "", showlegend = F, margin = m,
             xaxis = list(tickangle = -45, title = ""),
             yaxis = list(title = "Number of Samples")) %>%
      config(displayModeBar = F)
    p
  })
  
  
}) # shinyServer ends