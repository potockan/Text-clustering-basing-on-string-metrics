library(RSQLite)
library(stringi)
library(compiler)
library(stringdist)
library(Matrix)
library(dplyr)

source("./R/db_exec.R")
prepare_string <- cmpfun(function(str) {
  stri_paste("'", stri_replace_all_fixed(str, "'", "''"), "'")
})


con <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")



dbExecQuery(con, "create table if not exists wiki_word_clust_freq (
            id_title INTEGER NOT NULL,
            id_stem_word INTEGER NOT NULL,
            freq INTEGER NOT NULL,
            FOREIGN KEY (id_title) REFERENCES wiki_page(id),
            FOREIGN KEY (id_stem_word) REFERENCES wiki_word(id)
)")


#dbGetQuery(con, "select count(distinct id) as cnt from wiki_page")


# 
# 
# aa <- dbGetQuery(con, "
# select a.id_title, b.id_stem_word, sum(a.freq) as suma
# from 
# (  select *
#   from  wiki_word_freq 
# ) a
# join 
# (
#   select *
#   from wiki_hunspell_clust 
# ) b
# on
#   a.id_word = b.id_word
# group by 
#   a.id_title
#   ,b.id_stem_word
# ")

kategorie <- stri_trans_tolower(c(readRDS("./wszystkietyt.rds"), 
               readRDS("./wszystkietyt2.rds"), 
               readRDS("./wszystkietyt3.rds")))

kat <- dbGetQuery(con, sprintf("select *
  from wiki_category_name 
  where name in (%s)", stri_flatten(prepare_string(kategorie), collapse = " , ")))


# 
# 
# dbGetQuery(con, sprintf("
# select 
#   count(distinct b.id_title) as cnt 
# from 
#   wiki_category_text b 
# where
#   b.id_category in (%s)
# ", stri_flatten(kat[,1], collapse = " , ")))



dbExecQuery(con, sprintf("
insert into wiki_word_clust_freq(id_title, id_stem_word, freq)
select 
  a.id_title, b.id_stem_word, sum(a.freq) as freq
from 
(  select *
  from  wiki_word_freq 
  where id_title in (%s)
) a
join 
  wiki_hunspell_clust b
on
  a.id_word = b.id_word
group by 
  a.id_title
  ,b.id_stem_word
", stri_flatten(kat[,1], collapse = " , ")))


titles <- dbGetQuery(con, 
                     sprintf("select id, title from wiki_page where id in (%s)", 
                             stri_flatten(kat[,1], collapse = " , ")))
names(titles) <- c('id_title', 'title')

art_word_mat <- dbGetQuery(con, "select * from wiki_word_clust_freq")
id_art <- sort(unique(art_word_mat[,1]))
dict_art <- data.frame(id_title = id_art, nr_row = 1:length(id_art))
dict_art <- left_join(dict_art, titles)

id_word <- sort(unique(art_word_mat[,2]))
dict_word <- data.frame(id_stem_word = id_word, nr_col = 1:length(id_word))

stem_words <- dbGetQuery(con, 
                         sprintf("select id, word from wiki_word where id in (%s)", 
                                 stri_flatten(id_word, collapse = " , ")))
names(stem_words) <- c("id_stem_word", "word")

dict_word <- left_join(dict_word, stem_words)

art_word_mat <- left_join(left_join(art_word_mat, dict_art ), dict_word)

mattr <- sparseMatrix(art_word_mat$nr_row, art_word_mat$nr_col, x = art_word_mat$freq)

non_zero_art <- numeric(0)
for(i in 1:ncol(mattr)){
  non_zero_art <- c(non_zero_art, sum(mattr[,i]>0))
}


#dbExecQuery(con, "drop table tmp_hunspell")
dbDisconnect(con)









