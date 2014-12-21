#!/usr/bin/Rscript --vanilla

#install.packages("stringi")
library(RSQLite)
library(stringi)
### Raw text database ###

## TO DO: 
# (?) zaladowac od nowa baze, tak zeby wszystko bylo lower case. PHP zmieniony
# dziala dla lower(title), ale lower chyba dziala tylko dla ascii por. https://www.sqlite.org/lang_corefunc.html


conn <- dbConnect(SQLite(), dbname = "./Data/DataBase/wiki_raw.sqlite")
con <- dbConnect(SQLite(), dbname = "./Data/DataBase/wiki.sqlite")

i <- 15
aa <-
dbGetQuery(conn, sprintf("select * from wiki_raw 
           where id = %d", i))
id_from <- aa$id
text <- stri_trans_tolower(aa$text)

#extracting all the tags and all the content within curly brackets to save it in the DB
(tags <- stri_extract_all_regex(text, "<.*?>(.)*?<.*?>")[[1]])
(curly <- stri_extract_all_regex(text, "\\{\\{[^\\}]*?\\}\\}")[[1]])


#removing all the comment, tags and all the content within curly brackets
text <- stri_replace_all_regex(text,  "<!--(.)*?-->", "")
text1 <- stri_replace_all_regex(text,  "<.*?>(.)*?<.*?>", "")
text2 <- stri_replace_all_regex(text1,  "\\{\\{[^\\}]*?\\}\\}", "")

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
m3 <- stri_trans_tolower(unique(m2[,2]))


#extracting id's where we link to
(id_to <- dbGetQuery(conn, sprintf("select id from wiki_raw where lower(title) in ('%s')", 
                         stri_flatten( m3, collapse = "', '")
                         )
           )
)
# 
# (id_to <- dbGetQuery(conn, sprintf("select id, title from wiki_raw where lower(title) in ('%s')", 
#                                    stri_flatten( m3, collapse = "', '")
#                                    )
#                     )
# )

#those that had only [[x]] we want to replace with x
#[[x|y]] we want to replace with y
no_string <- which(stri_length(m[,3])==0)
m[no_string,3] <- m[no_string, 2]

(text3 <- stri_replace_all_fixed(text2, m[,1], m[,3], 
                          vectorize_all=FALSE)
)
##########

### KATEGORIE ###

# not links: [[x:y]] - we want y only if x is "kategoria"

#extractng all the not-links 
(not_link <- stri_extract_all_regex(text3, "\\[\\[[^:\\]]+?:\\S[^:]+?\\]\\]")[[1]])


#matching those with "kategoria"
(not_link2 <- stri_match_all_regex(not_link, "\\[\\[kategoria:(.+?)\\]\\]"))

(m <- matrix(unlist(not_link2), ncol=2, byrow=TRUE))


dbSendQuery(con, sprintf(
            "INSERT INTO 
            wiki_category_name(name)
            VALUES ('%s')",
            stri_flatten(m[,2], collapse = "'), ('")
                    )
            )

(text4 <- stri_replace_all_fixed(text3, not_link, "")
)

#############




######## SYF #######


klamr <- stri_extract_all_regex(text1, "\\{\\{(.)*?\\}\\}")
troj <- stri_extract_all_regex(t, "<.*?>(.)*?<.*?>")
opcj <- unique(unlist(stri_extract_all_regex(unlist(troj), "</(.)+?>")))

#dbGetQuery(conn, "select count(1) as ile from wiki_raw where ns=0")

dbDisconnect(conn)

###################
