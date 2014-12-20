#!/usr/bin/Rscript --vanilla

#install.packages("RSQLite")
library(RSQLite)

### Delete raw text database ###


conn <- dbConnect(SQLite(), dbname = "./Data/DataBase/wiki_raw.sqlite")

dbSendQuery(conn, "DROP TABLE wiki_raw;")
#dbListTables(conn)

dbDisconnect(conn)
