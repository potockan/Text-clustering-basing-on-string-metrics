library(RSQLite)
library(stringi)
library(compiler)
library(stringdist)
library(dplyr)

source("./R/db_exec.R")

con <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")

slowa <- dbGetQuery(con, "select b.id, b.word, count(a.id_stem_word) as cnt
           from wiki_hunspell_clust a
           join 
           wiki_word b
           on a.id_stem_word = b.id
           group by a.id_stem_word")


dbDisconnect(con)

#slowa2 <- slowa
slowa <- slowa2[1:100,]
slowa <- cbind(slowa, nowy_stem_id = slowa[,1], orig_word = slowa[,2])
method <- "jaccard"
mx <- 0.3
q <- 3

for(i in 1:nrow(slowa)){
  odl <- stringdist(slowa$word[i], slowa$word[-i], method = method, q = q)
  odl_min <- (odl < mx)
  if(any(odl_min)){
    ind_min_odl <- which(odl_min)
    ind_min_odl <- ifelse(ind_min_odl<i,0,1)+ind_min_odl
    indx <- sort(c(i,ind_min_odl))[which.max(slowa$cnt[sort(c(ind_min_odl,i))])]
    slowa$word[i] <- slowa$word[indx]
    slowa$nowy_stem_id[i] <- slowa$nowy_stem_id[indx]
  }
}


unique(slowa$nowy_stem_id) %>% length()
# lcs:
# 4: 49
# 3: 61
# 2: 79

# lv:
# 4: 35
# 3: 52
# 2: 71

# osa:
# 4: 35
# 3: 52
# 2: 71
