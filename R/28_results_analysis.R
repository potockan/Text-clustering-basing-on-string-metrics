
library(dplyr)
library(ggplot2)
library(stringi)
library(gridExtra)

obrobka_wynikow <- function(partition){
  nazwy <- c('_', '_lcs', '_dl','_jw', '_jaccard','_qgram',
             '_red_lcs','_red_dl','_red_jw','_red_jaccard','_red_qgram',
             '_red_lcs_lcs','_red_dl_dl','_red_jw_jw','_red_jaccard_jaccard','_red_qgram_qgram')
  # liczby <- c(5000,10000,35000)
  liczby <- c(5000)
  if(partition == "partitions3")
    liczby <- liczby[1:2]
  
  k <- 0
  aa <- list()
  for(i in 1:length(nazwy)){
    for(j in 1:length(liczby)){
      k<- k+1
      aa[k] <- read.table(sprintf(
        "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/%s/czesc1/wyn_%d_%s_5_",
        partition, liczby[j], nazwy[i]),  
        header = FALSE)
    }
  }
  j <- 3
  if(partition == "partitions3")
    j <- 2
  wyniki <- data.frame(matrix(ncol = 10))
  for(i in length(aa):1){
    k <- i%%j
    nazwy[ceiling(i/j)] %>% 
      c(liczby[ifelse(k == 0, j, k)], aa[[i]] ) %>% 
      matrix(ncol = 10) %>% 
      data.frame() %>% 
      bind_rows(wyniki) %>% 
      as.data.frame() -> wyniki
  }
  
  wyniki <- wyniki[-nrow(wyniki),]
  wyniki[,1] <- as.character(wyniki[,1])
  
  for(i in c("dl","lcs","jw","jaccard","qgram")){
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
  wyniki[wyniki[,1] == "clust_",1] <- "clust"
  
  names(wyniki) <- c("Typ danych", 
                     "Batch size",
                     "Jednorodnosc", 
                     "Zgodnosc", 
                     "Miara V", 
                     "Skorygowany indeks Randa",
                     "Silhouettes",
                     "AMI",
                     "NMI",
                     "Indeks Fowlkesa Mallowsa")
  
  wyniki <- as.data.frame(wyniki)
  for(i in 3:10)
    wyniki[,i] <- as.numeric(wyniki[,i])
  
  wyniki <- wyniki[,-c(8,9)]
  wyniki
}


wyniki <- obrobka_wynikow("partitions1")
wyniki <- cbind(wyniki, liczba_obs = rep("100%", 48))
wyniki <- obrobka_wynikow("partitions2") %>% 
  cbind(liczba_obs = rep("15%", 48)) %>% 
  bind_rows(wyniki, .)
wyniki <- obrobka_wynikow("partitions3") %>% 
  cbind(liczba_obs = rep("2%", 32)) %>% 
  bind_rows(wyniki, .)

# knitr::kable(wyniki)
#names(wyniki) <- c("Typ danych", "Batch", "Jedn.", "Zup.", "Miara V", "ARI", "Silhouettes", "Część")
# xtable::xtable(wyniki)

# write.csv(wyniki, "/dragon/Text-clustering-basing-on-string-metrics/Data/WYNIKI/wyniki_20151205.csv")
# write.csv(wyniki, "/dragon/Text-clustering-basing-on-string-metrics/Data/WYNIKI/wyniki_20151213.csv")
# write.csv(wyniki, "/dragon/Text-clustering-basing-on-string-metrics/Data/WYNIKI/wyniki_20151220.csv", row.names = FALSE)

j <- 10
g <- list()
names(wyniki) <- c("Typ danych", 
                   "Batch size", 
                   "Jednorodnosc", 
                   "Zgodnosc", 
                   "Miara V", 
                   "ARI", 
                   "Silhouettes", 
                   "Indeks FM")
nazwy <- names(wyniki)[3:8]
for(i in 1:length(nazwy)){
    g[[i]] <- 
      ggplot(wyniki, 
             aes(x=factor(`Typ danych`, levels = unique(wyniki$`Typ danych`)), 
                 y=eval(parse(text = paste0("`",nazwy[i], "`")))))+#, 
                 #fill=factor(`Batch size`, levels = sort(unique(as.numeric(wyniki$`Batch size`)))))) + 
      geom_bar(stat="identity", position="dodge") +
      # facet_wrap(~liczba_obs, ncol = 1) +
      ylab(nazwy[i]) +
      xlab("Typ danych") +
      theme(text = element_text(size=25),
            axis.text.x = element_text(angle = 45, hjust = 0.9, size = 20), 
            axis.text.y = element_text(size = 20), 
            legend.position = "top") +
      guides(fill=guide_legend(title="Batch size"))
    # ggsave(filename = paste0("LaTeX/plot",j,".pdf"), plot = g[[i]])
    ggsave(filename = paste0("Seminarium/plot",j,".pdf"), plot = g[[i]])
    
    
    #pdf(file = paste0("LaTeX/plot",j+5,".pdf"))
    #print(g[[k]])
    #dev.off()
    j <- j+1
#   print(j+8)
#   pdf(file = paste0("LaTeX/plot",j+8,".pdf"))
#   grid.arrange(a,
#                b,
#                nrow = 2, ncol = 1)
#   dev.off()
}

wyniki <- wyniki[,c(1:5,7,8,9)]
# write.csv(wyniki, "/dragon/Text-clustering-basing-on-string-metrics/Data/WYNIKI/wyniki_20151227.csv", row.names = FALSE)
wyniki <- read.csv("/dragon/Text-clustering-basing-on-string-metrics/Data/WYNIKI/wyniki_20151227.csv")
names(wyniki) <- c("Typ danych", "Batch", "Jedn.", "Zup.", "Miara V", "ARI", "FMI", "Silhouettes", "Część")
library(xtable)
aa <- xtable(wyniki[1:52,])
align(aa) <- "|rlr|rrr|rr|r|r|"
print(aa, hline.after = c(-1, 0, seq(4, 52, 4)))

aa <- xtable(wyniki[53:104,])
align(aa) <- "|rlr|rrr|rr|r|r|"
print(aa, hline.after = c(-1, 0, seq(4, 52, 4)))

aa <- xtable(wyniki[105:130,])
align(aa) <- "|rlr|rrr|rr|r|r|"
print(aa, hline.after = c(-1, 0, seq(2, 26, 2)))


#############
 
#%>% filter(liczba_obs == '2%')

wyn <- wyniki %>% 
  #filter(liczba_obs == '100%') %>% 
  group_by(`Typ danych`) %>% 
  summarise(zg = mean(`Indeks Fowlkesa Mallowsa`)) %>% 
  arrange(desc(zg))



