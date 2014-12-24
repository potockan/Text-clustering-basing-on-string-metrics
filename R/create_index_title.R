#!/usr/bin/Rscript --vanilla

#install.packages("stringi")
library(RSQLite)
conn <- dbConnect(SQLite(), dbname = "./Data/DataBase/wiki_raw.sqlite")

dbSendQuery(conn,"
            CREATE INDEX my_index
            ON wiki_raw(title)
            ")

dbDisconnect(conn)
