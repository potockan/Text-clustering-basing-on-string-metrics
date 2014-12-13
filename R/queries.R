
library(RSQLite)
library(stringi)
### Raw text database ###


conn <- dbConnect(SQLite(), dbname = "./Data/DataBase/wiki_raw.sqlite")

aa <-
dbGetQuery(conn, "select * from wiki_raw 
           where id between 1 and 500")
t <- aa$text
#cyt <- stri_extract_all_regex(t, "<ref>(.)*?</ref>")
#link <- stri_extract_all_regex(t, "\\[\\[[^:\\s\\]]+?\\]\\]")
#link <- stri_extract_all_regex(t, "\\[\\[[^:\\]]+?:\\s.+?\\]\\]")
#unlist(lapply(link, length))
link <- stri_extract_all_regex(t, "\\[\\[([^:\\]]+?:\\s(.)+?|[^:\\]]+?)\\]\\]")

not_link <- stri_extract_all_regex(t, "\\[\\[[^:\\]]+?:\\S[^:]+?\\]\\]")



klamr <- stri_extract_all_regex(t, "\\{\\{(.)*?\\}\\}")
troj <- stri_extract_all_regex(t, "<.*?>(.)*?<.*?>")
opcj <- unique(unlist(stri_extract_all_regex(unlist(troj), "</(.)+?>")))

#dbGetQuery(conn, "select count(1) as ile from wiki_raw where ns=0")

dbDisconnect(conn)

###################
