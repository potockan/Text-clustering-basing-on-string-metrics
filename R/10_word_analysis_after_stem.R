### stemmed: 733 828 / 2 805 858 == 26.15 %
### 655 287 Polish words
### 41 069 == 696356 - 655287 English words
### 20 426 == 716782 - 696356 French words
### 17 046 == 733828 - 716782 German words


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

cat(word_to_analize$word, file = "/home/natalia/LanguageTool-2.8/words_to_analize.txt", sep = "\n")

#words that apperead more than once
cat(word_to_analize$word[word_to_analize$freq>1], file = "/home/natalia/LanguageTool-2.8/words_to_analize2.txt", sep = "\n")


#words that appeared only once in all the articles
dbGetQuery(con, "
          select sum(freq) as freq
          from wiki_word_freq
          where freq=1
          group by id_word
            ")
#number of words that appeared only once in all the articles
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
          select count(*) from
          (
          select count(*) as cnt
          from wiki_word_freq
          group by id_word)
            ")

plot(1:nrow(word_to_analize), word_to_analize$freq, log='y', type='l')
sum(word_to_analize$freq==1)
# 1 098 192 - number of words that appeared only once in all the articles

dbGetQuery(con, "select count(distinct id_word) as cnt
           from wiki_hunspell_clust")
dbGetQuery(con, "select count(distinct id_stem_word) as cnt
           from wiki_hunspell_clust")
dbGetQuery(con, "select *
           from wiki_word where id = 2671160")
dbDisconnect(con)
