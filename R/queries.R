
library(RSQLite)
library(stringi)
### Raw text database ###


conn <- dbConnect(SQLite(), dbname = "./Data/DataBase/wiki_raw.sqlite")

i <- 3
aa <-
dbGetQuery(conn, sprintf("select * from wiki_raw 
           where id = %d", i))
id_from <- aa$id
text <- aa$text

(tagi <- stri_extract_all_regex(text, "<.*?>(.)*?<.*?>")[[1]])
(klamr <- stri_extract_all_regex(text, "\\{\\{(.)*?\\}\\}")[[1]])
text1 <- stri_replace_all_regex(text,  "<.*?>(.)*?<.*?>", "")
text2 <- stri_replace_all_regex(text1,  "\\{\\{(.)*?\\}\\}", "")


#cyt <- stri_extract_all_regex(t, "<ref>(.)*?</ref>")
#link <- stri_extract_all_regex(t, "\\[\\[[^:\\s\\]]+?\\]\\]")
#link <- stri_extract_all_regex(t, "\\[\\[[^:\\]]+?:\\s.+?\\]\\]")
#unlist(lapply(link, length))

text2 <- c("[[United States#History|History]] kglf [[United States]] mf [[United States#History]]")

### LINKS: [[x|y]] (x is the link, y the string to be viewed) or [[x]] (x is both)
link <- stri_extract_all_regex(text2, "\\[\\[([^:\\]]+?:\\s(.)+?|[^:\\]]+?)\\]\\]")[[1]]


#(link2 <- stri_extract_all_regex(link[[1]], "\\[\\[(^\\|)+?\\|*?(^\\|)*?\\]\\]"))



(link2 <- stri_match_all_regex(link, "\\[\\[([^\\|]+)\\|?+([^\\|]*?)\\]\\]"))

#### Co gdy # ?

m <- matrix(unlist(link2), ncol=3, byrow = TRUE)

hashtag <- which(stri_detect_fixed(m[,2], "#"))
hash_m <- matrix(unlist(stri_match_all_regex(m[hashtag,2], "(.*?)\\#(.+)")), ncol=3, byrow=TRUE)

m[hashtag, 2]  <- hash_m[,2]


id_to <- dbGetQuery(conn, sprintf("select id, title from wiki_raw where title in ('%s')", 
                         stri_flatten( m[,2], collapse = "', '")
                         )
           )


##########







not_link <- stri_extract_all_regex(t, "\\[\\[[^:\\]]+?:\\S[^:]+?\\]\\]")



klamr <- stri_extract_all_regex(text1, "\\{\\{(.)*?\\}\\}")
troj <- stri_extract_all_regex(t, "<.*?>(.)*?<.*?>")
opcj <- unique(unlist(stri_extract_all_regex(unlist(troj), "</(.)+?>")))

#dbGetQuery(conn, "select count(1) as ile from wiki_raw where ns=0")

dbDisconnect(conn)

###################
