mytheme <- function(){
  tt <- theme_bw() + theme(axis.text = element_text(size = 14, colour = 'black'),
                           axis.title = element_text(size = 14, colour = 'black'))
  return(tt)
}

mytheme2 <- function(){
  tt <- theme_bw() + theme(axis.text = element_text(size = 14, colour = 'black'),
                           axis.title = element_text(size = 14, colour = 'black'),
                           axis.text.x = element_text(size = 14, angle = 90, hjust = 1, vjust = 1),
                           plot.margin = unit(c(1.5, 1.5, 1.5, 1.5), "cm"))
  return(tt)
}

mytheme3 <- function(){
  tt <- theme_bw() + theme(axis.text = element_text(size = 14, colour = 'black'),
                           axis.title = element_text(size = 14, colour = 'black'),
                           plot.margin = unit(c(1.5, 1.5, 1.5, 1.5), "cm"),
                           legend.text = element_text(size = 14, colour = 'black'),
                           legend.title = element_text(size = 14, colour = 'black'))
  return(tt)
}

