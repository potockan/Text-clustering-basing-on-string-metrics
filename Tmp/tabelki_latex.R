
### 677 444 Polish words
### 41 087 == 705402 - 664315 English words
### 20 438 == 725840 - 705402 French words
### 21 117 == 746957 - 725840 German words

aa <- data.frame(jezyk = c("polski", "angielski", "niemiecki", "francuski"),
                 liczba = c("677 444", "41 087", "21 117", "20 438"))

aa[,1] <- as.character(aa[,1])
aa[,2] <- as.character(aa[,2])
aa <- rbind(aa, c("ogolem", "733 828"))

aa <- cbind(aa, procent = c(24.2, 1.5, 0.8, 0.7, 27.1))

xtable::xtable(aa)


# wykresy gdzie jest 3x13 slupkow - 
# po jednym na rozne licznosci zbioru, 
# po 3 na zbior.
# takich wykresow mozna zrobic od 3 do 6
library(RSQLite)
library(tidyr)
library(stringi)
library(dplyr)

con <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")

dbGetQuery(con, "select distinct id_stem_word from wiki_hunspell_clust2 limit 20")[,1] -> stem_words

skupienia <- dbGetQuery(con, sprintf("select *
           from wiki_hunspell_clust2 a
           join 
           wiki_word b
           on a.id_stem_word = b.id
           join 
           wiki_word c
           on a.id_word = c.id
           where a.id_stem_word in (%s)",
                        stri_flatten(stem_words, collapse = ", ")))
names(skupienia)[c(5,6)] <- c("id2", "word2")
skupienia <- skupienia %>% arrange(id_stem_word)

skupienia <- skupienia %>% filter(!(word %in% c("de", "nad", "np", "roku", "też", "the", "który", "wiele", "miasta", "jednym", "wśród")))

skupienia <- skupienia %>% select(word, word2)
skupienia2 <- skupienia %>% spread(word, word2)

bb <- cumsum(c(0,apply(skupienia2, 2, function(x) sum(!is.na(x)))))
l <- max(bb)

cc <- list()
for(i in 1:(length(bb)-1)){
  cc[[i]] <- c(skupienia2[(bb[i]+1):bb[i+1],i])#, rep(NA, 31))[1:31]
  
}

skupienia3 <- data.frame(cc)
names(skupienia3) <- names(skupienia2)

for(i in 1:ncol(skupienia3)){
  skupienia3[,i] <- as.character(skupienia3[,i])
  skupienia3[is.na(skupienia3[,i]),i] <- ""
}

aa <- xtable::xtable(skupienia3)
print(aa,  include.rownames = FALSE)


skupienia4 <- lapply(cc, stri_flatten, collapse = ", ")
skupienia4 <- data.frame(reprezentant = names(skupienia2), slowa = matrix(skupienia4))
aa <- xtable::xtable(skupienia4)
print(aa,  include.rownames = FALSE)

#################
liczn <- dbGetQuery(con, "select count(1) from wiki_hunspell_clust2 group by id_stem_word")

liczn <- summary(liczn$`count(1)`)
names(liczn)
liczn2 <- data.frame(t(matrix(liczn)))
names(liczn2) <- names(liczn)
xtable::xtable(liczn2, digits = 0)



##################
skupienia <- data.frame(zbior = c("clust", "clust_lcs", "clust_dl", "clust_jaccard", "clust_qgram", 
                     "clust_red_lcs", "clust_red_dl", "clust_red_jaccard", "clust_red_qgram", 
                     "clust_lcs_red_lcs", "clust_dl_red_dl", "clust_jaccard_red_jaccard", "clust_qgram_red_qgram"),
           liczba_skupien = c(
             rep("186 958", 5),
             rep("43 919", 4),
             "65 350", "66 378", "69 570", "62 434"
           ),
           redukcja = c(rep("6.6%", 5),
                        rep("98.4%", 4),
                        "97.7%", "97.6%", "97.5%", "97.8%"),
           liczba_slow = c(
             "746 957", "1 080 260", "1 080 260", "1 070 750", "1 070 750",
             "743 053", "743 053", "739 338", "739 338",
             "1 037 393", "1 060 474", "1 063 131", "1 063 131"
           ),
           procent_wszystkich = c(
             "27%", "38%", "38%", "38%", "38%", 
             "26%", "26%", "26%", "26%", 
             "37%", "38%", "38%", "38%"
           )
           )

xtable::xtable(skupienia)

#################
dbListTables(con)

dbGetQuery(con, "select count(distinct id_category) from wiki_unique_category")
dbGetQuery(con, "select count(distinct id_new) from wiki_category_after_reduction")
dbGetQuery(con, "select count(distinct id_new) from wiki_category_after_reduction2")

dbDisconnect(con)

