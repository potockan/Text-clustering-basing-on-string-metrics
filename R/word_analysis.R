#install.packages('stringdist')
library(stringdist)
library(stringi)

word_stat <- 
  readRDS("./Data/RObjects/words_cnt.rds")
n_words <- nrow(word_stat)
n_once <- sum(word_stat$word_cnt==1)/n_words*100

n_articles <- readRDS("./Data//RObjects//n_articles.rds")
# 
# word_stat_all <- 
#   readRDS("./Data/RObjects/words_cnt_all.rds")
# n_words_all <- nrow(word_stat_all)
# n_once_all <- sum(word_stat_all$word_cnt==1)/n_words_all*100
#
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

ble <- stringdistmatrix(words[sam], words[sam], method = 'lv')
s  <- numeric(20)
for(i in 1:20)
  s[i] <- sum(ble[i,])
s <- s/19
mean(s)


set.seed(128)
dimm <- 3
sam <- sample(1:n_no_stp, dimm)
nclust <- 20
dist_lv2 <- stringdistmatrix(words, words[sam], method = 'lv')
kmeans_lv <- kmeans(dist_lv2, centers=nclust, iter.max=20)



dist_lv3 <- numeric(0)
for(i in 1:20)
  dist_lv3 <- c(dist_lv3, 
                stringdist(words, words[sam[i]], method = 'lv'))
dist_lv3 <- matrix(dist_lv3, ncol=20, byrow=FALSE)




# simmilar <- which(dist_lv[1,]<=6)
# 
# unsimmilar <- numeric(20)
# for(i in 1:20)
#   unsimmilar[i] <- sum(which(dist_lv[1])>6)
# sum(simmilar)
# 
# w <- dist_lv2[,1:10]
# kmeans_lv <- kmeans(w, centers=20)
# unique(w)

euc_dist <- function(x1, x2) sqrt(sum((x1 - x2) ^ 2))
clust_means <- numeric(nclust)
for(j in 1:nclust){
  cl <- which(kmeans_lv$cluster==j)
  coor <- kmeans_lv$centers[j,]

  min_euc <- c(euc_dist(coor, dist_lv2[cl[1],]), 1)
  for(i in 2:length(cl)){
    euc <- euc_dist(coor, dist_lv2[cl[i],])
    if(euc<min_euc[1]){
      min_euc <- c(min(min_euc, euc), cl[i])
    }
    
  }
  clust_means[j] <- min_euc[2]
}




#########################################

######### word order #########
### one by one ###
method <- 'lv'
used <- 1
dist_index <- which.min(stringdist(words[-used], words[1], method = method))
words_order <- words[c(1,distances)]
for(i in 2:n_no_stp){
  used <- c(used, dist_index)
  distances <- which.min(stringdist(words[-used], words[dist_index], method = method))
  words_order <- c(words_order, words[dist_index])
}









#########################################

########### two nearest points ##########
cl_1 <- which(kmeans_lv$cluster==1)
coor_1 <- kmeans_lv$centers[1,]
euc_dist <- function(x1, x2) sqrt(sum((x1 - x2) ^ 2))
min_euc <- c(euc_dist(coor_1, dist_lv2[cl_1[1],]), 1)
min_euc2 <- min_euc
for(i in 2:length(cl_1)){
  euc <- euc_dist(coor_1, dist_lv2[cl_1[i],])
  if(euc<min_euc[1]){
    min_euc2 <- min_euc
    min_euc <- c(min(min_euc, euc), cl_1[i])
  }
  
}



