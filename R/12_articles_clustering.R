library(RSQLite)
library(stringi)
library(compiler)
library(stringdist)


source("./R/db_exec.R")
prepare_string <- cmpfun(function(str) {
  stri_paste("'", stri_replace_all_fixed(str, "'", "''"), "'")
})


con <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")



dbExecQuery(con, "create table if not exists wiki_word_clust_freq (
            id_title INTEGER NOT NULL,
            id_stem_word INTEGER NOT NULL,
            freq INTEGER NOT NULL,
            FOREIGN KEY (id_title) REFERENCES wiki_page(id),
            FOREIGN KEY (id_word) REFERENCES wiki_word(id)
)")


dbGetQuery(con, "select count(distinct id) as cnt from wiki_page")

dbGetQuery(con, "
select 
  count(distinct b.id_title) as cnt 
from 
  wiki_category_text b 
join
(
  select id 
  from wiki_category_name 
  where name in ('matematyka', 'historia sztuki', 'wojny')
) c
on
  b.id_category = c.id
")




aa <- dbGetQuery(con, "
select a.id_title, a.id_word, b.id_stem_word, a.freq, sum(a.freq) as suma
from 
(  select *
  from  wiki_word_freq 
) a
join 
(
  select *
  from wiki_hunspell_clust 
) b
on
  a.id_word = b.id_word
group by 
  a.id_title
  ,b.id_stem_word
")


kat <- dbGetQuery(con, "select *
  from wiki_category_name 
  where name in ('matematyka', 'historia sztuki', 'wojny')")

dbExecQuery(con, "drop table tmp_hunspell")
dbDisconnect(con)
