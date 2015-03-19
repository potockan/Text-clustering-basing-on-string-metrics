library(RSQLite)
library(stringi)
library(compiler)

#java -jar languagetool-commandline.jar -l pl -c UTF-8 -t words.txt > words_tag.txt

system2(command = "java", args = "-jar /home/natalia/LanguageTool-2.8/languagetool-commandline.jar -l pl -c UTF-8 -t /home/natalia/LanguageTool-2.8/words_to_analize.txt",
        stdout = "/dragon/Text-clustering-basing-on-string-metrics/Data//RObjects/words_tag.txt")

## dbExecQuery function
source("./R/db_exec.R")

## function preparing strong to insert it to db
prepare_string <- cmpfun(function(str) {
  stri_paste("'", stri_replace_all_fixed(str, "'", "''"), "'")
})


con <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")

#dbExecQuery(con, "drop table if exists wiki_langtools_tag_clust")
# #dbExecQuery(con, "drop table if exists wiki_hunspell_clust")
#dbExecQuery(con, "drop table if exists tmp_tag")
#dbExecQuery(con, "drop table if exists tmp_hunspell")



dbExecQuery(con, "CREATE TABLE IF NOT EXISTS wiki_langtools_tag_clust (
            id_word INTEGER NOT NULL,
            id_stem_word INTEGER NOT NULL,
            FOREIGN KEY (id_word) REFERENCES wiki_word(id),
            FOREIGN KEY (id_stem_word) REFERENCES wiki_word(id)
);")

dbExecQuery(con, "create table tmp_tag (
            word VARCHAR(256) NOT NULL,
            stem_word VARCHAR(256) NOT NULL
)")


f <- file("/dragon/Text-clustering-basing-on-string-metrics/Data//RObjects/words_tag.txt", "r")
i <- 0
while (length(out <- readLines(con = f, n=10)) > 0) {
  i <- i+1
  out1 <- 
    stri_split_fixed(unlist(stri_split_fixed(out, "]", omit_empty = TRUE)), "[", omit_empty = TRUE)
  out2 <- lapply(out1, function(x){
    
    #   stri_trans_tolower(
    #     stri_extract_all_regex(x, ",([^/]+)/", omit_no_match = TRUE)
    #     )
    p1 <- stri_trim_both(unlist(stri_split_fixed(x, "<S> ", omit_empty = TRUE))[1])
    p2 <- stri_trans_tolower(unlist(stri_split_fixed(x[2], "/", omit_empty = TRUE))[1])
    c(p1, ifelse(length(p2)==0, p1, p2))
    
  })
 
  
  m1 <- matrix(unlist(out2), ncol = 2, byrow = TRUE)
  na_col <- which(is.na(m1[,2]))
  if(length(na_col)>0)
    m1 <- m1[-na_col,]
  
  to_insert <- sprintf("(%s, %s)", prepare_string(m1[,1]), prepare_string(m1[,2]))
  to_insert <- split(to_insert, rep(1:ceiling(length(to_insert)/500), 
                                    length.out=length(to_insert)))          
  
  lapply(to_insert, function(to_insert) {
    dbExecQuery(con, sprintf("INSERT into tmp_tag(word, stem_word)
                             values %s", stri_flatten(to_insert, collapse=",")))
  })
  if(i %% 500 == 0)
    print(i)
  
}

close(f)

dbExecQuery(con, "INSERT into wiki_langtools_tag_clust(id_word, id_stem_word)
            select c.id_word as id_word, d.id as id_stem_word
            from
              (select a.word, a.stem_word, b.id as id_word
              from tmp_tag a
              join
              wiki_word b
              on a.word = b.word) c
          join
          wiki_word d
          on c.stem_word = d.word
            ")

dbExecQuery(con, "drop table tmp_tag")

dbGetQuery(con, "select count (distinct id_stem_word) from wiki_langtools_tag_clust")
dbGetQuery(con, "select count (distinct id_word) from wiki_langtools_tag_clust")
dbGetQuery(con, "select count (*) from wiki_langtools_tag_clust where id_word != id_stem_word")

dbDisconnect(con)

