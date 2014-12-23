#!/usr/bin/Rscript --vanilla

#install.packages("RSQLite")
library(RSQLite)

### Delete raw text database ###


con <- dbConnect(SQLite(), dbname = "./Data/DataBase/wiki.sqlite")

dbSendQuery(con, "DROP TABLE IF EXISTS wiki_word_freq;")
dbSendQuery(con, "DROP TABLE IF EXISTS wiki_word;")
# dbSendQuery(con, "DROP TABLE IF EXISTS wiki_curly;")
# dbSendQuery(con, "DROP TABLE IF EXISTS wiki_tag;")
dbSendQuery(con, "DROP TABLE IF EXISTS wiki_redirect;")
dbSendQuery(con, "DROP TABLE IF EXISTS wiki_link;")
dbSendQuery(con, "DROP TABLE IF EXISTS wiki_category_text;")
dbSendQuery(con, "DROP TABLE IF EXISTS wiki_category_name;")
dbSendQuery(con, "DROP TABLE IF EXISTS wiki_page;")

#dbListTables(con)

dbDisconnect(con)
