#!/usr/bin/Rscript --vanilla

library(RSQLite)

##this script does a hunspell stemming in choosen languages
source("./R/hunspell_analysis_function2.R")
source("./R/words_diff_after_stem.R")


con <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")
# # #dbExecQuery(con, "drop table wiki_hunspell_clust")
dbDisconnect(con)

languages <- c("pl_PL", "en_GB", "fr_FR", "de_DE")
#languages <- c("pl", "en", "fr", "de")
file.copy("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/words.txt", 
          "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/words_to_analize.txt", overwrite = TRUE)
file.copy("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/words_no_stpw.rds", 
          "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/words_to_analize.rds", overwrite = TRUE)

#file1 - morfologik analysis
#file2 - save analyzed

#file3 - to analyze.txt
#file4 - to analyze.rds
#file5 - to analyze upper case.txt


file1 <- "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/words_analiza_morfologiczna.txt"
file2 <- "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/words_analized.txt"
file3 <- "/dragon/Text-clustering-basing-on-string-metrics/Data//RObjects/words_to_analize.txt"
file4 <- "/dragon/Text-clustering-basing-on-string-metrics/Data//RObjects/words_to_analize.rds"
file5 <- "/dragon/Text-clustering-basing-on-string-metrics/Data//RObjects/words_to_analize_upper.txt"


for(lang in languages){
  message(lang)
  system2("hunspell", sprintf("-i utf-8 -d %s -m -G %s", 
                              lang,
                              file3), stdout = file1)
  hunspell_analysis(file1, file2)
  words_diff(file4, file2, file3, file5)
  message("Upper")
  system2("hunspell", sprintf("-i utf-8 -d %s -m -G %s", 
                              lang,
                              file5), stdout = file1)
  hunspell_analysis(file1, file2)
  words_diff(file4, file2, file3, file5)
  
}


# no-loop version in tmp



