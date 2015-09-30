#!/usr/bin/Rscript --vanilla

#install.packages("RSQLite")
library(RSQLite)
library(stringdist)
library(compiler)
library(dplyr)
library(stringi)

source("./R/db_exec.R")
prepare_string <- cmpfun(function(str) {
  stri_paste("'", stri_replace_all_fixed(str, "'", "''"), "'")
})
### Worked text database ###

con <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")


categ <- dbGetQuery(con, '
                    select 
                    a.id_category, b.name 
                    from 
                    wiki_unique_category a

                    join

                    wiki_category_name b
                    on 
                    b.id = a.id_category
                    ')

categ %>% 
  group_by(id_category) %>% 
  mutate(l_art = n()) %>% 
  arrange(l_art)-> categ

summary(categ$l_art)
summary(categ$l_art[categ$l_art < 5000])
boxplot(categ$l_art)
boxplot(categ$l_art[categ$l_art < 5000])

categ_low <- categ[categ$l_art < 100,] %>% arrange(l_art)

summary(categ_low$l_art)
boxplot(categ_low$l_art)




