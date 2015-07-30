
rm(list = ls())

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

### # dbExecQuery(con, "drop table if exists wiki_word_clust_freq")

#creating table with id_tittle, id_stem_word and its frequency (as a group)
# dbExecQuery(con, "create table if not exists wiki_word_clust_freq (
#             id_title INTEGER NOT NULL,
#             id_stem_word INTEGER NOT NULL,
#             freq INTEGER NOT NULL,
#             FOREIGN KEY (id_title) REFERENCES wiki_page(id),
#             FOREIGN KEY (id_stem_word) REFERENCES wiki_word(id)
# )")


#dbGetQuery(con, "select count(distinct id) as cnt from wiki_page")

# 
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

#reading categories: mathematics, art and wars
kat_mat <- readRDS("./wszystkietyt.rds")
kat_szt <- readRDS("./wszystkietyt2.rds")
kat_woj <- readRDS("./wszystkietyt3.rds")

#remebering which category belonged to which of the three: maths, art or wars
kategorie <- data.frame(name = stri_trans_tolower(c(kat_mat, kat_szt, kat_woj)), 
                              kat_id = c(rep("mat", length(kat_mat)), 
                                      rep("szt", length(kat_szt)), 
                                      rep("woj", length(kat_woj))))

kat <- dbGetQuery(con, sprintf("select *
                               from wiki_category_name 
                               where name in (%s)", stri_flatten(prepare_string(kategorie$name), collapse = " , ")))
#joining categories with its ids
kat <- left_join(kat, kategorie)
names(kat) <- c("id_category", "name", "kat_id")
kat <- kat[!duplicated(kat),]
# 
# kat <- cbind(kat, kat = c(rep("mat", length(kat_mat)), 
#                           rep("szt", length(kat_szt)), 
#                           rep("woj", length(kat_woj))))
# 
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

# 
# # inserting into table wiki_word_clust_freq
# dbExecQuery(con, sprintf("
#                          insert into wiki_word_clust_freq(id_title, id_stem_word, freq)
#                          select 
#                          a.id_title, b.id_stem_word, sum(a.freq) as freq
#                          from 
#                          (  select *
#                          from wiki_word_freq 
#                          where id_title in (
#                           select id_title
#                           from wiki_category_text
#                           where id_category in (%s) 
#                           )
#                          ) a
#                          join 
#                          wiki_hunspell_clust b
#                          on
#                          a.id_word = b.id_word
#                          group by 
#                          a.id_title
#                          ,b.id_stem_word
#                          ", stri_flatten(kat$id, collapse = " , ")))

# taking out the titles to analyze (names, ids and their categories)
titles <- dbGetQuery(con, 
                     sprintf("
select id, title, id_category 
from wiki_page a 
join 
(
select id_title, id_category
from wiki_category_text
where id_category in (%s)
) b
on a.id = b.id_title", 
stri_flatten(kat$id_category, collapse = " , ")))

names(titles) <- c('id_title', 'title', 'id_category')
titles <- titles[!duplicated(titles$id_title),]
#taking out the table wiki_word_clust_freq
art_word_mat <- dbGetQuery(con, "select * from wiki_word_clust_freq")

# creating a article dictionary and word dictionary
# to make a matrix constisitng of 
# articles as rows and (stem) words as columns
id_art <- sort(unique(art_word_mat$id_title))
dict_art <- data.frame(id_title = id_art, nr_row = 1:length(id_art))
dict_art <- left_join(dict_art, titles)
dict_art <- dict_art[!duplicated(dict_art$id_title),]
# dict_art <- left_join(dict_art, kat)

id_word <- sort(unique(art_word_mat[,2]))
dict_word <- data.frame(id_stem_word = id_word, nr_col = 1:length(id_word))

# taking out stem_words
stem_words <- dbGetQuery(con, 
                         sprintf("select id, word from wiki_word where id in (%s)", 
                                 stri_flatten(id_word, collapse = " , ")))
names(stem_words) <- c("id_stem_word", "word")

# joining ids with names
dict_word <- left_join(dict_word, stem_words)
dict_word <- dict_word[!duplicated(dict_word), ]

#joining everything
art_word_mat <- left_join(left_join(art_word_mat, dict_art ), dict_word)
#art_word_mat <- left_join(art_word_mat, kat[,c(1,3)]))

mattr <- sparseMatrix(art_word_mat$nr_row, art_word_mat$nr_col, x = art_word_mat$freq)


# 
# non_zero_art <- numeric(0)
# for(i in 1:ncol(mattr)){
#   non_zero_art <- c(non_zero_art, sum(mattr[,i]>0))
# }



#joining articles with their categories
dict_art_kat <- left_join(dict_art, kat[,c(1,3)])
dict_art_kat <- dict_art_kat[!duplicated(dict_art_kat$id_title),]
kat_id2 <- 2*(dict_art_kat$kat_id=='mat') + (dict_art_kat$kat_id=='szt') + 3*(dict_art_kat$kat_id=='woj')
dict_art_kat <- cbind(dict_art_kat, kat_id2 = kat_id2)



#clustering articles

#install.packages('skmeans')
library(skmeans)

percentage <- numeric(0)
#method: default
kl1 <- skmeans(mattr, nrow(kat_id2))
outcome1 <- cbind(dict_art_kat, cluster = kl1$cluster)
#percentage of well classified articles
percentage <- c(percentage, sum(outcome1$kat_id2 == outcome1$cluster, na.rm = TRUE)/nrow(outcome1))

#method: pclust
kl2 <- skmeans(mattr, 3, method = 'pclust', control = list(nruns = 20))
outcome2 <- cbind(dict_art_kat, cluster = kl2$cluster)
# saveRDS(outcome2, "./Seminarium/art_clust_res2.rds")
percentage <- c(percentage, sum(outcome2$kat_id2 == outcome2$cluster, na.rm = TRUE)/nrow(outcome2))

#saveRDS(percentage, "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/atr_cl_percentage.rds")

#method: genetic
#very poor!
# kl3 <- skmeans(mattr, 3, method = 'genetic')
# outcome3 <- cbind(dict_art_kat, cluster = kl3$cluster)
# percentage <- c(percentage, sum(outcome3$kat_id2 == outcome3$cluster)/nrow(outcome3))

#method: CLUTO
# kl4 <- skmeans(mattr, 3, method = 'CLUTO')
# outcome4 <- cbind(dict_art_kat, cluster = kl4$cluster)
# percentage <- c(percentage, sum(outcome4$kat_id2 == outcome4$cluster)/nrow(outcome4))
# 
# #method: gmeans
# kl5 <- skmeans(mattr, 3, method = 'gmeans')
# outcome5 <- cbind(dict_art_kat, cluster = kl5$cluster)
# percentage <- c(percentage, sum(outcome5$kat_id2 == outcome5$cluster)/nrow(outcome5))
# 
# #method: kmndirs
# kl6 <- skmeans(mattr, 3, method = 'kmndirs')
# outcome6 <- cbind(dict_art_kat, cluster = kl6$cluster)
# percentage <- c(percentage, sum(outcome6$kat_id2 == outcome6$cluster)/nrow(outcome6))


dbDisconnect(con)








