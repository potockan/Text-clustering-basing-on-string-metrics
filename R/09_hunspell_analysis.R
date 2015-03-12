library(RSQLite)

##this script does a hunspell stemming in choosen languages
source("./R/hunspell_analysis_function.R")
source("./R/words_diff_after_stem.R")


con <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")
dbExecQuery(con, "drop table wiki_hunspell_clust")
dbDisconnect(con)

languages <- c("pl_PL", "en_GB", "fr_FR", "de_DE")
file.copy("/dragon/Text-clustering-basing-on-string-metrics//Data//RObjects/words.txt", 
          "/dragon/Text-clustering-basing-on-string-metrics/Data//RObjects/words_to_analize.txt", overwrite = TRUE)

#file1 - morfologik analysis
#file2 - save analyzed

#file3 - RDS_all
#file4 - analyzed
#file5 - save to analyze
#file6 - save to analyze upper case
#file7 - save_RDS_left

file1 <- "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/words_analiza_morfologiczna.txt"
file2 <- "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/words_analized.txt"
file3 <- "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/words_no_stpw.rds"
file4 <- file2
file5 <- "/dragon/Text-clustering-basing-on-string-metrics/Data//RObjects/words_to_analize.txt"
file6 <- "/dragon/Text-clustering-basing-on-string-metrics/Data//RObjects/words_to_analize_upper.txt"
file7 <- "/dragon/Text-clustering-basing-on-string-metrics/Data//RObjects/words_to_analize.rds"

for(lang in languages){
  message(lang)
  system2("hunspell", sprintf("-i utf-8 -d %s -m -G %s", 
                              lang,
                              file5), stdout = file1)
  hunspell_analysis(file1, file2)
  words_diff(file3, file4, file5, file6, file7)
  message("Upper")
  system2("hunspell", sprintf("-i utf-8 -d %s -m -G %s > %s", 
                              lang,
                              "/dragon/Text-clustering-basing-on-string-metrics/Data//RObjects/words_to_analize_upper.txt", 
                              "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/words_analiza_morfologiczna.txt"))
  hunspell_analysis(file1, file2)
  words_diff(file3, file4, file5, file6, file7)
  
}


# no-loop version in tmp



