  
library(dendextend)
library(stringi)



# 
# 
# true_labels <- read.table("/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/true_labels/labels__dl_2")
# km_labels <- read.table("/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/partitions5/czesc1/wyniki_10000__dl.txt")

sciezka <- "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase"
typy <- nazwy <- c('_', '_lcs', '_dl','_jaccard','_qgram',
                   '_red_lcs','_red_dl','_red_jaccard','_red_qgram',
                   '_red_lcs_lcs','_red_dl_dl','_red_jaccard_jaccard','_red_qgram_qgram')

# FM_index(km_labels$V1, true_labels$V1)


for(d in c(2,15,100)){
  p <- 5
  ff <- c(5000, 10000, 35000, 70000)
  if(d == 2)
    ff <- ff[1:2]
  if(d == 15)
    p <- 4
  if(d == 100)
    p <- 3
  for(typ in typy){
    true_labels <- 
      read.table(file.path(
        sciezka, 
        stri_flatten(
          c("true_labels/labels_", typ, "_", d))
      ))$V1
    for(f in ff){
      km_labels <- 
        read.table(file.path(
          sciezka, 
          stri_flatten(c("partitions", p, "/czesc1/wyniki_", f, "_", typ, ".txt"))
        ))$V1
      fm <- FM_index(km_labels, true_labels)
      
      cat(fm[1], file = 
            file.path(
              sciezka, 
              stri_flatten(c("partitions", p, "/czesc1/wyni_", f, "_", typ))),
          append = TRUE, sep = "\n"
      )
    }
    
  }
}


