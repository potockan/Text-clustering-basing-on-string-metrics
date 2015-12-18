
library(dplyr)
library(ggplot2)
library(stringi)

obrobka_wynikow <- function(partition){
  nazwy <- c('_', '_lcs', '_dl','_jaccard','_qgram',
             '_red_lcs','_red_dl','_red_jaccard','_red_qgram',
             '_red_lcs_lcs','_red_dl_dl','_red_jaccard_jaccard','_red_qgram_qgram')
  liczby <- c(5000,10000,35000,70000)
  
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
  
  wyniki <- data.frame(matrix(ncol = 9))
  for(i in length(aa):1){
    k <- i%%4
    nazwy[ceiling(i/4)] %>% 
      c(liczby[ifelse(k == 0, 4, k)], aa[[i]] ) %>% 
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


wyniki <- obrobka_wynikow("partitions")
wyniki <- cbind(wyniki, liczba_obs = rep("malo", 52))
wyniki <- obrobka_wynikow("partitions2") %>% 
  cbind(liczba_obs = rep("duzo", 52)) %>% 
  bind_rows(wyniki, .)

knitr::kable(wyniki)
xtable::xtable(wyniki)

write.csv(wyniki, "/dragon/Text-clustering-basing-on-string-metrics/Data/WYNIKI/wyniki_20151205.csv")
write.csv(wyniki, "/dragon/Text-clustering-basing-on-string-metrics/Data/WYNIKI/wyniki_20151213.csv")

j <- 5
for(i in names(wyniki)[3:7]){
  g <- 
    ggplot(wyniki, 
           aes(x=factor(`Typ danych`, levels = unique(wyniki$`Typ danych`)), 
               y=eval(parse(text = paste0("`",i, "`"))), 
               fill=factor(`Batch size`, levels = sort(unique(as.numeric(wyniki$`Batch size`)))))) + 
    geom_bar(stat="identity", position="dodge") +
    facet_wrap(~liczba_obs) +
    ylab(i) +
    xlab("Typ danych") +
    theme(axis.text.x = element_text(angle = 45, hjust = 0.9), 
          legend.position = "top") +
    guides(fill=guide_legend(title="Batch size"))
  print(g)
  ggsave(filename = paste0("LaTeX/plot",j,".pdf"), plot = g)
  j <- j+1
}



