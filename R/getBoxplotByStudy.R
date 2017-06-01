getBoxplotByStudy <- function(genes, studies, norm, subset, log){
  
  dat <- getDataAnnotationByGeneSymbol(myGeneSymbols = genes, 
                                       myStudy = studies, 
                                       myNorms = norm)
  
  dat <- dat[-which(dat$definition == "Solid Tissue Normal"),]
  
  if(log == TRUE){
    dat$rsem.fpkm <- log2(dat$rsem.fpkm+1)
  }
  
  if(subset != "All"){
    defs <- subset
    defs <- c('normal', defs)
    defs <- paste(defs, collapse = "|")
    dat <- dat[grep(defs, ignore.case = T, dat$definition), c('study','sample_id','rsem.fpkm')]
  }
 
  p <- ggplot(dat, aes(x = study, y = rsem.fpkm, fill = study)) + geom_boxplot() + guides(fill = FALSE) + xlab('') + mytheme() + scale_fill_brewer(palette = 'Set1')
  p <- plotly_build(p)
  
  return(p)
}