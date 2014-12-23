#!/usr/bin/Rscript --vanilla

#install.packages("stringi")
library(RSQLite)
con <- dbConnect(SQLite(), dbname = "./Data/DataBase/wiki.sqlite")

dbSendQuery(con,"
            CREATE UNIQUE INDEX index_word
            ON wiki_word(word)
            ")

dbSendQuery(con,"
            CREATE UNIQUE INDEX index_cat
            ON wiki_category_name(name)
            ")

dbDisconnect(con)
