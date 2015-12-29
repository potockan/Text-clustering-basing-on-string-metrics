### new
### stemmed: 473496 / 1019320 == 46.45 %
### 430401 Polish words
### 27274 == 457675 - 430401 English words
### 8126 == 465801 - 457675 French words
### 7695 == 473496 - 465801 German words

### old
### stemmed: 746 957 / 2 805 858 == 26.62134 %
### 664 315 Polish words
### 41 087 == 705402 - 664315 English words
### 20 438 == 725840 - 705402 French words
### 21 117 == 746957 - 725840 German words


library(RSQLite)
library(stringi)
library(compiler)
library(dplyr)

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
              where id_word not in (select id_word from wiki_hunspell_clust2) 
                and id_word not in (select id from wiki_word where word in (%s))
           group by id_word
           order by freq desc
           ) a
            join
            wiki_word b
            on a.id_word = b.id
            ", stri_flatten(prepare_string(stopwords[!is.na(stopwords)]), collapse=",")))

cat(word_to_analize$word, file = "/home/natalia/LanguageTool-2.8/words_to_analize.txt", sep = "\n")

# words that are wiki connected 
stri_detect_fixed(word_to_analize$word, "wiki") -> bb
word_to_analize[bb,]
word_to_analize <- word_to_analize[!bb,]

# most frequent words
word_to_analize %>% filter(freq>1000) %>% arrange(desc(freq)) %>% select(word)

#words that apperead more than x times
######### chosen x is 5 #########
x <- 5
cat(word_to_analize$word[word_to_analize$freq>x], file = "/home/natalia/LanguageTool-2.8/words_to_analize2.txt", sep = "\n")

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
