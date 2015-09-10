#!/usr/bin/Rscript --vanilla

#install.packages("RSQLite")
library(RSQLite)

source("./R/db_exec.R")
### Worked text database ###

con <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")

slowa <- dbGetQuery(con, "select a.id_stem_word, a.freq, b.word
                    from
                    
                    (select id_stem_word, count(id_word) as freq
                    from wiki_hunspell_clust2
                    group by id_stem_word) a
                    
                    join
                    
                    wiki_word b

                    on a.id_stem_word = b.id
                    ")

repr <- dbGetQuery(con, "select a.id_stem_word, a.id_word, b.word
                    from
                    
                    (select id_stem_word, id_word
                    from wiki_hunspell_clust2
                    where id_stem_word = 2781371) a
                    
                    join
                    
                    wiki_word b

                    on a.id_word = b.id
                    ")

#slowa2 <- slowa
slowa <- slowa2[1:100,]
slowa <- cbind(slowa, nowy_stem_id = slowa[,1], orig_word = slowa[,2])
method <- "lv"
mx <- 3
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

