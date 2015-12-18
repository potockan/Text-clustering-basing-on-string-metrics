nazwy <- c('_', '_lcs', '_dl','_jaccard','_qgram',
           '_red_lcs','_red_dl','_red_jaccard','_red_qgram',
           '_red_lcs_lcs','_red_dl_dl','_red_jaccard_jaccard','_red_qgram_qgram')

nazwy <- c('_lcs', '_dl','_jaccard','_qgram',
           '_red_lcs','_red_dl','_red_jaccard','_red_qgram',
           '_red_lcs_lcs','_red_dl_dl','_red_jaccard_jaccard','_red_qgram_qgram')


t <- list()
# for(i in 1:5){
  i <- 1
  b <- character()
  for(a in nazwy){
    #for(bb in c(5000, 10000, 35000, 70000))
      b <- c(b,sprintf("python /home/natalia/Text-clustering-basing-on-string-metrics/Python/python_mini_batch/101_clustering.py --i %d --typ %s; ", i, a))
  }
  t[[i]] <- b
#}

t

#install.packages("stringi")
library(stringi)
lapply(t, stri_flatten, collapse = " ")
#for(i in 1:13)
  #cat(t[[i]], file = sprintf("/home/samba/potockan/mgr/czesc%d/skrypt1.sh", i))
  cat(t[[i]], file = sprintf("/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/partitions4/czesc%d/skrypt1.sh", i))



