getBoxplotByStudy <- function(genes, studies, norm, subset, log){
  
  if(norm == 'rsem'){
    lab <- 'RSEM_Gene'
  } else if(norm == 'sample_rsem_isoform') {
    lab <- 'RSEM_Isoform'
  } else {
    lab <- 'Kallisto_Abundance'
  }
  
  dat <- getDataAnnotationByGeneSymbol(myGeneSymbols = genes, 
                                       myStudy = studies, 
                                       myNorms = norm)
  
  dat <- dat[grep("Solid Tissue Normal", dat$definition, invert = T),]
  
  if(log == TRUE){
    dat$data.rsem.fpkm <- log2(dat$data.rsem.fpkm+1)
    lab <- paste0('log2_', lab)
  }
  
  if(subset != "All"){
    defs <- subset
    defs <- c('normal', defs)
    defs <- paste(defs, collapse = "|")
    dat <- dat[grep(defs, ignore.case = T, dat$definition), c('study_id','data.sample_id','data.rsem.fpkm')]
  }
 
  p <- ggplot(dat, aes(x = study_id, y = data.rsem.fpkm, fill = study_id)) + geom_boxplot() + guides(fill = FALSE) + xlab('') + ylab(lab) + mytheme() + scale_fill_brewer(palette = 'Set1')
  p <- plotly_build(p)
  
  return(p)
}