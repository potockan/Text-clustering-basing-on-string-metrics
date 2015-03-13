library(RSQLite)
library(stringi)
library(compiler)

#file1 - RDS left to analyze
#file2 - TXT analyzed
#file3 - TXT to analyze
#file4 - TXT to analyze upper case
words_diff <- function(file1, file2, file3, file4){
  
  
  #reading all words, that were not yet analyzed, excluding stopwords and words that have 1 character
  message("Reading all words")
  words <- stri_trans_tolower(readRDS(file1))
   
  
  #reading all clustered words
  message("Reading analyzed")
  f2 <- file(file2, "r")
  analized_words <- readLines(con = f2)
  close(f2) 
  
  
  #saving not analized words
  message("Setdiff")
  not_analized_words <- setdiff(words, stri_trans_tolower(analized_words))
  message("Saving not analyzed")
  g <- file(file3, 'w')
  writeLines(text = not_analized_words, con = g)
  close(g)
  
  message("Saving RDS")
  #save RDS
  saveRDS(not_analized_words, file1)

  message("Saving upper case")
  # upper case
  stri_sub(not_analized_words, 1, 1) <- stri_trans_toupper(stri_sub(not_analized_words, 1, 1))
  g <- file(file4, 'w')
  writeLines(text = not_analized_words, con = g)
  close(g)

}