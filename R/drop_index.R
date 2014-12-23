#!/usr/bin/Rscript --vanilla

library(RSQLite)
conn <- dbConnect(SQLite(), dbname = "./Data/DataBase/wiki_raw.sqlite")

dbSendQuery(conn,"
            DROP INDEX
            my_index
            ")

dbDisconnect(conn)