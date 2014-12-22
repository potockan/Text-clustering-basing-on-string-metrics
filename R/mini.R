#!/usr/bin/Rscript --vanilla

#install.packages("stringi")
library(RSQLite)
library(stringi)
### Raw text database ###

dir_file_create <- function(dir, sub_dir, i){
  file_size <- 20000000
  dir_size <- 1000
  outdir <- file.path(dir, stri_paste(sub_dir, i))
  file <- file.path(outdir, stri_paste(sub_dir, i, ".csv"))
  ls <- list.dirs(dir, recursive = FALSE)
  current_dir <- ls[length(ls)]
  if(length(current_dir)==0)
    dir.create(outdir)
  lf <- list.files(current_dir, full.names = TRUE)
  n <- length(lf)
  current_file <- lf[n]
  file_info <- file.info(current_file)
  if(length(file_info$size)==0){
    file.create(file)
    ret <- file
  }else{
    if(file_info$size>=file_size){
      if(n>=dir_size)
        dir.create(outdir)
      else{
        file.create(file)
      }
    }else{
      ret <- current_file
    }
  }
  return(ret)
}


conn <- dbConnect(SQLite(), dbname = "./Data/DataBase/wiki_raw.sqlite")
con <- dbConnect(SQLite(), dbname = "./Data/DataBase/wiki.sqlite")

dir_red <- "./Data/redirect"
dir_links <- "./Data/links"
dir_categories_name <- "./Data/categories_name"
dir_words <- "./Data/words"
dir_words_cnt <- "./Data/words_cnt"

dirs2create <- file.path(
  c(dir_red, dir_links, dir_categories_name, dir_words, dir_words_cnt))


dirs2create <- dirs2create[!file.exists(dirs2create)]
for (outdir3 in dirs2create) dir.create(outdir3, recursive=TRUE)



for(i in 1:1654533){
aa <-
  dbGetQuery(conn, sprintf("select * from wiki_raw 
                           where id = %d and ns=0", i))
index <- dbGetQuery(conn, "select id from wiki_raw 
                           where redirect!=NULL limit 200")
if(nrow(aa)!=0){ 
  #everything that's below
}
redirect <- aa$redirect
id_from <- aa$id
if(!is.na(redirect))
{
  current_file <- dir_file_create(dir_red, "red_", i)
  redirect <- stri_trans_tolower(redirect)
  id_to <- dbGetQuery(conn, sprintf("
            SELECT id 
            FROM wiki_raw 
            WHERE lower(title)='%s'", redirect))  
  stri_write_lines(c(id_from, id_to[,1]), current_file)
  
}
else
{
  #everything that's below
}


text <- stri_trans_tolower(aa$text)

#extracting all the tags and all the content within curly brackets to save it in the DB
(tags <- stri_extract_all_regex(text, "<.*?>(.)*?<.*?>")[[1]])
(curly <- stri_extract_all_regex(text, "\\{\\{[^\\}]*?\\}\\}")[[1]])





#removing all the comment, tags and all the content within curly brackets
patterns <- c("<!--(.)*?-->", "<.*?>(.)*?<.*?>", "\\{\\{[^\\}]*?\\}\\}", "zobacz tez", "linki zewnętrzne")
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
  VALUES ('%s')",
  stri_flatten(not_link3[,2], collapse = "'), ('")
)
)

id_cat <- dbGetQuery(con, sprintf("SELECT id from wiki_category_name
                                  WHERE name IN ('%s')", stri_flatten(not_link3[,2], collapse = "', '"))
)


### removing all the [[x:y]] from the text
(text4 <- stri_replace_all_fixed(text3, not_link, "", vectorize_all = FALSE)
)

#############

### WORD COUNTING ###
words_all  <- stri_extract_all_words(text4)[[1]]
### TO DO: 
#text jako jedna b. dluga linia, bez interpunkcji (stri_flatten words_all)
#czy raczej wyrzucic wszystko co nie jest [a-z], \s lub \d
#czy zostawic jak jest z *,=, milionem \n itd.


words <- unique(words_all)
words <- stri_replace_all_fixed(words, "'", "''")
### TO DO:
# INSERT DOESN'T WORK!!!
# Error in sqliteSendQuery(conn, statement) : 
# error in statement: too many terms in compound SELECT
# http://stackoverflow.com/questions/9527851/sqlite-error-too-many-terms-in-compound-select
# SQLITE_MAX_COMPOUND_SELECT id 500
# Powiekszamy, czy bawimy sie w pare/nascie insertow?
# words <- c("całą","historię","l''île", "des","pingouins","1908")
dbSendQuery(con, sprintf(
  "INSERT OR IGNORE INTO 
  wiki_word(word)
  VALUES ('%s')",
  stri_flatten(words[1:500], collapse = "'), ('")
)
)

id_words <- dbGetQuery(con, sprintf(
  "
  SELECT id FROM wiki_word
  WHERE word IN ('%s')
  "), stri_flatten(words, collapse = "', '")
)

#### TO DO: LICZNOSCI
### WORD COUNTING ###
(words_text <- table(words_all))

################################

####################################################

#### INSERTING INTO DB

### TO DO:
### This has to be done at the end, after inserting the text, cause
### id_title is FK from wiki_page
#inserting the tags
dbSendQuery(con, sprintf(
  "INSERT INTO 
  wiki_tag(id_title, text)
  VALUES (%s')",
  stri_paste(id_from, " , '", stri_flatten(tags))
  )
)

#inserting curly brackets
dbSendQuery(con, sprintf(
  "INSERT INTO 
  wiki_curly(id_title, text)
  VALUES (%s')",
  stri_paste(id_from, " , '", stri_flatten(curly))
  )
)
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

}
### DB DISCONNECT

dbDisconnect(conn)
dbDisconnect(con)

###################
