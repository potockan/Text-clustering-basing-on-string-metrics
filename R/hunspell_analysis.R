
library(RSQLite)
library(stringi)
library(compiler)

## dbExecQuery function
source("./R/db_exec.R")

## function preparing strong to insert it to db
prepare_string <- cmpfun(function(str) {
  stri_paste("'", stri_replace_all_fixed(str, "'", "''"), "'")
})


source("./R/hunspell_analysis_function.R")
source("./R/words_diff_after_stem.R")

#first stemming
# hunspell -i utf-8 -d pl_PL -m  -G  words.txt > words_analiza_morfologiczna.txt
file1 <- "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/words_analiza_morfologiczna.txt"
file2 <- "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/words_analized.txt"
hunspell_analysis(file1, file2)


#file1 - RDS_all
#file2 - analyzed
#file3 - save to analyze
#file4 - save to analyze upper case
#file5 - save_RDS_left
file1 <- "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/words_no_stpw.rds"
file2 <- "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/words_analized.txt"
file3 <- "/dragon/Text-clustering-basing-on-string-metrics/Data//RObjects/words_to_analize.txt"
file4 <- "/dragon/Text-clustering-basing-on-string-metrics/Data//RObjects/words_to_analize_upper.txt"
file5 <- "/dragon/Text-clustering-basing-on-string-metrics/Data//RObjects/words_to_analize.rds"

words_diff(file1, file2, file3, file4, file5)


#second stemming
# hunspell -i utf-8 -d pl_PL -m  -G  words_to_analize_upper.txt > words_analiza_morfologiczna.txt
hunspell_analysis("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/words_analiza_morfologiczna.txt")


#file1 - RDS_all
#file2 - analyzed
#file3 - save to analyze
#file4 - save to analyze upper case
#file5 - save_RDS_left
file1 <- "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/words_to_analize.rds"
file2 <- "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/words_analiza_morfologiczna.txt"
file3 <- "/dragon/Text-clustering-basing-on-string-metrics/Data//RObjects/words_to_analize.txt"
file4 <- "/dragon/Text-clustering-basing-on-string-metrics/Data//RObjects/words_to_analize_upper.txt"
file5 <- "/dragon/Text-clustering-basing-on-string-metrics/Data//RObjects/words_to_analize.rds"

words_diff(file1, file2, file3, file4, file5)



#third stemming
# hunspell -i utf-8 -d en_GB -m  -G  words_to_analize.txt > words_analiza_morfologiczna.txt
hunspell_analysis("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/words_analiza_morfologiczna.txt")


#file1 - RDS_all
#file2 - analyzed
#file3 - save to analyze
#file4 - save to analyze upper case
#file5 - save_RDS_left
file1 <- "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/words_to_analize.rds"
file2 <- "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/words_analiza_morfologiczna.txt"
file3 <- "/dragon/Text-clustering-basing-on-string-metrics/Data//RObjects/words_to_analize.txt"
file4 <- "/dragon/Text-clustering-basing-on-string-metrics/Data//RObjects/words_to_analize_upper.txt"
file5 <- "/dragon/Text-clustering-basing-on-string-metrics/Data//RObjects/words_to_analize.rds"

words_diff(file1, file2, file3, file4, file5)
