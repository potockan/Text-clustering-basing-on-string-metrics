
library(dplyr)
library(ggplot2)
library(stringi)

obrobka_wynikow <- function(partition){
  nazwy <- c('_', '_lcs', '_dl','_jaccard','_qgram',
             '_red_lcs','_red_dl','_red_jaccard','_red_qgram',
             '_red_lcs_lcs','_red_dl_dl','_red_jaccard_jaccard','_red_qgram_qgram')
  liczby <- c(5000,10000,35000,70000)
  if(partition == "partitions5")
    liczby <- liczby[1:2]
  
  k <- 0
  aa <- list()
  for(i in 1:length(nazwy)){
    for(j in 1:length(liczby)){
      k<- k+1
      aa[k] <- read.table(sprintf(
        "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/%s/czesc1/wyn_%d_%s",
        partition, liczby[j], nazwy[i]),  
        header = FALSE)
    }
  }
  j <- 4
  if(partition == "partitions5")
    j <- 2
  wyniki <- data.frame(matrix(ncol = 9))
  for(i in length(aa):1){
    k <- i%%j
    nazwy[ceiling(i/j)] %>% 
      c(liczby[ifelse(k == 0, j, k)], aa[[i]] ) %>% 
      matrix(ncol = 9) %>% 
      data.frame() %>% 
      bind_rows(wyniki) %>% 
      as.data.frame() -> wyniki
  }
  
  wyniki <- wyniki[-nrow(wyniki),]
  wyniki[,1] <- as.character(wyniki[,1])
  
  for(i in c("dl","lcs","jaccard","qgram")){
    j <- i
    if(j == "jaccard")
      j <- "jac"
    if(j == 'qgram')
      j <- "qg"
    wyniki[,1] <- stri_replace_all_fixed(wyniki[,1], i, j)
    wyniki[,1] <- stri_replace_last_fixed(wyniki[,1], 
                                          stri_flatten(c("red", rep(j,2)), collapse = "_"),
                                          stri_flatten(c(j,"red",j), collapse = "_")
    )
  }
  wyniki[,1] <- stri_paste("clust", wyniki[,1])
  
  names(wyniki) <- c("Typ danych", 
                     "Batch size",
                     "Jednorodnosc", 
                     "Zupelnosc", 
                     "Miara V", 
                     "Skorygowany indeks Randa",
                     "Silhouettes",
                     "AMI",
                     "NMI")
  
  wyniki <- as.data.frame(wyniki)
  for(i in 3:9)
    wyniki[,i] <- as.numeric(wyniki[,i])
  
  wyniki <- wyniki[,-c(8,9)]
  wyniki
}


wyniki <- obrobka_wynikow("partitions2")
wyniki <- cbind(wyniki, liczba_obs = rep("100%", 52))
wyniki <- obrobka_wynikow("partitions4") %>% 
  cbind(liczba_obs = rep("15%", 52)) %>% 
  bind_rows(wyniki, .)
wyniki <- obrobka_wynikow("partitions5") %>% 
  cbind(liczba_obs = rep("2%", 26)) %>% 
  bind_rows(wyniki, .)

knitr::kable(wyniki)
xtable::xtable(wyniki)

write.csv(wyniki, "/dragon/Text-clustering-basing-on-string-metrics/Data/WYNIKI/wyniki_20151205.csv")
write.csv(wyniki, "/dragon/Text-clustering-basing-on-string-metrics/Data/WYNIKI/wyniki_20151213.csv")

j <- 5
nazwy <- names(wyniki)[3:7]
for(i in seq(1, length(nazwy), by = 2)){
  g <- list()
  for(k in 1:2){
    print(nazwy[i+k-1])
    g[[k]] <- 
      ggplot(wyniki, 
             aes(x=factor(`Typ danych`, levels = unique(wyniki$`Typ danych`)), 
                 y=eval(parse(text = paste0("`",nazwy[i+k-1], "`"))), 
                 fill=factor(`Batch size`, levels = sort(unique(as.numeric(wyniki$`Batch size`)))))) + 
      geom_bar(stat="identity", position="dodge") +
      facet_wrap(~liczba_obs) +
      ylab(nazwy[i+k-1]) +
      xlab("Typ danych") +
      theme(axis.text.x = element_text(angle = 45, hjust = 0.9), 
            legend.position = "top") +
      guides(fill=guide_legend(title="Batch size"))
    print(g[[k]])
    print(j)
    print(j+5)
    ggsave(filename = paste0("LaTeX/plot",j,".pdf"), plot = g[[k]])
    pdf(file = paste0("LaTeX/plot",j+5,".pdf"))
    print(g[[k]])
    dev.off()
    j <- j+1
  }
  print(j+8)
  pdf(file = paste0("LaTeX/plot",j+8,".pdf"))
  g <- grid.arrange(g[[1]], 
                    g[[2]], 
                    nrow = 2, ncol = 1)
  dev.off()
}


