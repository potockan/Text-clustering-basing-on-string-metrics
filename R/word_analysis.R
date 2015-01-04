install.packages('stringdist')
library(stringdist)
library(stringi)

word_stat <- 
  readRDS("./Data/RObjects/words_cnt.rds")
n_words <- nrow(word_stat)
n_once <- sum(word_stat$word_cnt==1)/n_words*100

n_articles <- readRDS("./Data//RObjects//n_articles.rds")

word_stat_all <- 
  readRDS("./Data/RObjects/words_cnt_all.rds")
n_words_all <- nrow(word_stat_all)
n_once_all <- sum(word_stat_all$word_cnt==1)/n_words_all*100

# set.seed(208)
# sample(word_stat$word[word_stat$word_cnt==1], 10)
# 
# top10 <- head(word_stat, 10)
# top10 <- cbind(top10, top10[,1])[,-1]
# top10_all <- numeric(10)
# for(i in 1:length(top10[,1])){
#   top10_all[i] <- word_stat_all$word_cnt_all[which(word_stat_all$word==top10[i,1])]
# }
# top10 <- cbind(top10, top10_all)
# names(top10) <- c("Słowo", "Liczba artykułów", "Liczba wystąpień słowa")

stopwords <- as.vector(read.table("./Data//RObjects//stopwords2.txt", sep="")[,1])

words <- c(word=setdiff(word_stat$word, 
                                 c(stopwords, word_stat$word[2806173:2806765])))
words <- words[-(which(stri_length(words)==1))]
#word_no_stp <- merge(word_stat, words)
n_no_stp <- length(words)

############ clustering ############

set.seed(125)
sam <- sample(1:n_no_stp, 20)

dist_lv <- stringdistmatrix(words[sam], words, method = 'lv')
dist_lv2 <- t(dist_lv)
mean(dist_lv)
max(dist_lv)
#max(stri_length(words[sam]))


kmeans_lv <- kmeans(dist_lv2, centers=dist_lv2[sam,], iter.max=3)
simmilar <- which(dist_lv[1,]<=6)

unsimmilar <- numeric(20)
for(i in 1:20)
unsimmilar[i] <- sum(which(dist_lv[1])>6)
sum(simmilar)

w <- dist_lv2[,1:3]
kmeans_lv <- kmeans(w, centers=20)
unique(w)







