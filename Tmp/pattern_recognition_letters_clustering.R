

###################################################################################################
############ clustering ############
#from article Pattern Recognition Letters

set.seed(128)
dimm <- 3
sam <- sample(1:n_no_stp, dimm)

ble <- stringdistmatrix(words[sam], words[sam], method = 'lv')
s  <- numeric(20)
for(i in 1:20)
  s[i] <- sum(ble[i,])
s <- s/19
mean(s)


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




### one group by another ###





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


