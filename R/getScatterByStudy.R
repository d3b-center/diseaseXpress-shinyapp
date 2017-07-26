
getScatterByStudy <- function(gene1, gene2, studies, norm, log, subset, colorby, correlation){
  
  genes <- c(gene1, gene2)
  if(norm == 'rsem') {
    lab <- paste0('RSEM_Gene (', genes, ')')
  } else if(norm == 'sample_rsem_isoform') {
    lab <- paste0('RSEM_Isoform (', genes, ')')
  } else {
    lab <- paste0('Kallisto_Abundance (', genes, ')')
  }
  
  dat <- getDataAnnotationByGeneSymbol(myGeneSymbols = genes, 
                                       myStudy = studies, 
                                       myNorms = norm)
  
  dat <- dat[grep("Solid Tissue Normal", dat$definition, invert = T),]
  
  if(log == TRUE){
    dat$data.rsem.fpkm <- log2(dat$data.rsem.fpkm+1)
    lab <- paste0('log2_',lab)
  }
  
  if(subset != "All"){
    defs <- subset
  } else {
    defs <- c('Primary', 'Recurrent')
  }
  
  defs <- c('normal', defs)
  defs <- paste(defs, collapse = "|")
  dat <- dat[grep(defs, ignore.case = T, dat$definition), c('study','data.sample_id','data.rsem.fpkm','disease','tissue','gene_symbol', 'definition')]
  dat <- dat %>% group_by(data.sample_id, gene_symbol) %>% mutate(data.rsem.fpkm = mean(data.rsem.fpkm)) %>% as.data.frame() %>% unique()
  dat$disease <- ifelse(is.na(dat$disease), dat$tissue, dat$disease)
  
  dat <- dcast(data = dat, formula = study + data.sample_id + disease + definition ~ gene_symbol, value.var = "data.rsem.fpkm")
  
  # modify gene name, dashes present
  gene1.mut <- paste0('`',gene1,'`')
  gene2.mut <- paste0('`',gene2,'`')
  
  # compute correlation
  correlations <- plyr::ddply(.data = dat, .variables = colorby, .fun = function(x) getCorr(dat = x, gene1 = gene1, gene2 = gene2, correlation = correlation, log = log))
  
  # dotplot
  p <- ggplot(dat, aes_string(x = gene1.mut, y = gene2.mut, color = colorby)) + geom_point() + xlab(lab[1]) + ylab(lab[2]) + mytheme3() + geom_smooth(method = "lm") + scale_color_brewer(palette = 'Set1')
  p <- plotly_build(p)
  
  newList <- list(p, correlations)
  return(newList)
}
