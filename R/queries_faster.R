#!/usr/bin/Rscript --vanilla

#install.packages("stringi")
library(RSQLite)
library(stringi)
library(compiler)

source("./R/db_exec.R")

### Raw text database ###


prepare_string <- cmpfun(function(str) {
  stri_paste("'", stri_replace_all_fixed(str, "'", "''"), "'")
})

conn <- dbConnect(SQLite(), dbname = "./Data/DataBase/wiki_raw.sqlite")
con <- dbConnect(SQLite(), dbname = "./Data/DataBase/wiki.sqlite")

dbExecQuery(con, "create temporary table tmp_redirect (
            id INTEGER NOT NULL PRIMARY KEY,
            id_from INTEGER NOT NULL,
            title_to VARCHAR(256) NOT NULL
            )")

dbExecQuery(con, "create temporary table tmp_link (
            id INTEGER NOT NULL PRIMARY KEY,
            id_from INTEGER NOT NULL,
            title_to VARCHAR(256) NOT NULL
            )")

dbExecQuery(con, "create temporary table tmp_category_text (
            id INTEGER NOT NULL PRIMARY KEY,
            id_title INTEGER NOT NULL,
            name VARCHAR(256) 
            )")

dbExecQuery(con, "create temporary table tmp_word_freq (
            id_title INTEGER NOT NULL,
            word VARCHAR(256) NOT NULL,
            freq INTEGER NOT NULL
            )")


