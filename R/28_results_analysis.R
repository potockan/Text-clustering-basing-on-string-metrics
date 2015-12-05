


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
      "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/partitions/czesc1/wyniki%s/wyn_%d_%s",
      nazwy[i],liczby[j], nazwy[i]), 
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
    bind_rows(wyniki) -> wyniki
}

wyniki <- wyniki[-nrow(wyniki),]

names(wyniki) <- c("Typ danych", 
                   "Batch size",
                   "Jednorodność", 
                   "Zupełność", 
                   "Miara V", 
                   "Skorygowany indeks Randa",
                   "Silhouettes",
                   "AMI",
                   "NMI")

wyniki <- as.data.frame(wyniki)
for(i in 3:9)
  wyniki[,i] <- as.numeric(wyniki[,i])

knitr::kable(wyniki)

write.csv(wyniki, "/dragon/Text-clustering-basing-on-string-metrics/Data/WYNIKI/wyniki_20151205.csv")
