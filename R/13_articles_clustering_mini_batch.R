
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
set.seed(5678)
kat_mat <- readRDS("./wszystkietyt.rds")
kat_szt <- readRDS("./wszystkietyt2.rds") %>% sample(length(kat_mat))
kat_woj <- readRDS("./wszystkietyt3.rds") %>% sample(length(kat_mat))




#remebering which category belonged to which of the three: maths, art or wars
# kategorie <- data.frame(name = stri_trans_tolower(c(kat_mat, kat_szt, kat_woj)), 
#                         kat_id = c(rep("mat", length(kat_mat)), 
#                                    rep("szt", length(kat_szt)), 
#                                    rep("woj", length(kat_woj))))

kategorie <- data.frame(name = stri_trans_tolower(c(kat_mat, kat_szt, kat_woj)), 
                        kat_id = c(kat_mat, kat_szt, kat_woj))

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
# art_word_mat <- dbGetQuery(con, "select * from wiki_word_clust_freq")
art_word_mat <- dbGetQuery(con, sprintf("select * from wiki_word_clust_freq where id_title in (%s)",
                                             stri_flatten(titles$id_title, collapse = ", ")))

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


#joining articles with their categories
id_kat <- sort(unique(art_word_mat$id_category))
dict_art_kat <- left_join(dict_art, kat[,c(1,3)])
dict_art_kat <- dict_art_kat[!duplicated(dict_art_kat$id_title),]
#kat_id2 <- 2*(dict_art_kat$kat_id=='mat') + (dict_art_kat$kat_id=='szt') + 3*(dict_art_kat$kat_id=='woj')
kat_id2 <- data.frame(id_category = id_kat, kat_id2 = 1:length(id_kat))
dict_art_kat <- left_join(dict_art_kat, kat_id2)

mattr <- sparseMatrix(art_word_mat$nr_row, art_word_mat$nr_col, x = art_word_mat$freq)
write.csv(select(art_word_mat, freq, nr_row, nr_col), "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/sparse_matrix.csv", row.names = FALSE)
write.csv(select(dict_art_kat, kat_id2), "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/labels.csv", row.names = FALSE)

# 
# non_zero_art <- numeric(0)
# for(i in 1:ncol(mattr)){
#   non_zero_art <- c(non_zero_art, sum(mattr[,i]>0))
# }


dbDisconnect(con)


###################################
# mini-batch k-Means (from "Web-Scale K-means Clustering")
czas <- system.time({

set.seed(1234)
k <- 3
nb <- 100
it_no <- 10
centr <- mattr[sample(1:nrow(mattr), k), ]
d <- numeric(nrow(mattr))

v <- numeric(k)
for(i in 1:it_no){
  if(i%%10 == 0) print(i)
  M <- sample(1:nrow(mattr), nb)
  for(x in 1:length(M)){
    d1 <- M[x]
    d[d1] <- which.min(apply(centr, 1, function(y) sqrt(sum((y - mattr[d1,]) ^ 2))))
  }
  for(x in 1:length(M)){
    d1 <- d[M[x]]
    c1 <- centr[d1,]
    v[d1] <- v[d1] + 1
    eta <- 1/v[d1]
    centr[d1,] <- (1-eta)*c1 + eta*mattr[M[x],]
  }
}
})

#32min 100x100

# #100x1000
# user    system   elapsed 
# 20552.828     2.416 20539.318 
outcome1 <- cbind(dict_art_kat, cluster = d)
outcome1 <- outcome1[outcome1$cluster>0,]
#percentage of well classified articles
percentage <- c(percentage, 
                sum(outcome1$kat_id2 == outcome1$cluster, na.rm = TRUE)/nrow(outcome1))

saveRDS(d, "/dragon/Text-clustering-basing-on-string-metrics//Data/RObjects/d_100x1000.rds")
saveRDS(centr, "/dragon/Text-clustering-basing-on-string-metrics//Data/RObjects/centr_100x1000.rds")
saveRDS(v, "/dragon/Text-clustering-basing-on-string-metrics//Data/RObjects/v_100x1000.rds")











