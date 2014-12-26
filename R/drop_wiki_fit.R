#!/usr/bin/Rscript --vanilla

#install.packages("RSQLite")
library(RSQLite)
source("./R/db_exec.R")
### Delete raw text database ###


con <- dbConnect(SQLite(), dbname = "./Data/DataBase/wiki.sqlite")

dbExecQuery(con, "DROP TABLE IF EXISTS wiki_word_freq;")
dbExecQuery(con, "DROP TABLE IF EXISTS wiki_word;")
# dbExecQuery(con, "DROP TABLE IF EXISTS wiki_curly;")
# dbExecQuery(con, "DROP TABLE IF EXISTS wiki_tag;")
dbExecQuery(con, "DROP TABLE IF EXISTS wiki_redirect;")
dbExecQuery(con, "DROP TABLE IF EXISTS wiki_link;")
dbExecQuery(con, "DROP TABLE IF EXISTS wiki_category_text;")
dbExecQuery(con, "DROP TABLE IF EXISTS wiki_category_name;")
dbExecQuery(con, "DROP TABLE IF EXISTS wiki_page;")

#dbListTables(con)

dbDisconnect(con)
