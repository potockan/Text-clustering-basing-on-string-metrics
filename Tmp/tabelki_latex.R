
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
  cc[[i]] <- c(skupienia2[(bb[i]+1):bb[i+1],i], rep(NA, 31))[1:31]
  
}

skupienia3 <- data.frame(cc)
names(skupienia3) <- names(skupienia2)

for(i in 1:ncol(skupienia3)){
  skupienia3[,i] <- as.character(skupienia3[,i])
  skupienia3[is.na(skupienia3[,i]),i] <- ""
}

aa <- xtable::xtable(skupienia3)
print(aa,  include.rownames = FALSE)


#####
liczn <- dbGetQuery(con, "select count(1) from wiki_hunspell_clust2 group by id_stem_word")

liczn <- summary(liczn$`count(1)`)
names(liczn)
liczn2 <- data.frame(t(matrix(liczn)))
names(liczn2) <- names(liczn)
xtable::xtable(liczn2, digits = 0)


dbDisconnect(con)


