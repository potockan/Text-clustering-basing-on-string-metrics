#!/usr/bin/Rscript --vanilla

library(RSQLite)
library(compiler)
library(stringi)


source("./R/db_exec.R")
prepare_string <- cmpfun(function(str) {
  stri_paste("'", stri_replace_all_fixed(str, "'", "''"), "'")
})

wiki_word_clust2_freq <- function(typ){
  con <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")
  
  message(typ)
  # Create table
  dbExecQuery(con, sprintf('drop table if exists tmp_stem_word_reorder%s', typ))
  
  
  dbExecQuery(con, sprintf('create table if not exists tmp_stem_word_reorder%s (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              id_stem_word INTEGER NOT NULL,
              FOREIGN KEY (id_stem_word) REFERENCES wiki_word(id)
  )', typ))

  message('Insert...')
  dbExecQuery(con, sprintf('insert into tmp_stem_word_reorder%s(id_stem_word)
                           
                           select distinct id_stem_word
                           from wiki_hunspell_clust2%s
                           order by id_stem_word
                           ', typ, typ))
  
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
                           
                           tmp_stem_word_reorder%s c
                           
                           on
                           b.id_stem_word = c.id_stem_word
                           
                           ) d
                           on
                           a.id_word = d.id_word
                           
                           group by 
                           a.id_title
                           ,d.id_stem_word
                           ",
                           typ, typ, typ))
  
  dbExecQuery(con, sprintf('drop table if exists tmp_stem_word_reorder%s', typ))
  dbDisconnect(con)
  
}



# wiki_word_clust2_freq('')

print(system.time({
wiki_word_clust2_freq('_lcs')
}))
print(system.time({
wiki_word_clust2_freq('_dl')
}))
print(system.time({
wiki_word_clust2_freq('_jw')
}))
print(system.time({
wiki_word_clust2_freq('_jaccard')
}))
print(system.time({
wiki_word_clust2_freq('_qgram')
}))

print(system.time({
wiki_word_clust2_freq('_red_lcs')
}))
print(system.time({
wiki_word_clust2_freq('_red_dl')
}))
print(system.time({
wiki_word_clust2_freq('_red_jw')
}))
print(system.time({
wiki_word_clust2_freq('_red_jaccard')
}))
print(system.time({
wiki_word_clust2_freq('_red_qgram')
}))

print(system.time({
wiki_word_clust2_freq('_red_lcs_lcs')
}))
print(system.time({
wiki_word_clust2_freq('_red_dl_dl')
}))
print(system.time({
wiki_word_clust2_freq('_red_jw_jw')
}))
print(system.time({
wiki_word_clust2_freq('_red_jaccard_jaccard')
}))
print(system.time({
wiki_word_clust2_freq('_red_qgram_qgram')
}))


# tabele <- c('', '_lcs', '_dl', '_jaccard', '_qgram', 
#             '_red_lcs', '_red_dl', '_red_jaccard', '_red_qgram', 
#             '_red_lcs_lcs', '_red_dl_dl', '_red_jaccard_jaccard', '_red_qgram_qgram')
# 
# library('doSNOW')
# library('parallel')
# 
# #liczba watkow
# threads <- 6
# 
# #rejestrujemy liczbe watkow
# cl <- makeCluster(threads, outfile="")
# registerDoSNOW(cl)
# 
# message("Loading packages on threads...")
# #kazdemu watkowi wczytujemy pakiety
# 
# clusterEvalQ(cl,library('RSQLite'))
# clusterEvalQ(cl,library('compiler'))
# clusterEvalQ(cl,library('stringi'))
# 
# 
# #wywolujemy funkcje dla wszystkich typow
# foreach(i=1:length(tabele)) %dopar% {
#   print(i)
#   wiki_word_clust2_freq(tabele[i])
# }
# 
# 
# 
# #zatrzymujemy watki
# stopCluster(cl)

########################
####### cheking ########
########################
# con <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")

# dbGetQuery(con, 'select * from wiki_word_clust2_red_jaccard_jaccard_freq limit 10')

# id_title id_stem_word id_orig_stem_word freq
# 1         1          702             35688   10
# 2         1         1049             50593    1
# 3         1         1371             64993    1
# 4         1         2505            111563    6
# 5         1         5768            256423    1
# 6         1         7975            361055    1
# 7         1         8382            377534    1
# 8         1        11632            528899    1
# 9         1        11648            529517    2
# 10        1        11902            539051    1

# words <- dbGetQuery(con, 'select * from wiki_hunspell_clust2_red_jaccard_jaccard where id_stem_word = 35688')

# id_word id_stem_word
# 1    35723        35688
# 2    35687        35688
# 3    35688        35688
# 4    35689        35688
# 5    35690        35688
# 6    35691        35688
# 7    35692        35688
# 8    35693        35688
# 9    35694        35688
# 10   35722        35688

# id_words <- words$id_word

# dbGetQuery(con, sprintf('select * from wiki_word_freq where id_word in (%s) and id_title = 1', stri_flatten(id_words, collapse = ', ')))

# id_title id_word freq
# 1        1   35688    5
# 2        1   35722    3
# 3        1   35693    1
# 4        1   35694    1

# dbDisconnect(con)
########################


