#!/usr/bin/Rscript --vanilla

#install.packages("RSQLite")
library(RSQLite)
source("./R/db_exec.R")
### Delete raw text database ###


conn <- dbConnect(SQLite(), dbname = "./Data/DataBase/wiki_raw.sqlite")

#commented in case it's called by mistake
#dbExecQuery(conn, "DROP TABLE wiki_raw;")
#dbListTables(conn)

dbDisconnect(conn)
