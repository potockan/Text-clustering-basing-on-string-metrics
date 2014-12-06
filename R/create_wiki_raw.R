#!/usr/bin/Rscript --vanilla

#install.packages("RSQLite")
library(RSQLite)

### Raw text database ###


conn <- dbConnect(SQLite(), dbname = "./Data/DataBase/wiki_raw.sqlite")

dbSendQuery(conn, "CREATE TABLE IF NOT EXISTS wiki_raw (
  id INTEGER NOT NULL PRIMARY KEY,
  ns INEGER NOT NULL,
  title VARCHAR(256) NOT NULL,
  text TEXT NOT NULL,
  redirect VARCHAR(256) DEFAULT NULL
);")
#dbListTables(conn)

dbDisconnect(conn)

###################
