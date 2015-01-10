#!/usr/bin/Rscript --vanilla

#install.packages("stringi")
library(RSQLite)
source("./R/db_exec.R")
conn <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki_raw.sqlite")

dbExecQuery(conn,"
            CREATE INDEX my_index
            ON wiki_raw(title)
            ")

dbDisconnect(conn)
