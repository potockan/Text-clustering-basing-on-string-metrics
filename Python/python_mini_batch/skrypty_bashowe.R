nazwy <- c('_', '_lcs', '_dl','_jaccard','_qgram',
           '_red_lcs','_red_dl','_red_jaccard','_red_qgram',
           '_red_lcs_lcs','_red_dl_dl','_red_jaccard_jaccard','_red_qgram_qgram')

# nazwy <- c('_jaccard','_qgram',
# '_red_lcs','_red_dl','_red_jaccard','_red_qgram',
# '_red_lcs_lcs','_red_dl_dl','_red_jaccard_jaccard','_red_qgram_qgram')


t <- list()
# for(i in 1:5){
  i <- 1
  b <- character()
  for(a in nazwy){
    for(bb in c(5000, 10000, 35000, 70000))
      b <- c(b,sprintf("python /home/natalia/Text-clustering-basing-on-string-metrics/Python/python_mini_batch/100_clustering.py --i %d --typ %s --b %d; ", i, a, bb))
  }
  t[[i]] <- b
#}

t

#install.packages("stringi")
library(stringi)
lapply(t, stri_flatten, collapse = " ")
#for(i in 1:13)
  #cat(t[[i]], file = sprintf("/home/samba/potockan/mgr/czesc%d/skrypt1.sh", i))
  cat(t[[i]], file = sprintf("/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/partitions/czesc%d/skrypt1.sh", i))


#########################
nazwy <- c("_qgram")
t <- list()
for(i in 1:13){
  b <- character()
  for(a in nazwy)
    b <- c(b,sprintf("/opt/anaconda/bin/python3 ../client2.py --i %d --typ %s; ", i, a))
  t[[i]] <- b
}

t

#install.packages("stringi")
library(stringi)
lapply(t, stri_flatten, collapse = " ")
for(i in 1:13)
  cat(t[[i]], file = sprintf("/home/samba/potockan/mgr/czesc%d/skrypt1.sh", i))



for(i in 1:13){
  for(j in nazwy){
    cat(" ", file = sprintf("/home/samba/potockan/mgr/czesc%d/srodki_%s.txt", i, j))
  }
}

for(j in nazwy){
  cat(" ", file = sprintf("/home/samba/potockan/mgr/all/srodki_%s.txt", i, j))
}