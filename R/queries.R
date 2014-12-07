
library(RSQLite)

### Raw text database ###


conn <- dbConnect(SQLite(), dbname = "./Data/DataBase/wiki_raw.sqlite")

dbGetQuery(conn, "select * from wiki_raw 
           where id=1234567 ")


dbGetQuery(conn, "select count(*) as ile from wiki_raw where ns=0")

dbDisconnect(conn)

###################
