
library(RSQLite)
library(stringi)
library(compiler)

## dbExecQuery function
source("./R/db_exec.R")
prepare_string <- cmpfun(function(str) {
  stri_paste("'", stri_replace_all_fixed(str, "'", "''"), "'")
})


con <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")
stopwords <- as.vector(as.matrix(read.table("/dragon/Text-clustering-basing-on-string-metrics/Data//RObjects//stopwords3.txt")))
dbGetQuery(con, sprintf("
          select a.freq, b.word 
          from
          (select freq, id_word
           from wiki_word_freq where id_word not in (select id_word from wiki_hunspell_clust where id_word not in 
           ( select id from wiki_word where word not in (%s))
            )
           order by freq desc
           limit 100) a
            join
            wiki_word b
            on a.id_word = b.id
            group by word", stri_flatten(prepare_string(stopwords[!is.na(stopwords)]), collapse=",")))
dbGetQuery(con, "select *
           from wiki_word_freq where freq = 2605")
dbGetQuery(con, "select *
           from wiki_word where id = 2671160")
dbDisconnect(con)