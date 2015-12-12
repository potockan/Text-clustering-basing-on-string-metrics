#!/usr/bin/Rscript --vanilla

library(RSQLite)


con <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")

message("Counting word_freq...")
n_words_freq <- dbGetQuery(con, "select count(1) from wiki_word_freq")[1,1]
saveRDS(n_words_freq, file="/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/n_word_freq.rds")
n_words_freq <- readRDS("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/n_word_freq.rds")

message("Counting articles...")
n_articles <- dbGetQuery(con, "select count(1) from wiki_page")[1,1]
saveRDS(n_articles, file="/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/n_articles.rds")
n_articles <- readRDS("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/n_articles.rds")

message("Counting categories...")
n_categories <- dbGetQuery(con, "select count(1) from wiki_category_name")[1,1]
saveRDS(n_categories, file="/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/n_categories.rds")
n_categories <- readRDS("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/n_categories.rds")

message("Counting words...")
#cnt == in how many texts a word occured
word_stat <- dbGetQuery(con, "
                        select count(a.freq) as word_cnt, b.word as word
                        from wiki_word_freq a 
                        join
                        wiki_word b
                        on a.id_word=b.id
                        group by a.id_word
                        order by word_cnt desc")


saveRDS(word_stat, file="/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/words_cnt.rds")

message("Counting words appearance...")
#word_cnt_all == how many times a word apperead in all texts
word_stat_all <- dbGetQuery(con, "
                            select sum(a.freq) as word_cnt_all, b.word as word
                            from wiki_word_freq a
                            join
                            wiki_word b
                            on a.id_word=b.id
                            group by a.id_word
                            order by word_cnt_all desc
                            ")

saveRDS(word_stat_all, file="/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/words_cnt_all.rds")
word_stat_all <- readRDS("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/words_cnt_all.rds")
  

message("Counting number of words per article...")
#word_art == how many words apperead in the text
word_art <- dbGetQuery(con, "
                            select count(1) as cnt, a.id_title, b.title
                            from wiki_word_freq a
                            join 
                            wiki_page b
                            on a.id_title = b.id
                            group by a.id_title
                            ")

saveRDS(word_art, file="/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/word_art.rds")
word_art <- readRDS("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/word_art.rds")

  

dbDisconnect(con)
