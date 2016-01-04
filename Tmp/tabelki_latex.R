
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


con <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")



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

dbGetQuery(con, "select distinct id_stem_word from wiki_hunspell_clust2 limit 20")[,1] -> stem_words

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


# cat(c(paste0('names(sk',1:16, ')[5:6] <-  c("id2", "word2")')), sep = "\n")
names(sk1)[5:6] <-  c("id2", "word2")
names(sk2)[5:6] <-  c("id2", "word2")
names(sk3)[5:6] <-  c("id2", "word2")
names(sk4)[5:6] <-  c("id2", "word2")
names(sk5)[5:6] <-  c("id2", "word2")
names(sk6)[5:6] <-  c("id2", "word2")
names(sk7)[5:6] <-  c("id2", "word2")
names(sk8)[5:6] <-  c("id2", "word2")
names(sk9)[5:6] <-  c("id2", "word2")
names(sk10)[5:6] <-  c("id2", "word2")
names(sk11)[5:6] <-  c("id2", "word2")
names(sk12)[5:6] <-  c("id2", "word2")
names(sk13)[5:6] <-  c("id2", "word2")
names(sk14)[5:6] <-  c("id2", "word2")
names(sk15)[5:6] <-  c("id2", "word2")
names(sk16)[5:6] <-  c("id2", "word2")

sl1 <- list(
  sk1$word2[sk1$word == "niemiecki"],
  sk2$word2[sk2$word == "niemiecki"],
  sk3$word2[sk3$word == "niemiecki"],
  sk4$word2[sk4$word == "niemiecki"],
  sk5$word2[sk5$word == "niemiecki"],
  sk6$word2[sk6$word == "niemiecki"],
  sk7$word2[sk7$word == "niemiecki"],
  sk8$word2[sk8$word == "niemiecki"],
  sk9$word2[sk9$word == "niemiecki"],
  sk10$word2[sk10$word == "niemiecki"],
  sk11$word2[sk11$word == "niemiecki"],
  sk12$word2[sk12$word == "niemiecki"],
  sk13$word2[sk13$word == "niemiecki"],
  sk14$word2[sk14$word == "niemiecki"],
  sk15$word2[sk15$word == "niemiecki"],
  sk16$word2[sk16$word == "niemiecki"]
)


sl2 <- list(
  sk1$word2[sk1$word == "praca"],
  sk2$word2[sk2$word == "praca"],
  sk3$word2[sk3$word == "praca"],
  sk4$word2[sk4$word == "praca"],
  sk5$word2[sk5$word == "praca"],
  sk6$word2[sk6$word == "praca"],
  sk7$word2[sk7$word == "praca"],
  sk8$word2[sk8$word == "praca"],
  sk9$word2[sk9$word == "praca"],
  sk10$word2[sk10$word == "praca"],
  sk11$word2[sk11$word == "praca"],
  sk12$word2[sk12$word == "praca"],
  sk13$word2[sk13$word == "praca"],
  sk14$word2[sk14$word == "praca"],
  sk15$word2[sk15$word == "praca"],
  sk16$word2[sk16$word == "praca"]
)

sl3 <- list(
  sk1$word2[sk1$word == "okres"],
  sk2$word2[sk2$word == "okres"],
  sk3$word2[sk3$word == "okres"],
  sk4$word2[sk4$word == "okres"],
  sk5$word2[sk5$word == "okres"],
  sk6$word2[sk6$word == "okres"],
  sk7$word2[sk7$word == "okres"],
  sk8$word2[sk8$word == "okres"],
  sk9$word2[sk9$word == "okres"],
  sk10$word2[sk10$word == "okres"],
  sk11$word2[sk11$word == "okres"],
  sk12$word2[sk12$word == "okres"],
  sk13$word2[sk13$word == "okres"],
  sk14$word2[sk14$word == "okres"],
  sk15$word2[sk15$word == "okres"],
  sk16$word2[sk16$word == "okres"]
)

