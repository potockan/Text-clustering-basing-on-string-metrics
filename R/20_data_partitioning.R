#! /usr/bin/Rscript

library(RSQLite)
library(dplyr)
library(stringi)

source("./R/db_exec.R")


# for(i in 1:13){
#   system2("mkdir", 
#         sprintf("/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/partitions/czesc%d",i))
# }




partitions <- function(typ, art){

  message(typ)
  ciag <- ceiling(seq(1, length(art), length.out = 14))
  
  
  con <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")
  
  for(i in 1:13){
    message("Connecting to db ", i)
    con1 <- dbConnect(SQLite(), dbname = 
                        sprintf("/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/partitions/czesc%d/wiki%s.sqlite", i, typ))
    
    message("Taking the data from db")
    dane <- dbGetQuery(con, sprintf("select id_title, id_stem_word, freq 
                       from wiki_word_clust3%s_freq
                       where id_title in (%s)", typ, stri_flatten(art[ciag[i]:(ciag[i+1]-1)], collapse = ", ")))
  
    dbExecQuery(con1, sprintf("create table if not exists art_word_freq%s (
                             id_title INTEGER NOT NULL,
                             id_stem_word INTEGER NOT NULL,
                             freq INTEGER NOT NULL
    );", typ))
    
    message("To insert...")
    to_insert <- sprintf("(%d, %d, %d)", 
                         dane$id_title,
                         dane$id_stem_word,
                         dane$freq)
    to_insert <- split(to_insert, 
                       rep(1:ceiling(length(to_insert)/500), 
                           length.out=length(to_insert)))          
    
    message("Insert")
    lapply(to_insert, function(to_insert) {
      dbExecQuery(con1, sprintf("INSERT into art_word_freq%s(id_title, id_stem_word, freq)
                      values %s", typ, stri_flatten(to_insert, collapse=", ")))
    })
    dbDisconnect(con1)
  }
  dbDisconnect(con)
}

# 
# category_partitions <- function(art){
#   
#   ciag <- ceiling(seq(1, length(art), length.out = 14))
#   
#   
#   con <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")
#   
#   for(i in 1:13){
#     message("Connecting to db ", i)
#     con1 <- dbConnect(SQLite(), dbname = 
#                         sprintf("/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/partitions/czesc%d/wiki_art_cat.sqlite", i))
#     
#     message("Taking the data from db")
#     dane <- dbGetQuery(con, sprintf("select id_title, id_new_cat 
#                        from wiki_category_text_after_reduction
#                        where id_title in (%s)", stri_flatten(art[ciag[i]:(ciag[i+1]-1)], collapse = ", ")))
#     
#     dbExecQuery(con1, "create table if not exists cat_art (
#                              id_title INTEGER NOT NULL,
#                              id_cat
#     );")
#     
#     message("To insert...")
#     to_insert <- sprintf("(%d, %d)", 
#                          dane$id_title,
#                          dane$id_new_cat)
#     to_insert <- split(to_insert, 
#                        rep(1:ceiling(length(to_insert)/500), 
#                            length.out=length(to_insert)))          
#     
#     message("Insert")
#     lapply(to_insert, function(to_insert) {
#       dbExecQuery(con1, sprintf("INSERT into cat_art(id_title, id_cat)
#                       values %s", stri_flatten(to_insert, collapse=", ")))
#     })
#     dbDisconnect(con1)
#   }
#   dbDisconnect(con)
#   
# }
# 



set.seed(82823)

con <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")

title_num <- dbGetQuery(con, "select id_title, id from wiki_category_text_after_reduction")
dbDisconnect(con)

#title_num <- title_num %>% bind_cols(data.frame(id_new_title = 1:nrow(title_num)))

title_shuffle <- sample(title_num$id, nrow(title_num))

#category_partitions(title_shuffle)

#partitions('', title_shuffle)

#partitions('_lcs', title_shuffle)
#partitions('_dl', title_shuffle)
#partitions('_jaccard', title_shuffle)
#partitions('_qgram', title_shuffle)

#partitions('_red_lcs', title_shuffle)
partitions('_red_dl', title_shuffle)
partitions('_red_jaccard', title_shuffle)
partitions('_red_qgram', title_shuffle)

partitions('_red_lcs_lcs', title_shuffle)
partitions('_red_dl_dl', title_shuffle)
partitions('_red_jaccard_jaccard', title_shuffle)
partitions('_red_qgram_qgram', title_shuffle)


# > title_shuffle[1:10]
# [1]  359038  419564 1708533  138219 1195074 1542630  316539   32556  461362  934010
