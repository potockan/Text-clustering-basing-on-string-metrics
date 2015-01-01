#!/usr/bin/Rscript --vanilla

library(RSQLite)


con <- dbConnect(SQLite(), dbname = "./Data/DataBase/wiki.sqlite")

n_words_freq <- dbGetQuery(con, "select count(1) from wiki_word_freq")[1,1]

saveRDS(n_words_freq, file="./Data/RObjects/n_word_freq.rds")

#cnt == in how many texts a word occured
word_stat <- dbGetQuery(con, "
                        select count(a.freq) as word_cnt, b.word as word
                        from wiki_word_freq a 
                        join
                        wiki_word b
                        on a.id_word=b.id
                        group by a.id_word
                        order by word_cnt desc")


saveRDS(word_stat, file="./Data/RObjects/words_cnt.rds")

word_stat_all <- dbGetQuery(con, "
                            select sum(a.freq) as word_cnt_all, b.word as word
                            from wiki_word_freq a
                            join
                            wiki_word b
                            on a.id_word=b.id
                            group by a.id_word
                            order by word_cnt_all desc
                            ")

saveRDS(word_stat_all, file="./Data/RObjects/words_cnt_all.rds")


dbDisconnect(con)
