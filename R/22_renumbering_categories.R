
library(rvest)
library(dplyr)
library(stringi)
library(Hmisc)
library(RSQLite)
library(compiler)


prepare_string <- cmpfun(function(str) {
  stri_paste("'", stri_replace_all_fixed(str, "'", "''"), "'")
})

source("./R/db_exec.R")


load("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/categories/kategorie20151123_ost.rda")


con <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")

dbExecQuery(con, "DROP TABLE IF EXISTS wiki_category_after_reduction2")

dbExecQuery(con, "CREATE TABLE IF NOT EXISTS wiki_category_after_reduction2 (
  id_new INTEGER NOT NULL,
  name_old VARCHAR(256) NOT NULL,
  id_old INTEGER NOT NULL,
  name_new VARCHAR(256) NOT NULL
);")



to_insert <- sprintf("(%d, %s, %d, %s)", 
                     kategorie$id_new2,
                     prepare_string(kategorie$name_new), 
                     kategorie$id_new, 
                     prepare_string(kategorie$nowa_kat2))
to_insert <- split(to_insert, 
                   rep(1:ceiling(length(to_insert)/500), 
                       length.out=length(to_insert)))          

lapply(to_insert, function(to_insert) {
  dbExecQuery(con, sprintf("INSERT into wiki_category_after_reduction2(id_new, name_old, id_old, name_new)
                    values %s", stri_flatten(to_insert, collapse=",")))
})


dbGetQuery(con, "select * from wiki_category_after_reduction2 limit 10")
dbGetQuery(con, "select * from wiki_category_text_after_reduction limit 10")
dbGetQuery(con, "select count(distinct id_title) from wiki_category_text_after_reduction")
dbGetQuery(con, "select count(distinct id) from wiki_category_text_after_reduction")

dbDisconnect(con)
con1 <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/partitions/czesc1/wiki_dl.sqlite")

dbGetQuery(con1, "select count(distinct id_title) from art_word_freq_dl")

dbDisconnect(con1)

# TO DO:
# polaczyc teksty z kategoriami 
# i poprawic w kazdej z czesci, bo jest zle! (duplikaty)




