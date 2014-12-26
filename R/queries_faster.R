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


# i <- 15
# aa <-
# dbGetQuery(conn, sprintf("select * from wiki_raw 
#            where id = %d", i))
cnt <- 10
for(i in 1:10){
# for(i in 1: 1654533){
  print(i*cnt)
  aa <-
    dbGetQuery(conn, sprintf("select id, title, text, redirect from wiki_raw 
                             where id between %d and %d and ns=0", (i-1)*cnt+1, i*cnt))
  #   index <- dbGetQuery(conn, "select count(id) from wiki_raw 
  #                            where redirect!='NA'")
  
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
      print('redirect')
      aa_red <- aa[red_not_na,]
      redirect <- prepare_string(aa_red$redirect)
#       id_to <- dbGetQuery(conn, sprintf("
#                                         SELECT id, title
#                                         FROM wiki_raw 
#                                         INDEXED BY my_index
#                                         WHERE title in (%s)", 
#                                         stri_flatten(redirect, collapse = ", ")))
#       id_to <- merge(aa_red, id_to, by.x='redirect', by.y='title')
     # if(nrow(id_to>0))
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
      
      print('page')
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
      
      # #extracting all the tags and all the content within curly brackets to save it in the DB
      # (tags <- stri_extract_all_regex(text, "<.*?>(.)*?<.*?>")[[1]])
      # (curly <- stri_extract_all_regex(text, "\\{\\{[^\\}]*?\\}\\}")[[1]])
      
      
      #removing all the comment, tags and all the content within curly brackets
      #TO DO: zapetlone nie dzialaja!
      patterns <- c("<([a-zA-Z][a-zA-Z0-9]*).*?>.*?</\\1>", 
                    "\\{\\{[^\\}]*?\\}\\}", "<!--.*?-->")
      
      
      text2 <- stri_replace_all_regex(text, patterns , "", vectorize_all = FALSE)
      #patterns <- c(patterns, "<(.+?)>[^<]*?</(.+?)>")
      #text2 <- stri_replace_all_regex(text2, patterns , "", vectorize_all = FALSE)
      #text2 <- stri_replace_all_regex(text2, patterns , "", vectorize_all = FALSE)
          
      
      rm(patterns, text)
      
      
      #################################################
      ### LINKS ###
      ##[[x|y]] (x is the link, y the string to be viewed) or [[x]] (x is both)
      
      print('links')
#       stri_match_all_regex("[[ala: gowno|fknsel]]", "\\[\\[([^:|]+?)(?:(?:(?:: )|(?:\\|))([^|]+?))?\\]\\]")
      links <- stri_match_all_regex(text2, "\\[\\[([^:|]+?)(?:\\|([^|]+?))?\\]\\]")
      dl <- sapply(links, length)
      
#       #extractng all the links 
#       link <- stri_extract_all_regex(text2, "\\[\\[([^:\\]]+?:\\s(.)+?|[^:\\]]+?)\\]\\]")
#       link2 <- lapply(link, function(link){
#         if(any(!is.na(link))){
#           #matching those with pipe and without it
#           link2 <- stri_match_all_regex(link, "\\[\\[([^\\|]+)\\|?+([^\\|]*?)\\]\\]")
#         }})
#       dl <- unlist(lapply(link2, length))  
#       
      if(any(dl>0)){
        
        #transformation to matrix
        m <- cbind(matrix(unlist(link2), ncol=3, byrow = TRUE), rep(id_from, times=dl))
        m <- matrix(m[which(!is.na(m[,1])),], ncol=4)
        dup <- which(duplicated(m[,c(1,4)]))
        if(length(dup)>0)
          m <- m[-dup,]
        
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
          rm(hash_m)
        }
        
        # leaving only the links that lead to other pages
        m2 <- matrix(m[which(stri_length(m[,2])>0),], ncol=4)
        m3 <- unique(m2[,2])
        
        if(length(m3)>0){
          #extracting id's where we link to
          id_to <- dbGetQuery(conn, 
                              sprintf("SELECT id, title 
                                      FROM wiki_raw 
                                      INDEXED BY my_index 
                                      WHERE title in (%s)", 
                                      stri_flatten( prepare_string(m3), collapse = ", ")
                              )
          )
          
          m4 <- merge(x=as.data.frame(m2), y=id_to, by.x="V2", by.y="title")
          
          #inserting links
          n_links <- nrow(m4)
          #inserting max 500 at once - sqlite limit
          if(n_links>500){
            for(j in 1:floor(n_links/500)){
              dbSendQuery(con, sprintf(
                "INSERT INTO 
                wiki_link(id_from, id_to)
                VALUES (%s)",
                stri_paste(
                  stri_paste(m4[((j-1)*500+1) : (j*500),"V4"], m4[((j-1)*500+1) : (j*500), "id"], sep=", "), 
                  collapse = "), (")
              )
              )
              
              
              
            }
            
          }else
            j <- 0
          mod_links <- n_links%%500
          if(mod_links>0)
            dbSendQuery(con, sprintf(
              "INSERT INTO 
              wiki_link(id_from, id_to)
              VALUES (%s)",
              stri_paste(
                stri_paste(m4[(j*500+1) : (j*500+mod_links),"V4"], m4[(j*500+1) : (j*500+mod_links), "id"], sep=", "), 
                collapse = "), (")
            )
            )
        }
        
        
        
        ################################################
        ### LINKS: NOT-LINKS ###
        
        #those that had only [[x]] we want to replace with x (in the text)
        #[[x|y]] we want to replace with y
        no_string <- which(stri_length(m[,3])==0)
        m[no_string,3] <- m[no_string, 2]
        m <- m[which(!is.na(m[,3])),]
        
        ### removing all [[x]] and [[x|y]] from the text
        text3 <- stri_replace_all_fixed(text2, m[,1], m[,3], 
                                        vectorize_all=FALSE)
        
        rm(dl, m, hashtag, m2, m3, id_to, m4, n_links, mod_links, no_string)
      }else
        text3 <- text2
      rm(link, link2, text2)
      
      
      
      
      ###########################################
      
      ### CATEGORIES ###
      print('categories')
      # not links: [[x:y]] - we want y only if x is "kategoria"
      
      #extractng all the not-links 
      not_link <- stri_extract_all_regex(text3, "\\[\\[[^:\\]]+?:\\S[^:]+?\\]\\]")
      
      
      
      #matching those with "kategoria"
      not_link2 <- lapply(not_link, function(not_link){
        stri_match_all_regex(not_link, "\\[\\[kategoria:([^\\|]+)\\|{0,1}[^\\|]*?\\]\\]")
      })
      dl <- unlist(lapply(not_link2, length))  
      not_link2 <- unlist(not_link2)
      not_link4 <- cbind(matrix(not_link2, ncol=2, byrow=TRUE), rep(id_from, times=dl))
      if(any(!is.na(not_link4[,2]))){
        not_link3 <- matrix(not_link4[!is.na(not_link4[,2]),], ncol=3)
        
        ## inserting categories into db, if it's not already there
        dbSendQuery(con, sprintf(
          "INSERT OR IGNORE INTO 
          wiki_category_name(name)
          VALUES (%s)",
          stri_flatten(prepare_string(unique(not_link3[,2]))
                       , collapse = "), (")
        )
        )
        # selectng categories id
        id_cat <- dbGetQuery(con, sprintf("SELECT id, name from wiki_category_name
                                          WHERE name IN (%s)", 
                                          stri_flatten(prepare_string(not_link3[,2]),
                                                       collapse = ", "))
        )
        
        not_link3 <- data.frame(not_link3)
        id_cat <- merge(not_link3, id_cat, by.x=names(not_link3)[2], by.y='name')
        
        #inserting categories
        dbSendQuery(con, sprintf(
          "INSERT INTO 
          wiki_category_text(id_title, id_category)
          VALUES (%s)",
          stri_paste(
            stri_paste(id_cat[,3], id_cat$id, sep=", "), 
            collapse = "), (")
        )
        )
        rm(not_link3, id_cat)
      }
      ### removing all the [[x:y]] from the text
      if(any(!is.na(not_link))){
        not_link <- unlist(not_link)
        #doesn't work
        #text4 <- stri_replace_all_fixed(text3, c(not_link[!is.na(not_link)], "zobacz też", "linki zewnętrzne", "bibliografia", "przypisy", "\\[.+?\\]"), "", vectorize_all = FALSE)
        text4 <- stri_replace_all_fixed(text3, c(not_link[!is.na(not_link)], "zobacz też", "linki zewnętrzne", "bibliografia", "przypisy"), "", vectorize_all = FALSE)
        text4 <- stri_replace_all_regex(text4, "\\[.+?\\]", "")
      }else{
        text4 <- stri_replace_all_fixed(text3, c("zobacz też", "linki zewnętrzne", "bibliografia", "przypisy", "\\[.+?\\]"), "", vectorize_all = FALSE)
        text4 <- stri_replace_all_regex(text4, "\\[.+?\\]", "")
      }
      rm(not_link, not_link2, not_link4, text3)
      
      
      #############
      
      ### WORD INSERTING ###
      print('words')
      #extracting all the words
      words_all  <- stri_extract_all_words(text4)     
      
      #unique words
      words <- prepare_string(unique(unlist(words_all)))
      words <- words[!is.na(words)]
      
      n_words <- length(words)
      if(n_words>500){
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
      }else
        j <- 0
      mod_words <- n_words%%500
      if(mod_words>0){
        dbSendQuery(con, sprintf(
          "INSERT OR IGNORE INTO 
          wiki_word(word)
          VALUES (%s)",
          stri_flatten(words[(j*500+1) : (j*500+mod_words%%500)], collapse = "), (")
        )
        )
      }
      id_word <- dbGetQuery(con, sprintf("SELECT id, word from wiki_word
                                         WHERE word IN (%s)", 
                                         stri_flatten(words,
                                                      collapse = ", "))
      )
      
      rm(words, n_words, mod_words)
      
      
      
      ### WORD COUNTING ###
      print('words counting')
      #counting a number of words that occur in the text
      words_text <- lapply(words_all, function(x){ table(x) })
      rm(words_all)
      dl <- unlist(lapply(words_text, length))
      words_text1 <- data.frame()
      for(j in 1:length(dl)){
        words_text1 <- rbind(words_text1, cbind(as.data.frame(words_text[j]), id=rep(id_from, dl[j])))
      }
      
      
      words_text1 <- merge(words_text1, id_word, by.x='x', by.y='word')
      
      rm(words_text, dl, id_word)
      
      #inserting into db
      n_words_text <- nrow(words_text1)
      if(n_words_text>500){
        for(j in 1:floor(n_words_text/500))
        {
          
          ind <- ((j-1)*500+1) : (j*500)
          
          dbSendQuery(con, sprintf(
            "INSERT INTO 
            wiki_word_freq(id_title, id_word, freq)
            VALUES (%s)",
            stri_paste(
              stri_paste(words_text1$id.x[ind], words_text1$id.y[ind], words_text1$Freq[ind], sep=", "), 
              collapse = "), (")
          )
          )
          
          
        }
      }else
        j <- 0
      mod_words_text <- n_words_text%%500
      if(mod_words_text>0){
        ind <- (j*500+1) : (j*500+mod_words_text)
        dbSendQuery(con, sprintf(
          "INSERT INTO 
          wiki_word_freq(id_title, id_word, freq)
          VALUES (%s)",
          stri_paste(
            stri_paste(words_text1$id.x[ind], words_text1$id.y[ind], words_text1$Freq[ind], sep=", "), 
            collapse = "), (")
        )
        )
        
      }
      
      rm(n_words_text, mod_words_text, ind)
      
      ################################
      
    }
  
}

dbExecQuery(con, "insert into wiki_redirect (id_from, id_to)
            select y.id_from, x.id as id_to from tmp_redirect as y
            join
            wiki_page as x 
            on
            x.title=y.title_to")


### DB DISCONNECT

dbDisconnect(conn)
dbDisconnect(con)

###################
