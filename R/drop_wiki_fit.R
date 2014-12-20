#!/usr/bin/Rscript --vanilla

#install.packages("RSQLite")
library(RSQLite)

### Delete raw text database ###


conn <- dbConnect(SQLite(), dbname = "./Data/DataBase/wiki.sqlite")

dbSendQuery(conn, "DROP TABLE IF EXISTS wiki_card;")
dbSendQuery(conn, "DROP TABLE IF EXISTS wiki_word;")
dbSendQuery(conn, "DROP TABLE IF EXISTS wiki_curly;")
dbSendQuery(conn, "DROP TABLE IF EXISTS wiki_tag;")
dbSendQuery(conn, "DROP TABLE IF EXISTS wiki_redirect;")
dbSendQuery(conn, "DROP TABLE IF EXISTS wiki_link;")
dbSendQuery(conn, "DROP TABLE IF EXISTS wiki_category_text;")
dbSendQuery(conn, "DROP TABLE IF EXISTS wiki_category_name;")
dbSendQuery(conn, "DROP TABLE IF EXISTS wiki_page;")

#dbListTables(conn)

dbDisconnect(conn)
