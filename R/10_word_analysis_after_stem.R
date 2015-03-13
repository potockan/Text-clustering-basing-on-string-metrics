### stemmed: 733 828 / 2 805 858 == 26.15 %
### 655 287 polish words
### 41 069 == 696356 - 655287 english words
### 20 426 == 716782 - 696356 french words
### 17 046 == 733828 - 716782 german words


library(RSQLite)
library(stringi)
library(compiler)

## dbExecQuery function
source("./R/db_exec.R")
prepare_string <- cmpfun(function(str) {
  stri_paste("'", stri_replace_all_fixed(str, "'", "''"), "'")
})


con <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")
stopwords <- readLines("/dragon/Text-clustering-basing-on-string-metrics/Data//RObjects//stopwords3.txt")

#words and their freq in articles that were NOT clustered and are not a stopword/a word of length 1
word_to_analize <- dbGetQuery(con, sprintf("
          select a.freq, b.word 
          from
          (select sum(freq) as freq, id_word
           from wiki_word_freq 
              where id_word not in (select id_word from wiki_hunspell_clust) 
                and id_word not in (select id from wiki_word where word in (%s))
           group by id_word
           order by freq desc
           ) a
            join
            wiki_word b
            on a.id_word = b.id
            ", stri_flatten(prepare_string(stopwords[!is.na(stopwords)]), collapse=",")))

dbGetQuery(con, "
          select sum(freq) as freq
          from wiki_word_freq
          where freq=1
          group by id_word
            ")

dbGetQuery(con, "
          select count(*)
          from(
            select sum(freq) as freq
            from wiki_word_freq
            where freq=1
            group by id_word
          )
          where freq = 1
            ")

dbGetQuery(con, "
          select count(*)
          from wiki_word_freq
          group by id_word
            ")

plot(1:1000, word_to_analize$freq[1:1000])
sum(word_to_analize$freq>100)


dbGetQuery(con, "select count(distinct id_word) as cnt
           from wiki_hunspell_clust")
dbGetQuery(con, "select count(distinct id_stem_word) as cnt
           from wiki_hunspell_clust")
dbGetQuery(con, "select *
           from wiki_word where id = 2671160")
dbDisconnect(con)