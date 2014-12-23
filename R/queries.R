#!/usr/bin/Rscript --vanilla

#install.packages("stringi")
library(RSQLite)
library(stringi)
### Raw text database ###

## TO DO: 
# (?) zaladowac od nowa baze, tak zeby wszystko bylo lower case. PHP zmieniony
# dziala dla lower(title), ale lower chyba dziala tylko dla ascii por. https://www.sqlite.org/lang_corefunc.html


prepare_string <- function(str, source_encoding='UTF-8') {
  str <- as.character(str)
  stopifnot(!is.na(str))
  ret <- stri_replace_all_fixed(str, "'", "''")
  ret <- stri_paste("'",ret,"'")
  ret
}

conn <- dbConnect(SQLite(), dbname = "./Data/DataBase/wiki_raw.sqlite")
con <- dbConnect(SQLite(), dbname = "./Data/DataBase/wiki.sqlite")

i <- 15
aa <-
dbGetQuery(conn, sprintf("select * from wiki_raw 
           where id = %d", i))

redirect <- aa$redirect
id_from <- aa$id
if(!is.na(redirect))
{
  redirect <- stri_trans_tolower(redirect)
  id_to <- dbGetQuery(conn, sprintf("
            SELECT id 
            FROM wiki_raw 
            INDEXED BY my_index
            WHERE lower(title)='%s'", redirect))
  
  dbSendQuery(con, sprintf("
              INSERT INTO wiki_redirect(id_from, id_to)
              VALUES (%d, %d)
              ", id_from, id_to[,1])
  )
  
}
else
{
  #everything that's below
  title <- aa$title
  dbSendQuery(con, sprintf("
              INSERT INTO wiki_page(id, title)
              VALUES (%d, %s)
              ", id_from, prepare_string(title)))
}
  

text <- stri_trans_tolower(aa$text)

# #extracting all the tags and all the content within curly brackets to save it in the DB
# (tags <- stri_extract_all_regex(text, "<.*?>(.)*?<.*?>")[[1]])
# (curly <- stri_extract_all_regex(text, "\\{\\{[^\\}]*?\\}\\}")[[1]])





#removing all the comment, tags and all the content within curly brackets
patterns <- c("<!--(.)*?-->", "<.*?>(.)*?<.*?>", "\\{\\{[^\\}]*?\\}\\}", "zobacz tez", "linki zewnętrzne", "bibliografia", "przypisy")
text2 <- stri_replace_all_regex(text, patterns , "", vectorize_all = FALSE)



#################################################
### LINKS ###
##[[x|y]] (x is the link, y the string to be viewed) or [[x]] (x is both)

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
(id_to <- dbGetQuery(conn, 
        sprintf("SELECT id 
                FROM wiki_raw 
                INDEXED BY my_index 
                WHERE lower(title) in (%s)", 
          stri_flatten( prepare_string(m3), collapse = ", ")
                         )
           )
)


# 
# (id_to <- dbGetQuery(conn, sprintf("select id, title from wiki_raw where lower(title) in ('%s')", 
#                                    stri_flatten( m3, collapse = "', '")
#                                    )
#                     )
# )

################################################
### LINKS: NOT-LINKS ###
#those that had only [[x]] we want to replace with x
#[[x|y]] we want to replace with y
no_string <- which(stri_length(m[,3])==0)
m[no_string,3] <- m[no_string, 2]


### removing all [[x]] and [[x|y]] from the text
(text3 <- stri_replace_all_fixed(text2, m[,1], m[,3], 
                          vectorize_all=FALSE)
)
###########################################

### KATEGORIE ###

# not links: [[x:y]] - we want y only if x is "kategoria"

#extractng all the not-links 
(not_link <- stri_extract_all_regex(text3, "\\[\\[[^:\\]]+?:\\S[^:]+?\\]\\]")[[1]])


#matching those with "kategoria"
(not_link2 <- stri_match_all_regex(not_link, "\\[\\[kategoria:(.+?)\\]\\]"))

(not_link3 <- matrix(unlist(not_link2), ncol=2, byrow=TRUE))

## inserting categories into db, if it's not already there
dbSendQuery(con, sprintf(
            "INSERT OR IGNORE INTO 
            wiki_category_name(name)
            VALUES (%s)",
            stri_flatten(prepare_string(not_link3[,2])
                      , collapse = "), (")
                    )
            )

id_cat <- dbGetQuery(con, sprintf("SELECT id from wiki_category_name
                WHERE name IN (%s)", 
                stri_flatten(prepare_string(not_link3[,2]),
                  collapse = ", "))
          )


### removing all the [[x:y]] from the text
(text4 <- stri_replace_all_fixed(text3, not_link, "", vectorize_all = FALSE)
)

#############

### WORD COUNTING ###
words_all  <- stri_extract_all_words(text4)[[1]]
### TO DO: 


words <- unique(words_all)
words <- prepare_string(words)
### TO DO:
# INSERT DOESN'T WORK!!!
# Error in sqliteSendQuery(conn, statement) : 
# error in statement: too many terms in compound SELECT
# http://stackoverflow.com/questions/9527851/sqlite-error-too-many-terms-in-compound-select
# SQLITE_MAX_COMPOUND_SELECT id 500
# Powiekszamy, czy bawimy sie w pare/nascie insertow?
# words <- c("całą","historię","l''île", "des","pingouins","1908")
n_words <- length(words)
for(j in 1:floor(n_words/500))
{
  dbSendQuery(con, sprintf(
    "INSERT OR IGNORE INTO 
              wiki_word(word)
              VALUES (%s)",
    stri_flatten(words[((j-1)*500+1) : (j*500)], collapse = "), (")
    )
  )
}

dbSendQuery(con, sprintf(
  "INSERT OR IGNORE INTO 
              wiki_word(word)
              VALUES (%s)",
  stri_flatten(words[(j*500+1) : (j*500+n_words%%500)], collapse = "), (")
)
)

# id_words <- dbGetQuery(con, sprintf(
#             "
#             SELECT * FROM wiki_word
#             WHERE word IN (%s)
#             ", stri_flatten(words, collapse = ", ")
#             )
# )

#### TO DO: LICZNOSCI
### WORD COUNTING ###
(words_text <- as.data.frame(table(words_all)))
words_text[,1] <- prepare_string(words_text[,1])




n_words_text <- nrow(words_text)
for(j in 1:floor(n_words_text/500))
{
  
  ins <- "INSERT INTO wiki_word_freq(id_title, id_word, freq)
        VALUES "
  values <- apply(words_text[((j-1)*500+1) : (j*500),], 1, function(w)
  {
    sel <- stri_paste("SELECT id FROM wiki_word WHERE word=", w[1])
    str <- stri_paste("(", id_from, ", (", sel, "), ", w[2], ")")
    str
  })
  str <- stri_paste(ins, stri_flatten(values, collapse = ", "))
  dbSendQuery(con, str)

}


ins <- "INSERT INTO wiki_word_freq(id_title, id_word, freq)
VALUES "
values <- apply(words_text[(i*500+1) : (i*500+n_words%%500),], 1, function(w)
{
  sel <- stri_paste("SELECT id FROM wiki_word WHERE word=", w[1])
  str <- stri_paste("(", id_from, ", (", sel, "), ", w[2], ")")
  str
})
str <- stri_paste(ins, stri_flatten(values, collapse = ", "))
dbSendQuery(con, str)



################################

####################################################

#### INSERTING INTO DB

### TO DO:
### This has to be done at the end, after inserting the text, cause
### id_title is FK from wiki_page
# #inserting the tags
# dbSendQuery(con, sprintf(
#   "INSERT INTO 
#             wiki_tag(id_title, text)
#             VALUES (%s')",
#   stri_paste(id_from, " , '", stri_flatten(tags))
# )
# )
# 
# #inserting curly brackets
# dbSendQuery(con, sprintf(
#   "INSERT INTO 
#             wiki_curly(id_title, text)
#             VALUES (%s')",
#   stri_paste(id_from, " , '", stri_flatten(curly))
# )
# )
###########
### TO DO:
### This has to be done at the end, after inserting the text, cause
### id_from is FK from wiki_page
#inserting links
dbSendQuery(con, sprintf(
  "INSERT INTO 
            wiki_links(id_from, id_to)
            VALUES (%s)",
  stri_paste(id_from, ", ", 
             stri_flatten(id_to[,1], collapse = 
                            stri_paste("), (", id_from, ", ")))
)
)

#########3
## TO DO:
### This has to be done at the end, after inserting the text, cause
### id_from is FK from wiki_page
#inserting categories
dbSendQuery(con, sprintf(
  "INSERT INTO 
            wiki_category_text(id_title, id_category)
            VALUES (%s)",
  stri_paste(id_from, ", ",
             stri_flatten( id_cat[,1], collapse = 
                             stri_paste("), (", id_from, ", ")
             )
  )
)
)


### DB DISCONNECT

dbDisconnect(conn)
dbDisconnect(con)

###################
