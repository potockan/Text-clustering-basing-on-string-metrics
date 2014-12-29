#!/usr/bin/Rscript --vanilla

library(RSQLite)
library(stringi)
#library(compiler)

## dbExecQuery function
#source("./R/db_exec.R")

con <- dbConnect(SQLite(), dbname = "./Data/DataBase/wiki.sqlite")

n_words <- dbGetQuery(con, "select count(1) from wiki_word")[1,1]
n_words_freq <- dbGetQuery(con, "select count(1) from wiki_word_freq")[1,1]
word_stat <- dbGetQuery(con, "
           select count(a.freq) as word_cnt, b.word as word
           from wiki_word_freq a 
           join
           wiki_word b
           on a.id_word=b.id
           group by a.id_word
           order by word_cnt desc")


saveRDS(word_stat, file="./Data/RObjects/words_cnt.rds")

#x <- readRDS("./Data//RObjects//words_cnt.rds")

#"words" occuring only once starting with no letter
435125/length(word_stat$word[which(word_stat$word_cnt==1)])

#x <- word_stat$word[sample(nrow(word_stat), 5000)]
n_has_no_letter <- sum(stri_detect_regex(word_stat$word, "\\P{L}"))
n_has_letter <- sum(stri_detect_regex(word_stat$word, "\\P{L}"))
n_one_let <- sum(stri_length(word_stat$word)==1)

hist(word_stat$word_cnt[which(word_stat$word_cnt>100000)])


stopwords <- as.vector(as.matrix(read.table("./Data//RObjects//stopwords.txt", sep=",")[1,]))
stopwords2 <- as.vector(read.table("./Data//RObjects//stopwords2.txt", sep="
                         ")[,1])


