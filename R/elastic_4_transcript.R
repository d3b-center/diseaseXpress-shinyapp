library(elastic)
library(jsonlite)

# example
# index <- 'disease_express'
# type <- 'genes'
# genes <- c('PKD1','ALK')
# fields <- c('samples.sample_id','samples.transcripts.transcript_id',
#             'samples.transcripts.sample_rsem_isoform.tpm',
#             'gene_info.transcripts.biotype')
# samp_ids <- 'SRR1310210'

get.transcript.data <- function(index, type, genes, fields, samp_ids){
  
  # list of genes becomes query
  query <- paste(genes, collapse = ' OR ')
  query <- paste0('_id:','(',query,')')
  
  # fields to pull become body
  set.fields <- c('samples.sample_id', 'samples.transcripts.transcript_id', 'samples.transcripts.sample_rsem_isoform.tpm','gene_info.symbol')
  if(length(fields)>0){
    fields <- c(set.fields, fields)
  }
  if(length(fields)==0){
    fields <- set.fields
  }
  n.fields <- length(fields)
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
  dat <- dat[,-which(colnames(dat) %in% c('_type','_score','_index'))]
  samples <- mapply(function(x, y) cbind(x, `_id` = y), dat$`_source.samples`, dat$`_id`, SIMPLIFY = FALSE)
  dat$`_source.samples` <- NULL
  samples <- rbind.pages(samples)
  samples <- samples[which(samples$sample_id %in% samp_ids),]
  dat <- merge(dat, samples, by= "_id")
  transcripts <- mapply(function(x, y, z) cbind(x, sample_id = y, `_id` = z), dat$transcripts, dat$sample_id, dat$`_id`, SIMPLIFY = FALSE)
  dat$transcripts <- NULL
  dat <- merge(dat, rbind.pages(transcripts), by = c("sample_id","_id"))
  
  if(n.fields == 5){
    dat <- cbind(dat, dat$`_source.gene_info.transcripts`[[1]], row.names = NULL)
    dat$`_source.gene_info.transcripts` <- NULL
  }
  
  return(dat)
}






