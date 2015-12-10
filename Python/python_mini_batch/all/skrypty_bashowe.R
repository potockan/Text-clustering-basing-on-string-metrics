nazwy <- c('_', '_lcs', '_dl','_jaccard','_qgram',
           '_red_lcs','_red_dl','_red_jaccard','_red_qgram',
           '_red_lcs_lcs','_red_dl_dl','_red_jaccard_jaccard','_red_qgram_qgram')

nazwy <- c('_dl','_jaccard','_qgram',
'_red_lcs','_red_dl','_red_jaccard','_red_qgram',
'_red_lcs_lcs','_red_dl_dl','_red_jaccard_jaccard','_red_qgram_qgram')


t <- list()
for(i in 1:13){
  b <- character()
  for(a in nazwy){
    if(a == '_lcs')
      b <- c(b,sprintf("/opt/anaconda/bin/python3 ../client2.py --i %d --typ %s; ", i, a))
    else
      b <- c(b,sprintf("/opt/anaconda/bin/python3 ../client.py --i %d --typ %s; ", i, a))
  }
  t[[i]] <- b
}

t

#install.packages("stringi")
library(stringi)
lapply(t, stri_flatten, collapse = " ")
for(i in 1:13)
  cat(t[[i]], file = sprintf("/home/samba/potockan/mgr/czesc%d/skrypt1.sh", i))



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