# i <- 15
# aa <-
# dbGetQuery(conn, sprintf("select * from wiki_raw 
#            where id = %d", i))
cnt <- 100
for(i in 1:10){
  # for(i in 1: 1654533){
  print(i*cnt)
  aa <-
    dbGetQuery(conn, sprintf("select id, title, text, redirect from wiki_raw 
                             where id between %d and %d and ns=0", (i-1)*cnt+1, i*cnt))
 
  #we can select and empty row, when ns!=0 that's why:
  n <- nrow(aa)
  if(n==0)
    next
  
  
  redirect <- aa$redirect
  id_from <- aa$id
  #if a page is redirect, then we add it to redirect table
  red_na <- which(is.na(redirect))
  red_not_na <- which(!is.na(redirect))
  n_not_na <- length(red_not_na)
  if(n_not_na>0)
  {
    #print('redirect')
    aa_red <- aa[red_not_na,]
    redirect <- prepare_string(aa_red$redirect)
    
    dbExecQuery(con, sprintf("
                                 INSERT INTO tmp_redirect(id_from, title_to)
                                 VALUES (%s)
                                 ", 
                             stri_paste(
                               stri_paste(id_from[red_not_na], redirect, sep=", "), 
                               collapse = "), (")
    )
    )
    
    rm(aa_red, redirect)
  }
  if(n_not_na<n)
  {
    
    #print('page')
    aa <- aa[red_na,]
    rm(red_na, red_not_na, n_not_na)
    #inserting id and title of a page
    id_from <- aa$id
    title <- aa$title
    dbExecQuery(con, sprintf("
                               INSERT INTO wiki_page(id, title)
                               VALUES (%s)
                               ", 
                             stri_paste(
                               stri_paste(id_from, prepare_string(title), sep=", ")
                               , collapse = "), (")
    )
    )
    
    rm(title)
    
    
    text <- aa$text
    
  
    #removing all the comment, tags and all the content within curly brackets
    patterns <- c("<([a-zA-Z][a-zA-Z0-9]*).*?>.*?</\\1>", 
                  "\\{\\{[^\\}]*?\\}\\}", "<!--.*?-->")
  
    text2 <- stri_replace_all_regex(text, patterns , "", vectorize_all = FALSE)

    rm(patterns, text)
    
    
    #################################################
    ### LINKS ###
    ##[[x|y]] (x is the link, y the string to be viewed) or [[x]] (x is both)
    
    #print(links')
    links <- stri_match_all_regex(text2, "\\[\\[([^:|#]+?)(?:#[^|]+?)?(?:\\|(.+?))?\\]\\]",omit_no_match = TRUE)
    dl <- sapply(links, nrow)
    
   
    if(any(dl>0)){
      m <- cbind(do.call(rbind, links), rep(id_from, times=dl))
      m <- m[!duplicated(m[,c(1,4)]),]
      
   
      to_insert <- sprintf("(%s, %s)", m[,4], prepare_string(m[,2]))
      to_insert <- split(to_insert, rep(1:ceiling(length(to_insert)/500), length.out=length(to_insert)))          
      
      lapply(to_insert, function(to_insert) {
        dbExecQuery(con, sprintf("INSERT into tmp_link(id_from, title_to)
                    values %s", stri_flatten(to_insert, collapse=",")))
      })
   
      ################################################
      ### LINKS: NOT-LINKS ###
      
      #those that had only [[x]] we want to replace with x (in the text)
      #[[x|y]] we want to replace with y
      text3 <- stri_replace_all_regex(text2,
                                      "\\[\\[(?:[^:|\\]]+?\\|)(.+?)\\]\\]", "$1")    
      text3 <- stri_replace_all_regex(text3, 
                                      "\\[\\[([^:#\\]]+?)(?:(?:#.*?\\]\\])|(?:\\]\\]))", "$1")   
    
    }  

    ###########################################
    
    ### CATEGORIES ###
    #print('categories')
    # not links: [[x:y]] - we want y only if x is "kategoria"
    categories <- stri_match_all_regex(text3, "\\[\\[kategoria:([^|]+?)(?:\\|.*?)?\\]\\]")
    m <- cbind(do.call(rbind, categories), rep(id_from, times=sapply(categories, nrow)))[,-1]
    
    
    to_insert <- sprintf("(%s, %s)", m[,2], prepare_string(m[,1]))
    to_insert <- split(to_insert, rep(1:ceiling(length(to_insert)/500), length.out=length(to_insert)))          
    
    lapply(to_insert, function(to_insert) {
      dbExecQuery(con, sprintf("INSERT into tmp_category_text(id_title, name)
                    values %s", stri_flatten(to_insert, collapse=",")))
    })
    
#     
#     #matching those with "kategoria"
#     not_link2 <- lapply(not_link, function(not_link){
#       stri_match_all_regex(not_link, "\\[\\[kategoria:([^\\|]+)\\|{0,1}[^\\|]*?\\]\\]")
#     })
#     dl <- unlist(lapply(not_link2, length))  
#     not_link2 <- unlist(not_link2)
#     not_link4 <- cbind(matrix(not_link2, ncol=2, byrow=TRUE), rep(id_from, times=dl))
#     if(any(!is.na(not_link4[,2]))){
#       not_link3 <- matrix(not_link4[!is.na(not_link4[,2]),], ncol=3)
#       
#       ## inserting categories into db, if it's not already there
#       dbSendQuery(con, sprintf(
#         "INSERT OR IGNORE INTO 
#           wiki_category_name(name)
#           VALUES (%s)",
#         stri_flatten(prepare_string(unique(not_link3[,2]))
#                      , collapse = "), (")
#       )
#       )
#       # selectng categories id
#       id_cat <- dbGetQuery(con, sprintf("SELECT id, name from wiki_category_name
#                                           WHERE name IN (%s)", 
#                                         stri_flatten(prepare_string(not_link3[,2]),
#                                                      collapse = ", "))
#       )
#       
#       not_link3 <- data.frame(not_link3)
#       id_cat <- merge(not_link3, id_cat, by.x=names(not_link3)[2], by.y='name')
#       
#       #inserting categories
#       dbSendQuery(con, sprintf(
#         "INSERT INTO 
#           wiki_category_text(id_title, id_category)
#           VALUES (%s)",
#         stri_paste(
#           stri_paste(id_cat[,3], id_cat$id, sep=", "), 
#           collapse = "), (")
#       )
#       )
#       rm(not_link3, id_cat)
#     }
    ### removing all the [[x:y]] from the text
    
    text4 <- stri_replace_all_regex(text3, "\\[.+?\\]|zobacz też|linki zewnętrzne|bibliografia|przypisy", "")
    
    
    #############
    
    ### WORD INSERTING ###
    #print('words')
    #extracting all the words
    words_all  <- stri_extract_all_words(text4, omit_no_match = TRUE)     
    words_text <- lapply(seq_along(words_all), function(x){
      t <- table(words_all[x])
      cbind(as.numeric(t), names(t), id_from[x])  
    })
    
    m <- do.call(rbind, words_text)
    to_insert <- sprintf("(%s, %s, %s)", m[,3], prepare_string(m[,2]), m[,1])
    to_insert <- split(to_insert, rep(1:ceiling(length(to_insert)/500), length.out=length(to_insert)))          
    
    lapply(to_insert, function(to_insert) {
      dbExecQuery(con, sprintf("INSERT into tmp_word_freq(id_title, word, freq)
                               values %s", stri_flatten(to_insert, collapse=",")))
    })
    
             
  }
  
}

dbExecQuery(con, "insert into wiki_redirect (id_from, id_to)
            select y.id_from, x.id as id_to from tmp_redirect as y
            join
            wiki_page as x 
            on
            x.title=y.title_to")

dbExecQuery(con, "insert into wiki_link (id_from, id_to)
            select y.id_from, x.id as id_to from tmp_link as y
            join
            wiki_page as x 
            on
            x.title=y.title_to")


dbExecQuery(con, "insert or ignore into wiki_category_name (name)
            select distinct name from tmp_category_text")

dbExecQuery(con, "insert into wiki_category_text (id_title, id_category)
            select y.id_title, x.id as id_category from tmp_category_text as y
            join
            wiki_category_name as x 
            on
            x.name=y.name")



dbExecQuery(con, "insert or ignore into wiki_word (word)
            select distinct word from tmp_word_freq")

dbExecQuery(con, "insert into wiki_word_freq (id_title, id_word, freq)
            select y.id_title, x.id as id_word, y.freq as freq from tmp_word_freq as y
            join
            wiki_word as x 
            on
            x.word=y.word")

### DB DISCONNECT

dbDisconnect(conn)
dbDisconnect(con)

###################
