#!/usr/bin/Rscript --vanilla

library(RSQLite)
library(stringi)
library(compiler)
library(stringdist)
library(dplyr)


source("./R/db_exec.R")
prepare_string <- cmpfun(function(str) {
  stri_paste("'", stri_replace_all_fixed(str, "'", "''"), "'")
})


con <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")
# file.copy("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/words_to_analize.txt", 
#           "/home/natalia/LanguageTool-2.8/words_to_analize2.txt",
#           overwrite = TRUE)


words_to_analize <- readLines("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/words_to_analize.txt")

words <- dbGetQuery(con, "
          select a.word, a.id 
          from wiki_word2 a
          join
          (select distinct id_stem_word
          from wiki_hunspell_clust2) b
          on
          a.id = b.id_stem_word
            ")

dbDisconnect(con)
# saveRDS(words, "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/words_111.rds")

words <- words %>% distinct()

#str_dist <- stringdistmatrix(words_to_analize, words, method = 'lv')


######### word order #########
### one by one ###

# making an order on words such that the first has small distances to the second, the second to the third...
# without repetition of words
# word_order <- function(words_to_analize, words, method = 'lcs', q = 3){
#   print(paste0("word order ", method))
#   # method <- 'lcs'
#   #N <- 100
#   N <- length(words_to_analize)
#   N <- 1000
#   
#   used <- numeric(N)
#   used <- 1
#   #word closest to the first one
#   system.time({
#   used[1] <- which.min(stringdist(words$word, words_to_analize[1], method = method, q = q))
#   })
#   for(i in 2:N){
#     #word closest to the i-th word
#     used[i] <- which.min(stringdist(words$word, words_to_analize[i], method = method, q = q))
#     #     if(i%%100==0)
#     #       print(i)
#   }
#   return(used)
# }


word_order2 <- function(words_to_analize, words, method = 'lcs', q = 3, n = 3000){
  print(paste0("word order ", method))
  # method <- 'lcs'
  #N <- 100
  N <- length(words_to_analize)
  
  used <- numeric(N)
  used <- 1

  x <- unique(c(seq(1, N, by = n), N+1))
  for(i in 1:(length(x)-1)){
    #word closest to the i-th word
    used[x[i]:(x[i+1]-1)] <- apply(
      stringdistmatrix(words$word, words_to_analize[x[i]:(x[i+1]-1)], method = method),
      2, which.min)
    if(i %% 10 == 0)
      print(x[i])
  }
  return(used)
}


####################
# ss <- Sys.time()
# print(system.time({
# used_lcs <- word_order(words_to_analize, words, method = 'lcs')
# })) #114s.
# Sys.time() - ss
# 
print(system.time({
  used_lcs <- word_order2(words_to_analize, words, method = 'lcs', n = 1000)
}))
saveRDS(used_lcs, "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/used_lcs.rds")
used_lcs <- readRDS("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/used_lcs.rds")

print(system.time({
used_dl <- word_order2(words_to_analize, words, method = 'dl')
}))
saveRDS(used_dl, "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/used_dl.rds")
used_dl <- readRDS("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/used_dl.rds")

word_order <- function(words_to_analize, words, method = 'lcs', q = 3, n = 3000){
  print(paste0("word order ", method))
  #method <- 'jaccard'
  #N <- 100
  N <- length(words_to_analize)
  
  used <- numeric(N)
  used <- 1
  #word closest to the first one
  # used[1] <- which.min(stringdist(words$word, words_to_analize[1], method = method, q = q))
  
  
#   for(i in 2:N){
#     #word closest to the i-th word
#     strdst <- stringdist(words$word, words_to_analize[i], method = method, q = q)
#     used[i] <- ifelse(all(strdst == Inf), NA, which.min(strdst))
#     if(i%%10000==0)
#       print(i)
#   }
#   
  
  x <- unique(c(seq(1, N, by = n), N+1))
  for(i in 1:(length(x)-1)){
    #word closest to the i-th word
    used[x[i]:(x[i+1]-1)] <- apply(stringdistmatrix(
      words$word, words_to_analize[x[i]:(x[i+1]-1)], method = method, q = q), 
      2, 
      function(t){
        ifelse(all(t == Inf), NA, which.min(t))
      })
  }
  return(used)
}



hunspell_insert <- function(used, typ){
  print(paste0("insert ", typ))
  con <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")
  
  dbExecQuery(con, sprintf("create table if not exists tmp_hunspell%s (
              word VARCHAR(256) NOT NULL,
              id_stem_word INTEGER NOT NULL,
              FOREIGN KEY (id_stem_word) REFERENCES wiki_word(id)
  )", typ))
  
  to_insert <- sprintf("(%s, %d)", prepare_string(words_to_analize[!is.na(used)]), words$id[used[!is.na(used)]])
  #print(5)
  to_insert <- split(to_insert, rep(1:ceiling(length(to_insert)/500),
                                    length.out=length(to_insert)))
  
  lapply(to_insert, function(to_insert) {
    dbExecQuery(con, sprintf("INSERT into tmp_hunspell%s(word, id_stem_word)
                             values %s", typ, stri_flatten(to_insert, collapse=",")))
  })
  
  
  dbExecQuery(con, sprintf("CREATE TABLE IF NOT EXISTS wiki_hunspell_clust2_%s (
              id_word INTEGER NOT NULL,
              id_stem_word INTEGER NOT NULL,
              FOREIGN KEY (id_word) REFERENCES wiki_word(id),
              FOREIGN KEY (id_stem_word) REFERENCES wiki_word(id)
  );", typ))
  
  dbExecQuery(con, sprintf("INSERT into wiki_hunspell_clust2_%s(id_word, id_stem_word)
              
              select b.id as id_word, a.id_stem_word as id_stem_word
              from tmp_hunspell%s a
              join
              wiki_word b
              on a.word = b.word
              
              union all
              
              select id_word, id_stem_word 
              from wiki_hunspell_clust2
              ", typ, typ))
  
  
  dbExecQuery(con, sprintf("drop table tmp_hunspell%s", typ))
  dbDisconnect(con)
}

# print(system.time({
# used_jaccard <- word_order(words_to_analize, words, method = 'jaccard', q = 4)
# }))
# saveRDS(used_jaccard, "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/used_jaccard.rds")
# #used_jaccard <- readRDS("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/used_jaccard.rds")
# 
# print(system.time({
# used_qgram <- word_order(words_to_analize, words, method = 'qgram', q = 4)
# }))
# saveRDS(used_qgram, "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/used_qgram.rds")
# #used_qgram <- readRDS("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/used_qgram.rds")
# 
# print(system.time({
# used_jw <- word_order2(words_to_analize, words, method = 'jw')
# }))
# saveRDS(used_jw, "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/used_jw.rds")


used_jw <- readRDS("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/used_jw.rds")
used_lcs <- readRDS("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/used_lcs.rds")
used_jaccard <- readRDS("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/used_jaccard.rds")
used_jw <- readRDS("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/used_jw.rds")
used_qgram <- readRDS("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/used_qgram.rds")
used_dl <- readRDS("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/used_dl.rds")


print(system.time({
hunspell_insert(used_lcs, "lcs")
hunspell_insert(used_dl, "dl")
hunspell_insert(used_jaccard, "jaccard")
hunspell_insert(used_qgram, "qgram")
hunspell_insert(used_jw, "jw")
}))



#####################
# sum(used_cosine == used_jaccard, na.rm = TRUE) / 323793
# # [1] 0.9090592
# sum(used_qgram == used_jaccard, na.rm = TRUE) / 323793
# # [1] 0.6516663
# sum(used_qgram == used_cosine, na.rm = TRUE) / 323793
# [1] 0.7301177

# we're getting rid of used_cosine, as it is very similar to used_jaccard, 
# and more similar to used_qgram than used_qgram to used_jaccard
#####################


# used <- used_jaccard
# used <- used_qgram
#used <- used_cosine


# n <- 10
# 
# n <- n+10
# words_to_analize[1:10+n]
# words[used][1:10+n]
# 
# ss <- sample(1:i, 10)
# words_to_analize[ss]
# words[used[ss]] #lv
# words[used2[ss]] #lcs

######################################################






