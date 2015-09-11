library(RSQLite)
library(stringi)
library(compiler)
library(stringdist)


source("./R/db_exec.R")
prepare_string <- cmpfun(function(str) {
  stri_paste("'", stri_replace_all_fixed(str, "'", "''"), "'")
})


con <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")
words_to_analize <- readLines("/home/natalia/LanguageTool-2.8/words_to_analize2.txt")

words <- dbGetQuery(con, "
          select a.word, a.id 
          from wiki_word a
          join
          (select distinct id_stem_word
          from wiki_hunspell_clust2) b
          on
          a.id = b.id_stem_word
            ")

#str_dist <- stringdistmatrix(words_to_analize, words, method = 'lv')


######### word order #########
### one by one ###

# making an order on words such that the first has small distances to the second, the second to the third...
# without repetition of words
word_order <- function(words_to_analize, words, method = 'lcs'){
  # method <- 'lcs'
  #N <- 100
  N <- length(words_to_analize)
  
  used <- numeric(N)
  used <- 1
  #word closest to the first one
  used[1] <- which.min(stringdist(words$word, words_to_analize[1], method = method))
  
  for(i in 2:N){
    #word closest to the i-th word
    used[i] <- which.min(stringdist(words$word, words_to_analize[i], method = method))
    if(i%%100==0)
      print(i)
  }
  return(used)
}

used_lcs <- word_order(words_to_analize, words, method = 'lcs')
used_lcs <- used
#saveRDS(used_lcs, "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/used_lcs.rds")
used <- readRDS("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/used_lcs.rds")

words[used[1:100], 1]
words_to_analize[1:100]


dbExecQuery(con, "create table if not exists tmp_hunspell (
            word VARCHAR(256) NOT NULL,
            id_stem_word INTEGER NOT NULL,
            FOREIGN KEY (id_stem_word) REFERENCES wiki_word(id)
)")

to_insert <- sprintf("(%s, %d)", prepare_string(words_to_analize), words$id[used])
#print(5)
to_insert <- split(to_insert, rep(1:ceiling(length(to_insert)/500),
                                  length.out=length(to_insert)))

lapply(to_insert, function(to_insert) {
    dbExecQuery(con, sprintf("INSERT into tmp_hunspell(word, id_stem_word)
                                 values %s", stri_flatten(to_insert, collapse=",")))
})




dbExecQuery(con, "INSERT into wiki_hunspell_clust(id_word, id_stem_word)

select b.id as id_word, a.id_stem_word as id_stem_word
from tmp_hunspell a
join
wiki_word b
on a.word = b.word
")


dbExecQuery(con, "drop table tmp_hunspell")
dbDisconnect(con)

# n <- 10
# 
# n <- n+10
# words_to_analize[1:10+n]
# words[used][1:10+n]
# 
# ss <- sample(1:i, 10)
# words_to_analize[ss]
# words[used[ss]] #lv
# words[used2[ss]] #lcs

######################################################






