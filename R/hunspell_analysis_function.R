library(RSQLite)
library(stringi)
library(compiler)
## dbExecQuery function
source("./R/db_exec.R")
## function preparing strong to insert it to db
prepare_string <- cmpfun(function(str) {
  stri_paste("'", stri_replace_all_fixed(str, "'", "''"), "'")
})
hunspell_analysis <- function(file1, file2){
  message("DB connect")
  con <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")
  #dbExecQuery(con, "drop table wiki_hunspell_clust")
  dbExecQuery(con, "CREATE TABLE IF NOT EXISTS wiki_hunspell_clust (
              id_word INTEGER NOT NULL,
              id_stem_word INTEGER NOT NULL,
              FOREIGN KEY (id_word) REFERENCES wiki_word(id),
              FOREIGN KEY (id_stem_word) REFERENCES wiki_word(id)
  );")
  dbExecQuery(con, "create table if not exists tmp_hunspell (
            word VARCHAR(256) NOT NULL,
            stem_word VARCHAR(256) NOT NULL
)")
  if(file.exists(file2))
    file.remove(file2)
  message("File reading")
  f <- file(file1, "r")
  #i <- 0
  while (length(txt <- readLines(con = f, n=8192)) > 0) {
    #i <- i+1
    #print(i)
    txt <- txt[stri_detect_fixed(txt, " ")]
    txt <- txt[which(stri_length(txt)>0)]
    txt_split <- lapply(stri_split_fixed(txt, " "), function(txt){
      p <- unlist(stri_split_fixed(txt, "st:") )
      p <- p[which(stri_length(p)>0 & p!="fl")]
      n <- length(p)
      if(n==1)
        p[2] <- ""
      p[1:2]
    })
    #txt_split
    if(length(txt_split)>0){
      #print(1)
      m1 <- matrix(unlist(txt_split), ncol = 2, byrow = TRUE)
      #print(2)
      dupl <- which(duplicated(m1[,1]))
      #print(3)
      if(length(dupl)>0)
        m1 <- matrix(m1[-dupl,], ncol = 2)
      cat(m1[,1], file = file2, append = TRUE, sep = '\n')
      #print(4)
      to_insert <- sprintf("(%s, %s)", prepare_string(stri_trans_tolower(m1[,1])), prepare_string(stri_trans_tolower(m1[,2])))
      #print(5)
      to_insert <- split(to_insert, rep(1:ceiling(length(to_insert)/500),
                                        length.out=length(to_insert)))
      #print(6)
      tryCatch({
        lapply(to_insert, function(to_insert) {
          dbExecQuery(con, sprintf("INSERT into tmp_hunspell(word, stem_word)
                                 values %s", stri_flatten(to_insert, collapse=",")))
        })
      },
      finally = next)
    }
  }
  message("File closing")
  close(f)
  message("DB inserting")
  dbExecQuery(con, "INSERT into wiki_hunspell_clust(id_word, id_stem_word)
select c.id_word as id_word, d.id as id_stem_word
from
(select a.word, a.stem_word, b.id as id_word
from tmp_hunspell a
join
wiki_word b
on a.word = b.word) c
join
wiki_word d
on c.stem_word = d.word
")
  dbExecQuery(con, "drop table tmp_hunspell")
  print(dbGetQuery(con, "select count (id_word) from wiki_hunspell_clust"))
  message("DB disconnect")
  dbDisconnect(con)
}