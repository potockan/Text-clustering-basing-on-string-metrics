
library(RSQLite)

### Raw text database ###


conn <- dbConnect(SQLite(), dbname = "./Data/DataBase/wiki_raw.sqlite")

dbGetQuery(conn, "select * from wiki_raw 
           where id=7 ")


dbGetQuery(conn, "select count(1) as ile from wiki_raw where ns=0")

dbDisconnect(conn)

###################
