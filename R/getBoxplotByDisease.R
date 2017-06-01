
getBoxplotByDisease <- function(genes, studies, norm, subset, log, collapse, ref){
  
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
    dat <- dat[grep(defs, ignore.case = T, dat$definition), c('study','sample_id','rsem.fpkm','disease','tissue')]
  }
  
  dat$disease <- ifelse(dat$disease == "NA", dat$tissue, dat$disease)
  
  if(collapse == 'none'){
    to.lev <- dat %>% group_by(disease) %>% summarise(median = median(rsem.fpkm)) %>% as.data.frame()
    to.lev <- to.lev[order(to.lev$median),]
    dat$disease <- factor(dat$disease, levels = as.character(to.lev$disease))
  }
  
  if(collapse != 'none'){
    dat <- dat %>% group_by(disease) %>% mutate(mean = mean(rsem.fpkm)) %>% as.data.frame()
    dat[which(dat$study==collapse),'rsem.fpkm'] <- dat[which(dat$study == collapse),'mean']
    dat[which(dat$study==collapse),'disease'] <- collapse
  }
  
  # number of samples
  ct <- plyr::count(dat, 'disease')
  ct$freq <- paste0(ct$disease,' (',ct$freq,')')
  dat <- merge(dat, ct, by = 'disease')
  to.lev <- dat %>% group_by(freq) %>% summarise(median = median(rsem.fpkm)) %>% as.data.frame()
  to.lev <- to.lev[order(to.lev$median),]
  dat$freq <- factor(dat$freq, levels = as.character(to.lev$freq))
  
  # set reference level
  if(ref != 'none'){
    ref <- grep(ref, levels(dat$freq), value = T)
    dat$freq <- relevel(x = dat$freq, ref = ref)
  }
  
  p <- ggplot(dat, aes(x = freq, y = rsem.fpkm, fill = study)) + geom_boxplot() + xlab('') + mytheme2() + scale_fill_brewer(palette = 'Set1')
  p <- plotly_build(p)
  
  return(p)
}