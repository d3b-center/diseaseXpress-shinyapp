
getBoxplotByDisease <- function(genes, studies, norm, subset, log, collapse, ref){
  
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
    dat <- dat[grep(defs, ignore.case = T, dat$definition), c('study','data.sample_id','data.rsem.fpkm','disease','tissue')]
  }
  
  dat$disease <- ifelse(is.na(dat$disease), dat$tissue, dat$disease)
  
  if(collapse == 'none'){
    to.lev <- dat %>% group_by(disease) %>% summarise(median = median(data.rsem.fpkm)) %>% as.data.frame()
    to.lev <- to.lev[order(to.lev$median),]
    dat$disease <- factor(dat$disease, levels = as.character(to.lev$disease))
  }
  
  if(collapse != 'none'){
    dat <- dat %>% group_by(disease) %>% mutate(mean = mean(data.rsem.fpkm)) %>% as.data.frame()
    dat[which(dat$study==collapse),'data.rsem.fpkm'] <- dat[which(dat$study == collapse),'mean']
    dat[which(dat$study==collapse),'disease'] <- collapse
  }
  
  # number of samples
  ct <- plyr::count(dat, 'disease')
  ct$freq <- paste0(ct$disease,' (',ct$freq,')')
  dat <- merge(dat, ct, by = 'disease')
  to.lev <- dat %>% group_by(freq) %>% summarise(median = median(data.rsem.fpkm)) %>% as.data.frame()
  to.lev <- to.lev[order(to.lev$median),]
  dat$freq <- factor(dat$freq, levels = as.character(to.lev$freq))
  
  # set reference level
  if(ref == ''){
    ref <- 'none'
  } else if(ref != 'none'){
    ref <- grep(ref, levels(dat$freq), value = T)
    dat$freq <- relevel(x = dat$freq, ref = ref)
  }
  
  p <- ggplot(dat, aes(x = freq, y = data.rsem.fpkm, fill = study)) + geom_boxplot() + xlab('') + ylab(lab) + mytheme2() + scale_fill_brewer(palette = 'Set1')
  p <- plotly_build(p)
  
  return(p)
}