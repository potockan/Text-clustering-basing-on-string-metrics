#!/usr/bin/Rscript --vanilla

#install.packages("RSQLite")
library(RSQLite)
source("./R/db_exec.R")
### Raw text database ###


conn <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki_raw.sqlite")

dbExecQuery(conn, "CREATE TABLE IF NOT EXISTS wiki_raw (
  id INTEGER NOT NULL PRIMARY KEY,
  ns INEGER NOT NULL,
  title VARCHAR(256) NOT NULL,
  text TEXT NOT NULL,
  redirect VARCHAR(256) DEFAULT NULL
);")
#dbListTables(conn)

dbDisconnect(conn)

###################
