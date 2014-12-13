
library(RSQLite)
library(stringi)
### Raw text database ###


conn <- dbConnect(SQLite(), dbname = "./Data/DataBase/wiki_raw.sqlite")
aa[20,3]
aa <-
dbGetQuery(conn, "select * from wiki_raw 
           where id between 8 and 50")
t <- unlist(aa)[127:173]
cyt <- stri_extract_all_regex(t, "<ref>(.)*?</ref>")
link <- stri_extract_all_regex(t, "\\[\\[[^:\\]]+?:[^:]+?\\]\\]")

link2 <- stri_extract_all_regex(t, "\\[\\[[^:\\]]+?:\\S[^:]+?\\]\\]")
unlist(lapply(link2, length))
klamr <- stri_extract_all_regex(t, "\\{\\{(.)*?\\}\\}")
troj <- stri_extract_all_regex(t, "<.*?>(.)*?<.*?>")

dbGetQuery(conn, "select count(1) as ile from wiki_raw where ns=0")

dbDisconnect(conn)

###################
