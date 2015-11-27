#! /usr/bin/Rscript

library(RSQLite)
library(dplyr)
library(stringi)

source("./R/db_exec.R")


# for(i in 1:13){
#   system2("mkdir", 
#         sprintf("/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/partitions/czesc%d",i))
# }




partitions <- function(typ){

  print(typ)
  
  for(i in 1:13){
    message("Connecting to db ", i)
    con1 <- dbConnect(SQLite(), dbname = 
                        sprintf("/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/partitions/czesc%d/wiki_art_cat.sqlite", i))
    
    con <- dbConnect(SQLite(), dbname = 
                        sprintf("/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/partitions/czesc%d/wiki%s.sqlite", i, typ))
    
    message("Taking the data from db")
    dane <- dbGetQuery(con, sprintf("select distinct id_title
                                    from art_word_freq%s
                                    ", typ))
    
    
    
    dbExecQuery(con1, sprintf("create table if not exists cat_art2%s (
                id_title INTEGER NOT NULL,
                id_cat
    );", typ))
    
    
      dbExecQuery(con1, sprintf("INSERT into cat_art2%s(id_title, id_cat)
                                
                                select id_title, id_cat 
                                from cat_art
                                where id_title in (%s)", typ, 
                                stri_flatten(unique(dane$id_title), collapse=", ")))
    
    
    
    dbDisconnect(con1)
    dbDisconnect(con)
  }
}

partitions('')

partitions('_lcs')
partitions('_dl')
partitions('_jaccard')
partitions('_qgram')

partitions('_red_lcs')
partitions('_red_dl')
partitions('_red_jaccard')
partitions('_red_qgram')

partitions('_red_lcs_lcs')
partitions('_red_dl_dl')
partitions('_red_jaccard_jaccard')
partitions('_red_qgram_qgram')


