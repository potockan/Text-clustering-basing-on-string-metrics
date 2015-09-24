#!/usr/bin/Rscript --vanilla

library(RSQLite)
library(compiler)
library(stringi)


source("./R/db_exec.R")
prepare_string <- cmpfun(function(str) {
  stri_paste("'", stri_replace_all_fixed(str, "'", "''"), "'")
})

con <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")

wiki_word_clust2_freq <- function(typ){
  message(typ)
  # Create table
  dbExecQuery(con, 'drop table if exists wiki_stem_word_reorder')
  
  
  dbExecQuery(con, 'create table if not exists tmp_stem_word_reorder (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              id_stem_word INTEGER NOT NULL,
              FOREIGN KEY (id_stem_word) REFERENCES wiki_word(id)
  )')

  message('Insert...')
  dbExecQuery(con, sprintf('insert into tmp_stem_word_reorder(id_stem_word)
                           
                           select distinct id_stem_word
                           from wiki_hunspell_clust2%s
                           order by id_stem_word
                           ', typ))
  
  #creating table with id_tittle, id_stem_word and its frequency (as a group)
  dbExecQuery(con, sprintf("create table if not exists wiki_word_clust2%s_freq (
                           id_title INTEGER NOT NULL,
                           id_stem_word INTEGER NOT NULL,
                           id_orig_stem_word INTEGER NOT NULL,
                           freq INTEGER NOT NULL,
                           FOREIGN KEY (id_title) REFERENCES wiki_page(id),
                           FOREIGN KEY (id_orig_stem_word) REFERENCES wiki_word(id)
  )", typ))

  
  message("Insert into _freq ...")
  # # inserting into table wiki_word_clust_freq
  dbExecQuery(con, sprintf("
                           insert into wiki_word_clust2%s_freq(id_title, id_stem_word, id_orig_stem_word, freq)
                           
                           select 
                           a.id_title, d.id_stem_word, d.id_orig_stem_word, sum(a.freq) as freq
                           
                           from 
                           wiki_word_freq a
                           
                           join 
                           
                           (
                           select 
                           c.id as id_stem_word, b.id_stem_word as id_orig_stem_word, b.id_word
                           
                           from
                           wiki_hunspell_clust2%s b
                           
                           join
                           
                           tmp_stem_word_reorder c
                           
                           on
                           b.id_stem_word = c.id_stem_word
                           
                           ) d
                           on
                           a.id_word = d.id_word
                           
                           group by 
                           a.id_title
                           ,d.id_stem_word
                           ",
                           typ, typ))
  
  dbExecQuery('drop table if exists wiki_stem_word_reorder')
  
}

wiki_word_clust2_freq('')

wiki_word_clust2_freq('_lcs')
wiki_word_clust2_freq('_dl')
wiki_word_clust2_freq('_jaccard')
wiki_word_clust2_freq('_qgram')

wiki_word_clust2_freq('_red_lcs')
wiki_word_clust2_freq('_red_dl')
wiki_word_clust2_freq('_red_jaccard')
wiki_word_clust2_freq('_red_qgram')

wiki_word_clust2_freq('_red_lcs_lcs')
wiki_word_clust2_freq('_red_dl_dl')
wiki_word_clust2_freq('_red_jaccard_jaccard')
wiki_word_clust2_freq('_red_qgram_qgram')

dbDisconnect(con)
