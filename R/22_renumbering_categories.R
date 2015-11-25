
library(rvest)
library(dplyr)
library(stringi)
library(Hmisc)
library(RSQLite)
library(compiler)


prepare_string <- cmpfun(function(str) {
  stri_paste("'", stri_replace_all_fixed(str, "'", "''"), "'")
})

source("./R/db_exec.R")


load("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/categories/kategorie20151123_ost.rda")


con <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")

dbExecQuery(con, "DROP TABLE IF EXISTS wiki_category_after_reduction2")

dbExecQuery(con, "CREATE TABLE IF NOT EXISTS wiki_category_after_reduction2 (
  id_new INTEGER NOT NULL,
  name_old VARCHAR(256) NOT NULL,
  id_old INTEGER NOT NULL,
  name_new VARCHAR(256) NOT NULL
);")



to_insert <- sprintf("(%d, %s, %d, %s)", 
                     kategorie$id_new2,
                     prepare_string(kategorie$name_new), 
                     kategorie$id_new, 
                     prepare_string(kategorie$nowa_kat2))
to_insert <- split(to_insert, 
                   rep(1:ceiling(length(to_insert)/500), 
                       length.out=length(to_insert)))          

lapply(to_insert, function(to_insert) {
  dbExecQuery(con, sprintf("INSERT into wiki_category_after_reduction2(id_new, name_old, id_old, name_new)
                    values %s", stri_flatten(to_insert, collapse=",")))
})


dbGetQuery(con, "select * from wiki_category_after_reduction2 limit 10")
dbGetQuery(con, "select * from wiki_category_text_after_reduction limit 10")
dbGetQuery(con, "select count(distinct id_title) from wiki_category_text_after_reduction")
dbGetQuery(con, "select count(distinct id) from wiki_category_text_after_reduction")

dbDisconnect(con)

##########

con1 <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/partitions/czesc1/wiki_dl.sqlite")

dbGetQuery(con1, "select count(distinct id_title) from art_word_freq_dl")

dbDisconnect(con1)

# TO DO:
# polaczyc teksty z kategoriami 
# i poprawic w kazdej z czesci, bo jest zle! (duplikaty)




# dbExecQuery(con, "CREATE TABLE IF NOT EXISTS tmp_category_text_after_reduction (
#             id_title INTEGER NOT NULL,
#             id_new_cat INTEGER NOT NULL,
#             id_old_cat INTEGER NOT NULL,
#             FOREIGN KEY (id_title) REFERENCES wiki_page(id),
#             FOREIGN KEY (id_old_cat) REFERENCES wiki_category_name(id)
# );")
# 
# dbExecQuery(con, "INSERT into tmp_category_text_after_reduction(id_title, id_new_cat, id_old_cat)
#             
#             select a.id_title, b.id_new, b.id_old
#             from wiki_unique_category a
#             join
#             wiki_category_after_reduction b
#             on a.id_category = b.id_old
#             ")


dbExecQuery(con, "CREATE TABLE IF NOT EXISTS wiki_category_text_after_reduction_single (
  id INTEGER NOT NULL PRIMARY KEY,
  id_title INTEGER NOT NULL,
  id_new_cat INTEGER NOT NULL,
  id_old_cat INTEGER NOT NULL,
  FOREIGN KEY (id_title) REFERENCES wiki_page(id),
  FOREIGN KEY (id_old_cat) REFERENCES wiki_category_name(id)
);")

dbExecQuery(con, "INSERT into wiki_category_text_after_reduction_single(id_title, id_new_cat, id_old_cat)

                  select d.id_title, d.id_new_cat, d.id_old_cat
                  from wiki_category_text_after_reduction d
                  group by d.id_title, d.id_new_cat, d.id_old_cat")


#####
#spr

dbGetQuery(con, "select count(distinct id_title) from wiki_category_text_after_reduction_single")
dbGetQuery(con, "select count(distinct id) from wiki_category_text_after_reduction_single")
#####




dbExecQuery(con, "CREATE TABLE IF NOT EXISTS wiki_category_text_after_reduction2 (
  id INTEGER NOT NULL PRIMARY KEY,
  id_title INTEGER NOT NULL,
  id_new_cat INTEGER NOT NULL,
  id_old_cat INTEGER NOT NULL,
  FOREIGN KEY (id_title) REFERENCES wiki_page(id),
  FOREIGN KEY (id_old_cat) REFERENCES wiki_category_name(id)
);")

dbExecQuery(con, "INSERT into wiki_category_text_after_reduction2(id_title, id_new_cat, id_old_cat)

                  select c.id_title, c.id_new_cat, c.id_old_cat
                  from wiki_category_after_reduction2 d
                  join 
                  wiki_category_text_after_reduction_single c
                  on d.id_old = c.id_new_cat
                  group by c.id_title, c.id_new_cat, c.id_old_cat")



dbGetQuery(con, "select count(distinct id_title) from wiki_category_text_after_reduction2")
dbGetQuery(con, "select count(distinct id) from wiki_category_text_after_reduction2")

###########################
# Nowe tabele: 

# wiki_category_text_after_reduction_single == wiki_category_text_after_reduction
# bez zduplikowanych obserwacji, liczba nowych kategorii == 5265

# wiki_category_after_reduction2 - liczba nowych kategorii == 100
# wiki_category_text_after_reduction2 - -||- , liczba art. == 993 131, brak zduplikowanych obs.


##########################

id_title <- dbGetQuery(con, "select id_title from wiki_category_text_after_reduction order by id_title desc limit 50")
id <- dbGetQuery(con, "select id from wiki_category_text_after_reduction order by id desc limit 50")

dane <- dbGetQuery(con, sprintf("select distinct id_title
                       from wiki_word_clust3%s_freq
                       limit 
                       ", typ))

typ <- '_red_lcs'

dbDisconnect(con)




