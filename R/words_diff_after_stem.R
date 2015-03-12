library(RSQLite)
library(stringi)
library(compiler)

#file1 - RDS_all
#file2 - analyzed
#file3 - save to analyze
#file4 - save to analyze upper case
#file5 - save_RDS_left
words_diff <- function(file1, file2, file3, file4, file5){
  
  
  
  #reading all words, excluding stopwords and words that have 1 character
  message("Reading all words")
  words <- stri_trans_tolower(readRDS(file1))
   
  
  #reading all clustered words
  message("Reading analyzed")
  f2 <- file(file2, "r")
  
  analized_words <- readLines(con = f2)
  
#   while (length(txt <- readLines(con = f2, n=8192)) > 0) {
#     
#     txt <- txt[which(stri_length(txt)>0)]
#     
#     txt_split <- lapply(stri_split_fixed(txt, " "), function(txt){
#       p <- unlist(stri_split_fixed(txt, "st:"))
#       p <- p[which(stri_length(p)>0 & p!="fl")]
#       n <- length(p)
#       if(n==1)
#         p[2] <- ""
#       p[1:2]
#       
#     })
#     #txt_split
#     
#     m1 <- matrix(unlist(txt_split), ncol = 2, byrow = TRUE)
#     m1 <- m1[-which(duplicated(m1[,1])),]
#     analized_words <- unique(c(analized_words, m1[,1]))
#     
#   }
  close(f2) 
  
  
  #saving not analized words
  message("Setdiff")
  not_analized_words <- setdiff(words, stri_trans_tolower(analized_words))
  message("Saving not analyzed")
  g <- file(file3, 'w')
  writeLines(text = not_analized_words, con = g)
  close(g)
  
  message("Saving RDS")
  #sve RDS
  saveRDS(not_analized_words, file5)

  message("Saving upper case")
  ### upper case
  stri_sub(not_analized_words, 1, 1) <- stri_trans_toupper(stri_sub(not_analized_words, 1, 1))
  g <- file(file4, 'w')
  writeLines(text = not_analized_words, con = g)
  close(g)

}