#!/usr/bin/Rscript --vanilla

#install.packages("RSQLite")
library(RSQLite)
library(stringdist)
library(compiler)
library(dplyr)
library(stringi)

source("./R/db_exec.R")
prepare_string <- cmpfun(function(str) {
  stri_paste("'", stri_replace_all_fixed(str, "'", "''"), "'")
})
### Worked text database ###

con <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")


read_wiki_hunspell_clust2 <- function(table){
  dbGetQuery(con, sprintf("select a.id_stem_word, a.freq, b.word
                      from
                      
                      (select id_stem_word, count(id_word) as freq
                      from %s
                      group by id_stem_word) a
                      
                      join
                      
                      wiki_word b
  
                      on a.id_stem_word = b.id
                      ", table))
}
##############
# repr <- dbGetQuery(con, "select a.id_stem_word, a.id_word, b.word
#                     from
#                     
#                     (select id_stem_word, id_word
#                     from wiki_hunspell_clust2_red_jaccard_jaccard
#                     where id_stem_word = 334521) a
#                     
#                     join
#                     
#                     wiki_word b
# 
#                     on a.id_word = b.id
#                     ")


# wiki_hunspell_clust2
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 1.000   1.000   2.000   3.995   5.000  89.000 

# wiki_hunspell_clust2_lcs
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 1.000   2.000   4.000   5.778   8.000 217.000 

# wiki_hunspell_clust2_dl
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 1.000   2.000   4.000   5.778   8.000 217.000 

# wiki_hunspell_clust2_jaccard
# Min.   1st Qu.    Median      Mean   3rd Qu.      Max. 
# 1.000     2.000     4.000     5.727     8.000 18484.000

# wiki_hunspell_clust2_qgram
# Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
# 1.00     1.00     3.00     5.73     7.00 40701.00 

# wiki_hunspell_clust2_cosine
# Min.   1st Qu.    Median      Mean   3rd Qu.      Max. 
# 1.000     2.000     4.000     5.727     8.000 18500.000 

##############


word_clustering <- function(slowa, method = 'lcs', q = 4){
  # dividing words into those that are being redirected to other clusters (slowa)
  # and those which stay (slowa2)
  # we get rid of words that are shorter than 4 characters 
  # to avoid strange situations where we have the clustes 'aa' which has 500 words
  slowa <- cbind(slowa, nowy_stem_id = slowa$id_stem_word, orig_word = slowa$word)
  slowa2 <- slowa[slowa$freq > 5,]
  slowa2 <- slowa2[stri_length(slowa2$word) > 3, ]
  slowa <- slowa[slowa$freq <= 5,]
  
  # method <- "lcs"
  # method <- "dl"
  # method <- "jaccard"
  # method <- "qgram"
  for(i in 1:nrow(slowa)){
    odl <- stringdist(slowa$word[i], slowa2$word, method = method, q = q)
    if(all(odl == Inf)){
      slowa$word[i] <- NA
      slowa$nowy_stem_id[i] <- NA
    }else{
      odl_min <- which(odl == min(odl))
      indx <- which.max(slowa2$freq[odl_min])
      slowa$word[i] <- slowa2$word[odl_min[indx]]
      slowa$nowy_stem_id[i] <- slowa2$id_stem_word[odl_min[indx]]
    }
  }
  slowa <- bind_rows(slowa, slowa2)
  return(slowa)
}

# add to the clusters those clusters that have little elements i.e. 5
slowa <- read_wiki_hunspell_clust2("wiki_hunspell_clust2")

slowa_lcs <- word_clustering(slowa, method = 'lcs')
saveRDS(slowa_lcs, "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/slowa_lcs.rds")

slowa_dl <- word_clustering(slowa, method = 'dl')
saveRDS(slowa_dl, "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/slowa_dl.rds")

slowa_jaccard <- word_clustering(slowa, method = 'jaccard', q = 4)
saveRDS(slowa_jaccard, "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/slowa_jaccard.rds")

slowa_qgram <- word_clustering(slowa, method = 'qgram', q = 4)
saveRDS(slowa_qgram, "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/slowa_qgram.rds")



# add to the clusters those clusters that have little elements i.e. 5
slowa <- read_wiki_hunspell_clust2("wiki_hunspell_clust2_lcs")
slowa_lcs_lcs <- word_clustering(slowa, method = 'lcs')
saveRDS(slowa_lcs_lcs, "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/slowa_lcs_lcs.rds")


slowa <- read_wiki_hunspell_clust2("wiki_hunspell_clust2_dl")
slowa_dl_dl <- word_clustering(slowa, method = 'dl')
saveRDS(slowa_dl_dl, "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/slowa_dl_dl.rds")


slowa <- read_wiki_hunspell_clust2("wiki_hunspell_clust2_jaccard")
slowa_jaccard_jaccard <- word_clustering(slowa, method = 'jaccard', q = 4)
saveRDS(slowa_jaccard_jaccard, "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/slowa_jaccard_jaccard.rds")


slowa <- read_wiki_hunspell_clust2("wiki_hunspell_clust2_qgram")
slowa_qgram_qgram <- word_clustering(slowa, method = 'qgram', q = 4)
saveRDS(slowa_qgram_qgram, "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/slowa_qgram_qgram.rds")


##################
# inserting into db

insert_into_db <- function(typ, typ2){
  dbExecQuery(con, "create table if not exists tmp_hunspell (
            id_stem_word INTEGER NOT NULL,
            nowy_stem_id INTEGER NOT NULL,
            FOREIGN KEY (id_stem_word) REFERENCES wiki_word(id)
)")
  
  ktore <- which(!is.na(eval(parse(text = paste0('slowa_',typ)))$nowy_stem_id))
  
  to_insert <- sprintf("(%d, %d)", eval(parse(text = paste0('slowa_',typ)))$id_stem_word[ktore], eval(parse(text = paste0('slowa_',typ)))$nowy_stem_id[ktore])
  #print(5)
  to_insert <- split(to_insert, rep(1:ceiling(length(to_insert)/500),
                                    length.out=length(to_insert)))
  
  lapply(to_insert, function(to_insert) {
    dbExecQuery(con, sprintf("INSERT into tmp_hunspell(id_stem_word, nowy_stem_id)
                           values %s", stri_flatten(to_insert, collapse=",")))
  })
  
  table <- paste0('wiki_hunspell_clust2_red_', typ)
  
  dbExecQuery(con, sprintf("CREATE TABLE IF NOT EXISTS %s (
              id_word INTEGER NOT NULL,
              id_stem_word INTEGER NOT NULL,
              FOREIGN KEY (id_word) REFERENCES wiki_word(id),
              FOREIGN KEY (id_stem_word) REFERENCES wiki_word(id)
  );", table))
  
  dbExecQuery(con, sprintf("INSERT into %s(id_word, id_stem_word)

              select b.id_word as id_word, a.nowy_stem_id as id_stem_word
              from tmp_hunspell a
              join
              %s b
              on a.id_stem_word = b.id_stem_word
              ", table, paste0('wiki_hunspell_clust2', typ2)))
  
  
  dbExecQuery(con, "drop table tmp_hunspell")
}



##################

insert_into_db('lcs', '')
insert_into_db('dl', '')
insert_into_db('jaccard', '')
insert_into_db('qgram', '')
insert_into_db('lcs_lcs', '_lcs')
insert_into_db('dl_dl', '_dl')
insert_into_db('jaccard_jaccard', '_jaccard')
insert_into_db('qgram_qgram', '_qgram')

#####################
#### statisctics ####
#####################

dbListTables(con)
dbGetQuery(con, 'select count(distinct id_stem_word) from wiki_hunspell_clust2')
# 186958

dbGetQuery(con, 'select count(distinct id_stem_word) from wiki_hunspell_clust2_lcs')
# 186958
dbGetQuery(con, 'select count(distinct id_stem_word) from wiki_hunspell_clust2_dl')
# 186958
dbGetQuery(con, 'select count(distinct id_stem_word) from wiki_hunspell_clust2_jaccard')
# 186958
dbGetQuery(con, 'select count(distinct id_stem_word) from wiki_hunspell_clust2_qgram')
# 186958

dbGetQuery(con, 'select count(distinct id_stem_word) from wiki_hunspell_clust2_red_lcs')
# 43919
dbGetQuery(con, 'select count(distinct id_stem_word) from wiki_hunspell_clust2_red_dl')
# 43919
dbGetQuery(con, 'select count(distinct id_stem_word) from wiki_hunspell_clust2_red_jaccard')
# 43919
dbGetQuery(con, 'select count(distinct id_stem_word) from wiki_hunspell_clust2_red_qgram')
# 43919

dbGetQuery(con, 'select count(distinct id_stem_word) from wiki_hunspell_clust2_red_lcs_lcs')
# 65350
dbGetQuery(con, 'select count(distinct id_stem_word) from wiki_hunspell_clust2_red_dl_dl')
# 66378
dbGetQuery(con, 'select count(distinct id_stem_word) from wiki_hunspell_clust2_red_jaccard_jaccard')
# 69570
dbGetQuery(con, 'select count(distinct id_stem_word) from wiki_hunspell_clust2_red_qgram_qgram')
# 62434


dbGetQuery(con, 'select count(1) from wiki_hunspell_clust2')
# 746957

dbGetQuery(con, 'select count(1) from wiki_hunspell_clust2_lcs')
# 1080260
dbGetQuery(con, 'select count(1) from wiki_hunspell_clust2_dl')
# 1080260
dbGetQuery(con, 'select count(1) from wiki_hunspell_clust2_jaccard')
# 1070750
dbGetQuery(con, 'select count(1) from wiki_hunspell_clust2_qgram')
# 1070750

dbGetQuery(con, 'select count(1) from wiki_hunspell_clust2_red_lcs')
# 743053
dbGetQuery(con, 'select count(1) from wiki_hunspell_clust2_red_dl')
# 743053
dbGetQuery(con, 'select count(1) from wiki_hunspell_clust2_red_jaccard')
# 739338
dbGetQuery(con, 'select count(1) from wiki_hunspell_clust2_red_qgram')
# 739338

dbGetQuery(con, 'select count(1) from wiki_hunspell_clust2_red_lcs_lcs')
# 1037393
dbGetQuery(con, 'select count(1) from wiki_hunspell_clust2_red_dl_dl')
# 1060474
dbGetQuery(con, 'select count(1) from wiki_hunspell_clust2_red_jaccard_jaccard')
# 1063131
dbGetQuery(con, 'select count(1) from wiki_hunspell_clust2_red_qgram_qgram')
# 1063131
#######

dbDisconnect(con)

# # saveRDS(aa, "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/time_lcs.rds")
aa <- readRDS("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/time_lcs.rds")
unique(slowa$nowy_stem_id) %>% length()
slowa3 <- slowa %>% group_by(nowy_stem_id, word) %>% summarise(freq = sum(freq))
slowa3$freq %>% summary()
sum(slowa$id_stem_word != slowa$nowy_stem_id)
