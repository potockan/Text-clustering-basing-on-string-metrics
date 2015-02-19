library(stringdist)
library(stringi)

word_stat <- 
  readRDS("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/words_cnt.rds")
stopwords <- as.vector(read.table("/dragon/Text-clustering-basing-on-string-metrics/Data//RObjects//stopwords2.txt", sep="")[,1])

words <- c(word=setdiff(word_stat$word, 
              c(stopwords, word_stat$word[2806173:2806765])))


words <- words[-(which(stri_length(words)==1))]
n_no_stp <- length(words)


######### word order #########
### one by one ###

#making an order on words such that the first has small distances to the second, the second to the third...
#without repetition of words
# method <- 'lv'
# N <- 1000
# 
# used <- numeric(n_no_stp)
# used <- 1
# #word closest to the first one
# dist_index <- which.min(stringdist(words[-used], words[1], method = method))
# 
# for(i in 2:N){
#   used[i] <- which(words==words[-used][dist_index])
#   #word closest to the i-th word
#   dist_index <- which.min(stringdist(words[-used], words[used[i]], method = method))
#   if(i%%100==0)
#     print(i)
# }
# 
# #saving words order, that is indexes of words
# saveRDS(used, file="/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/used.rds")
used <- readRDS("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/used.rds")
words_order <- words[used]

words_order <- as.vector(words_order)

#distance from i-th to (i+1)-th word + statistics
odl <- (stringdist(words_order[1:(N-1)], words_order[2:N], method = method))

mean(odl)
max(odl)

#distance from every word to any other word + statistics
odl_all <- stringdistmatrix(words_order, words_order)

apply(odl_all, 1, mean)
mean(odl_all)
max(odl_all)



######### clustering #########
######### ######### #########
### 1. criterion: distance of edges
j <- 1
#maximum distance in a cluster
cnt <- 8
i <- 1
used2 <- numeric(0)
used2[i] <- 1
while(j<N){
  i <- i+1
  kt <- which(odl_all[j,-c(1:j)]>=cnt)
  if(length(kt)>0)
    j <- used2[i] <- kt[1]+used2[i-1]
  else
    j <- used2[i] <- N
}


#cnt:   4   5   6   7   8   9   10   11   12   13
#cl : 135  84  46  29  18  12   10    3    3    1

#words in the clusters
for(ii in 1:(i-1))
  print(as.vector(words_order[used2[ii]:(used2[ii+1]-1)]))

#mean number of words in clusters
mean(diff(used2))

######### ######### #########
### 2. criterion: distance from the middle 
j <- 1
#maximum distance between the middles
cnt <- 8
i <- 1
#used3 is a vector of indexes of the middles
used3 <- numeric(0)
kt <- which(odl_all[,1]>=cnt)[1]
j <- used3[1] <- which.min(apply(odl_all[1:kt, 1:kt], 1, sum)) 
clusters1 <- numeric(0)
clusters1[1:j] <- 1
while(j<N){
  i <- i+1
  kt <- which(odl_all[j,-c(1:j)]>=cnt)
  if(length(kt)>0)
    j <- used3[i] <- kt[1]+used3[i-1]
  else
    j <- used3[i] <- N
  #to which cluster does a word belong?
  clusters1[used3[i-1]:used3[i]] <- apply(odl_all[used3[i-1]:used3[i],c(used3[i-1],used3[i])], 1, which.min)+i-1
}
i

#cnt:   4   5   6   7   8   9   10   11   12   13
#cl : 136  84  46  30  16  13   10    9    3    1

#middles
print(as.vector(words_order[used3]))

#words in the clusters
for(ii in 1:i)
  print(as.vector(words_order[which(clusters1==ii)]))

#mean number of words in clusters
mean(diff(used3))

######### ######### #########
### 3. k-medoids
# mamy n-elem cluster, 
# znajdujemy kandydata na dolozenie do klastra, 
# przeliczamy srodek, 
# patrzymy czy max. odl. w klastrze nie przekracza zadanej liczby

cnt <- 6
cluster <- numeric(0)
middle <- numeric(0)
used_all <- numeric(0)
# cluster[1] <- 1
# middle[1] <- 1
# used5 <- used_all <- 1
counter <- 1:N
used_all <- N+1
i <- 0

while(sum(!is.na(used_all))<N+1){
  i <- i+1
  used5 <- middle[i] <- sample(counter[-used_all], 1)
  cluster[used5] <- i
  used_all <- c(used_all, used5)
  while(all(odl_all[used5, used5]<cnt)){
    kt <- which.min(odl_all[-used_all, middle[i]])
    kt <- counter[-used_all][kt]
    cluster[kt] <- i
    used5 <- which(cluster==i)
    used_all <- c(used_all, used5)
    middle[i] <- used5[which.min(apply(odl_all[used5, used5], 1, sum))]
  }
  cluster[kt] <- NA
  used5 <- used5[-which(used5==kt)]
  used_all <- unique(c(used_all, used5))
  
}
i
for(j in 1:i)
  print(words_order[which(cluster==j)])


#words in i-th cluster
for(i in 1:k)
  print(as.vector(words_order[which(clusters==i)]))
#middles
as.vector(words_order[mid])
#input middles
as.vector(words_order[in_mid])


######### ######### #########
### 4. k-medoids with fixed number of clusters
#number of clusters:
k <- 17
#middle words
mid <- sample(1:N, k, replace = FALSE)
s1 <- rep(1,k)
in_mid <- mid

j <- 0
while(!all(s1==mid)){
  s1 <- mid
  #to which cluster does a word belong?
  clusters <- apply(odl_all[,mid], 1, which.min) #drawback: it takes the first found
  #searching for new middle points
  for(i in 1:k){
    wh <- which(clusters==i)
    len <- length(wh)
    if(len>1){
      m <- which.min(apply(odl_all[wh, wh], 1, sum)) 
      mid[i] <- wh[m]
    }else
      mid[i] <- wh
  }
  #counting number of iterations
  j <- j+1
}
j

#words in i-th cluster
for(i in 1:k)
  print(as.vector(words_order[which(clusters==i)]))
#middles
as.vector(words_order[mid])
#input middles
as.vector(words_order[in_mid])


