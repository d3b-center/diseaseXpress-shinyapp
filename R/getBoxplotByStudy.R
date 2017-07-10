getBoxplotByStudy <- function(genes, studies, norm, subset, log){
  
  dat <- getDataAnnotationByGeneSymbol(myGeneSymbols = genes, 
                                       myStudy = studies, 
                                       myNorms = norm)
  
  dat <- dat[grep("Solid Tissue Normal", dat$definition, invert = T),]
  
  if(log == TRUE){
    dat$data.rsem.fpkm <- log2(dat$data.rsem.fpkm+1)
  }
  
  if(subset != "All"){
    defs <- subset
    defs <- c('normal', defs)
    defs <- paste(defs, collapse = "|")
    dat <- dat[grep(defs, ignore.case = T, dat$definition), c('study','data.sample_id','data.rsem.fpkm')]
  }
 
  p <- ggplot(dat, aes(x = study, y = data.rsem.fpkm, fill = study)) + geom_boxplot() + guides(fill = FALSE) + xlab('') + mytheme() + scale_fill_brewer(palette = 'Set1')
  p <- plotly_build(p)
  
  return(p)
}