#! /usr/bin/Rscript


library(RSQLite)
library(dplyr)

source("./R/db_exec.R")




wiki_word_clust3_freq <- function(typ){
  con <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")
  
  message(typ)
  # Create table
  
  dbExecQuery(con, sprintf('drop table if exists tmp_word_clust3%s_freq', typ))
  
  dbExecQuery(con, sprintf("create table if not exists tmp_word_clust3%s_freq (
                           id_title INTEGER NOT NULL,
                           id_stem_word INTEGER NOT NULL,
                           id_orig_stem_word INTEGER NOT NULL,
                           freq INTEGER NOT NULL,
                           FOREIGN KEY (id_title) REFERENCES wiki_category_text_after_reduction(id),
                           FOREIGN KEY (id_orig_stem_word) REFERENCES wiki_word(id)
  )", typ))
  
  
  
  message('Insert 1...')
  dbExecQuery(con, sprintf('insert into tmp_word_clust3%s_freq(id_title, id_stem_word, id_orig_stem_word, freq)
                           
                           select a.id, b.id_stem_word, b.id_orig_stem_word, b.freq
                           from
                           wiki_category_text_after_reduction a
                           join 
                           wiki_word_clust2%s_freq  b
                           on a.id_title = b.id_title
                           ', typ, typ))
  
  
  
  dbExecQuery(con, sprintf('drop table if exists tmp_stem_word_reorder%s', typ))
  
  
  dbExecQuery(con, sprintf('create table if not exists tmp_stem_word_reorder%s (
                           id INTEGER PRIMARY KEY AUTOINCREMENT,
                           id_orig_stem_word INTEGER NOT NULL,
                           FOREIGN KEY (id_orig_stem_word) REFERENCES wiki_word(id)
  )', typ))

  message('Insert 2...')
  dbExecQuery(con, sprintf('insert into tmp_stem_word_reorder%s(id_orig_stem_word)
                           
                           select distinct id_orig_stem_word
                           from
                           tmp_word_clust3%s_freq
                           order by id_orig_stem_word
                           ', typ, typ))
  
  #creating table with id_tittle, id_stem_word and its frequency (as a group)
  dbExecQuery(con, sprintf("create table if not exists wiki_word_clust3%s_freq (
                           id_title INTEGER NOT NULL,
                           id_stem_word INTEGER NOT NULL,
                           id_orig_stem_word INTEGER NOT NULL,
                           freq INTEGER NOT NULL,
                           FOREIGN KEY (id_title) REFERENCES wiki_category_text_after_reduction(id),
                           FOREIGN KEY (id_orig_stem_word) REFERENCES wiki_word(id)
  )", typ))

  
  message("Insert into _freq ...")
  # # inserting into table wiki_word_clust_freq
  dbExecQuery(con, sprintf("
                           insert into wiki_word_clust3%s_freq(id_title, id_stem_word, id_orig_stem_word, freq)
                           
                           select 
                           d.id_title, a.id, d.id_orig_stem_word, d.freq
                           
                           from 
                           tmp_stem_word_reorder%s a
                           
                           join 
                           
                           tmp_word_clust3%s_freq d

                           on
                           a.id_orig_stem_word = d.id_orig_stem_word
                           
                           group by 
                           d.id_title
                           ,a.id
                           ",
                           typ, typ, typ))
  
  dbExecQuery(con, sprintf('drop table if exists tmp_stem_word_reorder%s', typ))
  dbExecQuery(con, sprintf('drop table if exists tmp_word_clust3%s_freq', typ))
  dbDisconnect(con)
  
}



#wiki_word_clust3_freq('')

#wiki_word_clust3_freq('_lcs')
#wiki_word_clust3_freq('_dl')
#wiki_word_clust3_freq('_jaccard')
#wiki_word_clust3_freq('_qgram')

#wiki_word_clust3_freq('_red_lcs')
#swiki_word_clust3_freq('_red_dl')
wiki_word_clust3_freq('_red_jaccard')
wiki_word_clust3_freq('_red_qgram')

wiki_word_clust3_freq('_red_lcs_lcs')
wiki_word_clust3_freq('_red_dl_dl')
wiki_word_clust3_freq('_red_jaccard_jaccard')
wiki_word_clust3_freq('_red_qgram_qgram')


#dbDisconnect(con)
#dbDisconnect(con1)
