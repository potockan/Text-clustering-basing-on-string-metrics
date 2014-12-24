#!/usr/bin/Rscript --vanilla

#install.packages("RSQLite")
library(RSQLite)

### Delete raw text database ###


conn <- dbConnect(SQLite(), dbname = "./Data/DataBase/wiki_raw.sqlite")

#commented in case it's called by mistake
#dbSendQuery(conn, "DROP TABLE wiki_raw;")
#dbListTables(conn)

dbDisconnect(conn)
