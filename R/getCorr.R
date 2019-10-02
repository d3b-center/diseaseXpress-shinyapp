
getCorr <- function(dat, gene1, gene2, correlation, log){
  
  if(log == FALSE){
    x <- log2(dat[,gene1]+1)
    y <- log2(dat[,gene2]+1)
  } else {
    x <- dat[,gene1]
    y <- dat[,gene2]
  }
  
  cor <- cor.test(x = x, y = y, method = correlation)
  
  if(cor$p.value==0){
    cor.pval <- '< 2.2e-16'
  }
  if(cor$p.value>0){
    cor.pval <- as.numeric(format(cor$p.value, scientific = T, digits = 3))
  }
  if(cor$estimate==1){
    cor.est <- 1
  }
  if(cor$estimate!=1){
    cor.est <- as.numeric(format(cor$estimate, scientific = T, digits = 3))
  }

  cor.title <- data.frame(Cor = cor.est, Pval = cor.pval, stringsAsFactors = F)
  
  return(cor.title)
}
