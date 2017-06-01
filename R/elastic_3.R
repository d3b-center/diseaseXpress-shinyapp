library(elastic)
library(jsonlite)
source('connect_to_server.R')

# index <- 'pnoc'
# type <- 'genes'
# genes <- c('PKD1','AAAS','A2M','5S_rRNA')
# fields <- c('samples.sample_id','samples.rsem.fpkm','gene_info.biotype')

get.gene.data <- function(index, type, genes, fields){
  
  # list of genes becomes query
  query <- paste(genes, collapse = ' OR ')
  query <- paste0('gene_info.symbol:','(',query,')')
  
  # fields to pull become body
  fields <- paste0('"', fields, collapse = '",')
  fields <- paste0(fields, '"')
  body <- paste0('{"_source": [',fields,']}')
  
  out <- Search(index = index, 
                type = type, 
                q = query, 
                body = body, 
                raw = TRUE)
  
  df <- jsonlite::fromJSON(out, flatten = TRUE, simplifyDataFrame = TRUE)
  n <- df$hits$total
  dat <- df$hits$hits
  dat <- jsonlite::flatten(dat, recursive = TRUE)
  dat <- dat[,-which(colnames(dat) %in% c('_type','_score'))]
  for(i in 1:n){
    if(i == 1){
      gene.level <- jsonlite::flatten(dat$`_source.samples`[[i]], recursive = TRUE)
      gene.level$id <- dat$`_id`[[i]]
      gene.level$symbol <- genes[i]
    }
    
    if(i > 1){
      gene <- jsonlite::flatten(dat$`_source.samples`[[i]], recursive = TRUE)
      gene$id <- dat$`_id`[[i]]
      gene$symbol <- genes[i]
      gene.level <- rbind(gene, gene.level)
    }
  }
  
  return(gene.level)
  
}






