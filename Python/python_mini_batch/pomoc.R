library(RSQLite)
library(dplyr)
library(stringi)


source("./R/db_exec.R")

nazwy <- c('_', '_lcs', '_dl','_jaccard','_qgram',
           '_red_lcs','_red_dl','_red_jaccard','_red_qgram',
           '_red_lcs_lcs','_red_dl_dl','_red_jaccard_jaccard','_red_qgram_qgram')
for(n in nazwy){
  print(n)
  i <- 1
  if(n == "_")
    typ <- ""
  else
    typ <- n
  con1 <- dbConnect(SQLite(), dbname = 
                      sprintf("/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/partitions/czesc%d/wiki%s.sqlite", i, typ))
  for(j in 2){
    con <- dbConnect(SQLite(), dbname = 
                       sprintf("/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/partitions/czesc%d/wiki%s.sqlite", j, typ))
    
    
    
    dane <- dbGetQuery(con, sprintf("select id_title, id_stem_word, freq 
                       from art_word_freq%s
                       ", typ))
    
    
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
    dbDisconnect(con)
    dbDisconnect(con1)
  }
}





nazwy <- c('', '_lcs', '_dl','_jaccard','_qgram',
           '_red_lcs','_red_dl','_red_jaccard','_red_qgram',
           '_red_lcs_lcs','_red_dl_dl','_red_jaccard_jaccard','_red_qgram_qgram')

aa <- list()
for(n in 1:length(nazwy)){
  i <- 1
  typ <- nazwy[n]
  con1 <- dbConnect(SQLite(), dbname = 
                      sprintf("/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/partitions/czesc%d/wiki%s.sqlite", i, typ))
  aa[n] <- dbGetQuery(con1, sprintf("select distinct id_title from art_word_freq%s", typ))
  dbDisconnect(con1)
  
}

## bb - z cat_art


i <- 1
message("Connecting to db ", i)
con1 <- dbConnect(SQLite(), dbname = 
                    sprintf("/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/partitions/czesc%d/wiki_art_cat.sqlite", i))


dbExecQuery(con1, "drop table if exists cat_art2;")
dbExecQuery(con1, "create table if not exists cat_art2 (
                id_title INTEGER NOT NULL,
                id_cat
    );")

dbExecQuery(con1, sprintf("insert into cat_art2 (id_title, id_cat)
                
                select * from cat_art 
                where id_title not in (%s)", 
                          stri_flatten(
                            c(411278, 907399, 473644, 411388, 193317, 358425, 18152, 473968, 474017,
                              327107, 280615, 544189, 278771, 712304, 200423, 578374, 418763, 190832), collapse = ", ")
                          #391868
                  )
)
dbDisconnect(con1)




