
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

#extracting all the tags and all the content within curly brackets to save it in the DB
(tagi <- stri_extract_all_regex(text, "<.*?>(.)*?<.*?>")[[1]])
(klamr <- stri_extract_all_regex(text, "\\{\\{(.)*?\\}\\}")[[1]])

#removing all the tags and all the content within curly brackets
text1 <- stri_replace_all_regex(text,  "<.*?>(.)*?<.*?>", "")
text2 <- stri_replace_all_regex(text1,  "\\{\\{(.)*?\\}\\}", "")


#cyt <- stri_extract_all_regex(t, "<ref>(.)*?</ref>")
#link <- stri_extract_all_regex(t, "\\[\\[[^:\\s\\]]+?\\]\\]")
#link <- stri_extract_all_regex(t, "\\[\\[[^:\\]]+?:\\s.+?\\]\\]")
#unlist(lapply(link, length))

#text2 <- c("[[United States#History|History]] kglf [[United States]] mf [[United States#History]] nkds [[#Links and URLs]]")

### LINKS: [[x|y]] (x is the link, y the string to be viewed) or [[x]] (x is both)

#extractng all the links 
(link <- stri_extract_all_regex(text2, "\\[\\[([^:\\]]+?:\\s(.)+?|[^:\\]]+?)\\]\\]")[[1]])

#matching those with pipe and without it
(link2 <- stri_match_all_regex(link, "\\[\\[([^\\|]+)\\|?+([^\\|]*?)\\]\\]"))

#transformation to matrix
m <- matrix(unlist(link2), ncol=3, byrow = TRUE)

#if a link contains a hashtag (#) then the link leads to a section of the page
#(can be the same page itself)
#we want a link to the page not to the section so we're extracting it here


hashtag <- which(stri_detect_fixed(m[,2], "#"))
if(any(hashtag))
{
  #matching the page title and the section, transforming it into matrix
  hash_m <- matrix(unlist(stri_match_all_regex(m[hashtag,2], "(.*?)\\#(.+)")), ncol=3, byrow=TRUE)

  #replacing with title page
  m[hashtag, 2]  <- hash_m[,2]
}

# leaving only the links that lead to other pages
m2 <- m[which(stri_length(m[,2])>0),]
m3 <- unique(m2[,2])

#connecting with db
id_to <- dbGetQuery(conn, sprintf("select id, title from wiki_raw where title in ('%s')", 
                         stri_flatten( m3, collapse = "', '")
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
