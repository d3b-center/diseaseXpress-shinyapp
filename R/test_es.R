library(elastic)
library(jsonlite)
source('connect_to_server.R')

index <- 'target_test_v6'
type <- 'genes'
genes <- c('A1BG')
fields <- c('samples.sample_id','samples.rsem.fpkm','gene_info.biotype')


get.gene.data <- function(index, type, genes, fields){
  
  # list of genes becomes query
  query <- paste(genes, collapse = ' OR ')
  query <- paste0('gene_info.symbol:','(',query,')')
  
  # fields to pull become body
  if(length(grep('symbol',fields))==0){
    fields <- c('gene_info.symbol', fields)
  }
  fields <- paste0('"', fields, collapse = '",')
  fields <- paste0(fields, '"')
  body <- paste0('{"_source": [',fields,']}')
  
  out <- Search(index = index, 
                type = type, 
                q = query, 
                body = body, 
                raw = TRUE, analyze_wildcard = TRUE)
  
  df <- jsonlite::fromJSON(out, flatten = TRUE, simplifyDataFrame = TRUE)
  n <- df$hits$total
  dat <- df$hits$hits
  dat <- jsonlite::flatten(dat, recursive = TRUE)
  dat <- dat[,-which(colnames(dat) %in% c('_type','_score'))]
  samples <- mapply(function(x, y) cbind(x, `_id` = y), dat$`_source.samples`, dat$`_id`, SIMPLIFY = FALSE)
  dat$`_source.samples` <- NULL
  dat <- merge(dat, rbind.pages(samples), by= "_id")
  return(dat)
}
sample.info <- read.delim('data/sample_info_19418.txt', stringsAsFactors = F)
dat <- merge(dat, sample.info, by.x = 'sample_id', by.y = 'analysis_id')