nazwy <- c('clust', 
           'clust_lcs', 
           'clust_dl',
           'clust_jw', 
           'clust_jac',
           'clust_qg',
           
           'clust_red_lcs',
           'clust_red_dl',
           'clust_red_jw',
           'clust_red_jac',
           'clust_red_q',
           
           'clust_lcs_red_lcs',
           'clust_dl_red_dl',
           'clust_jw_red_jw',
           'clust_jac_red_jac',
           'clust_qg_red_qg')

names(sl1) <- nazwy
names(sl2) <- nazwy
names(sl3) <- nazwy

tab <- data.frame()

for(i in 1:16)
  tab <- bind_rows(tab, 
                   data.frame(typ = nazwy[i] , 
                              slowa = as.character(stri_flatten(as.character(sl3[[i]]), collapse = ", "))))

print(xtable::xtable(tab), hline.after = 0:16, include.rownames = FALSE)



dbDisconnect(con)


######################

library(ggplot2)
library(gridExtra)

set.seed(23454)
dane <- data.frame(x = c(rnorm(10, 3, 0.2),rnorm(10,4,0.4)-0.5),
                   y = c(rnorm(10, 2, 0.5),rnorm(10,3,0.7)),
                   typ = c(rep(1, 10), rep(2,10)),
                   l = rep(7, 20))
dane$x[c(3,10)] <- dane$x[c(3,10)]-0.25

gg <- ggplot() + 
  geom_point(data = dane, aes(x = x, 
                              y = y, col = factor(typ), 
                              shape = factor(typ),
                              size = l))


mx <- 0
mx_i <- 0
mx_j <- 0
mn <- 10
mn_i <- 0
mn_j <- 0
for(i in 1:10){
  odl <- sqrt((dane$x[i] - dane$x[11:20])^2 + 
                (dane$y[i] - dane$y[11:20])^2)
  mxx <- odl[which.max(odl)]
  print(mxx)
  if(mxx > mx){
    mx <- mxx
    mx_i <- i
    mx_j <- which.max(odl)
  }
  print(mx_i)
  print(mx_j)
  mnn <- odl[which.min(odl)]
  if(mnn < mn){
    mn <- mnn
    mn_i <- i
    mn_j <- which.max(odl)
  }
}



dane2 <- data.frame(x1 = c(dane$x[mn_i], 
                           dane$x[mx_i], 
                           mean(dane$x[1:10]), 
                           median(dane$x[1:10])), 
                    x2 = c(dane$x[mn_j+10], 
                           dane$x[mx_j+10], 
                           mean(dane$x[11:20]), 
                           median(dane$x[11:19])),
                    y1 = c(dane$y[mn_i], 
                           dane$y[mx_i], 
                           mean(dane$y[1:10]), 
                           median(dane$y[1:10])), 
                    y2 = c(dane$y[mn_j+10], 
                           dane$y[mx_j+10], 
                           mean(dane$y[11:20]), 
                           median(dane$y[11:19])))

dane2[1,] %>% geom_line(data = ., aes(x = c(x1,x2), y = c(y1,y2))) -> tt1
dane2[2,] %>% geom_line(data = ., aes(x = c(x1,x2), y = c(y1,y2))) -> tt2
dane2[3,] %>% geom_line(data = ., aes(x = c(x1,x2), y = c(y1,y2))) -> tt3
dane2[4,] %>% geom_line(data = ., aes(x = c(x1,x2), y = c(y1,y2))) -> tt4

guides(shape = FALSE, col = FALSE)

grid.arrange(gg + tt1 + guides(size = FALSE, col = FALSE, shape = FALSE) + ggtitle("Najblizszy"), 
             gg + tt2 + guides(size = FALSE, col = FALSE, shape = FALSE) + ggtitle("Najdalszy"), 
             gg + tt3 + guides(size = FALSE, col = FALSE, shape = FALSE) + ggtitle("Centroid"), 
             gg + tt4 + guides(size = FALSE, col = FALSE, shape = FALSE) + ggtitle("Mediany"), 
             nrow = 2, ncol = 2)



