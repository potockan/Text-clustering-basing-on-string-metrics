
### new
### stemmed: 473496 / 1019320 == 46.45 %
### 430401 Polish words
### 27274 == 457675 - 430401 English words
### 8126 == 465801 - 457675 French words
### 7695 == 473496 - 465801 German words


aa <- data.frame(jezyk = c("polski", "angielski", "francuski", "niemiecki"),
                 liczba = c("430 401", "27 274", "8 126",  "7 695"))

aa[,1] <- as.character(aa[,1])
aa[,2] <- as.character(aa[,2])
aa <- rbind(aa, c("ogolem", "473 496"))

aa <- cbind(aa, procent = c("42,2%", "2,7%", "0,8%", "0,8%", "46,5%"))

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

skupienia <- skupienia %>% filter(!(word %in% c("nawet", "zarówno", "swoich", "mimo", "bardziej", "gdyż")))

skupienia <- skupienia %>% select(word, word2)
skupienia2 <- skupienia %>% spread(word, word2)
wschód <- as.character(skupienia2$średnia)
skupienia2 %>% select(-średnia) %>% cbind(wschód = as.character(wschód)) -> skupienia2

bb <- cumsum(c(0,apply(skupienia2, 2, function(x) sum(!is.na(x)))))
l <- max(bb)

cc <- list()
for(i in 1:(length(bb)-1)){
  cc[[i]] <- as.character(skupienia2[(bb[i]+1):bb[i+1],i])#, rep("", 27))[1:27]
  
}

# skupienia3 <- data.frame(cc)
# names(skupienia3) <- names(skupienia2)
# 
# for(i in 1:ncol(skupienia3)){
#   skupienia3[,i] <- as.character(skupienia3[,i])
#   skupienia3[is.na(skupienia3[,i]),i] <- ""
# }
# 
# aa <- xtable::xtable(skupienia3)
# print(aa,  include.rownames = FALSE)


skupienia4 <- lapply(cc, stri_flatten, collapse = ", ")
skupienia4 <- data.frame(reprezentant = names(skupienia2), slowa = matrix(skupienia4))
aa <- xtable::xtable(skupienia4)
print(aa,  include.rownames = FALSE, hline.after = 0:nrow(aa))

#################
liczn <- dbGetQuery(con, "select count(1) from wiki_hunspell_clust2 group by id_stem_word")

liczn <- summary(liczn$`count(1)`)
names(liczn)
liczn2 <- data.frame(t(matrix(liczn)))
names(liczn2) <- names(liczn)
xtable::xtable(liczn2, digits = 0)


##################




skupienia <- data.frame(zbior = c("clust", "clust_lcs", "clust_dl",  "clust_jw", "clust_jac", "clust_qg", 
                                  "clust_red_lcs", "clust_red_dl", "clust_red_jw", "clust_red_jac", "clust_red_qg", 
                                  "clust_lcs_red_lcs", "clust_dl_red_dl", "clust_jw_red_jw", "clust_jac_red_jac", "clust_qg_red_qg"),
                        liczba_skupien = c(
                          rep("137 223", 6),
                          rep("33 403", 5),
                          "73 101", "78 354", "79 255", "74 642", "61 915"
                        ),
                        redukcja = c(rep("86,5%", 6),
                                     rep("96,7%", 5),
                                     "92,8%", "92,3%", "92,2%", "92,7%", "93,9%"),
                        liczba_slow = c(
                          rep("976 691", 6),
                          rep("473 500", 5),
                          rep("976 691", 5)
                        ),
                        procent_wszystkich = c(
                          rep("95,8%", 6),
                          rep("46,5%", 5),
                          rep("95,8%", 5)
                        )
)

print(xtable::xtable(skupienia),  hline.after = c(0, 6, 11, 16))

#################
dbListTables(con)

dbGetQuery(con, "select count(distinct id_category) from wiki_unique_category")
dbGetQuery(con, "select count(distinct id_new) from wiki_category_after_reduction")
dbGetQuery(con, "select count(distinct id_new) from wiki_category_after_reduction2")

dbDisconnect(con)

################

wyciagnij <- function(table, stem_words) {
  
  dbGetQuery(con, sprintf("select *
           from wiki_hunspell_clust2%s a
           join 
           wiki_word b
           on a.id_stem_word = b.id
           join 
           wiki_word c
           on a.id_word = c.id
           where a.id_stem_word in (%s)",
                          table, stri_flatten(stem_words, collapse = ", ")))
}

sk1 <- wyciagnij("", stem_words)
sk2 <- wyciagnij("_lcs", stem_words)
sk3 <- wyciagnij("_dl", stem_words)
sk4 <- wyciagnij("_jw", stem_words)
sk5 <- wyciagnij("_jaccard", stem_words)
sk6 <- wyciagnij("_qgram", stem_words)

sk7 <- wyciagnij("_red_lcs", stem_words)
sk8 <- wyciagnij("_red_dl", stem_words)
sk9 <- wyciagnij("_red_jw", stem_words)
sk10 <- wyciagnij("_red_jaccard", stem_words)
sk11 <- wyciagnij("_red_qgram", stem_words)

sk12 <- wyciagnij("_red_lcs_lcs", stem_words)
sk13 <- wyciagnij("_red_dl_dl", stem_words)
sk14 <- wyciagnij("_red_jw_jw", stem_words)
sk15 <- wyciagnij("_red_jaccard_jaccard", stem_words)
sk16 <- wyciagnij("_red_qgram_qgram", stem_words)

