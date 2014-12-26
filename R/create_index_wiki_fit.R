#!/usr/bin/Rscript --vanilla

#install.packages("stringi")
library(RSQLite)
source("./R/db_exec.R")
con <- dbConnect(SQLite(), dbname = "./Data/DataBase/wiki.sqlite")

dbExecQuery(con,"
            CREATE UNIQUE INDEX index_word
            ON wiki_word(word)
            ")

dbExecQuery(con,"
            CREATE UNIQUE INDEX index_cat
            ON wiki_category_name(name)
            ")

dbDisconnect(con)
