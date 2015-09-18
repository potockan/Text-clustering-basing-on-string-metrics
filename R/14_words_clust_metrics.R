#!/usr/bin/Rscript --vanilla

#install.packages("RSQLite")
library(RSQLite)

source("./R/db_exec.R")
### Worked text database ###

con <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")

slowa <- dbGetQuery(con, "select a.id_stem_word, a.freq, b.word
                    from
                    
                    (select id_stem_word, count(id_word) as freq
                    from wiki_hunspell_clust2_cosine
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


# wiki_hunspell_clust2
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 1.000   1.000   2.000   3.995   5.000  89.000 

# wiki_hunspell_clust2_lcs
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 1.000   2.000   4.000   5.778   8.000 217.000 

# wiki_hunspell_clust2_dl
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 1.000   2.000   4.000   5.778   8.000 217.000 

# wiki_hunspell_clust2_jaccard
# Min.   1st Qu.    Median      Mean   3rd Qu.      Max. 
# 1.000     2.000     4.000     5.727     8.000 18484.000

# wiki_hunspell_clust2_qgram
# Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
# 1.00     1.00     3.00     5.73     7.00 40701.00 

# wiki_hunspell_clust2_cosine
# Min.   1st Qu.    Median      Mean   3rd Qu.      Max. 
# 1.000     2.000     4.000     5.727     8.000 18500.000 

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

