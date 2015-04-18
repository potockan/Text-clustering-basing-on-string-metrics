#!/usr/bin/Rscript --vanilla

library(RSQLite)
library(stringi)
library(ggplot2)
#library(compiler)

## dbExecQuery function
#source("./R/db_exec.R")

con <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics//Data/DataBase/wiki.sqlite")

n_words <- dbGetQuery(con, "select count(1) from wiki_word")[1,1]
n_words_freq <- dbGetQuery(con, "select count(1) from wiki_word_freq")[1,1]
word_stat <- readRDS("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/words_cnt.rds")


#x <- readRDS("./Data//RObjects//words_cnt.rds")
435125/length(word_stat$word[which(word_stat$word_cnt==1)])

#x <- word_stat$word[sample(nrow(word_stat), 5000)]
n_has_no_letter <- sum(stri_detect_regex(word_stat$word, "\\P{L}"))
n_has_letter <- sum(stri_detect_regex(word_stat$word, "\\p{L}"))
n_one_let <- sum(stri_length(word_stat$word)==1)


cnt <- 10
hist(word_stat$word_cnt[which(word_stat$word_cnt>cnt)], 
     xlab="Liczba wystapien w tekstach", 
     ylab="Licznosc",
     main=stri_paste("Histogram dla licznosci powyzej ", cnt," wystapien" ))

qplot(word_stat$word_cnt[which(word_stat$word_cnt>cnt)], binwidth=10000,
      ylim=c(0,200),
      xlab="Liczba wystapien w tekstach", 
      ylab="Licznosc",
      main=stri_paste("Histogram dla licznosci powyzej ", cnt," wystapien" ))

qplot(word_stat$word_cnt, binwidth=10000,
      ylim=c(0,170),
      xlab="Liczba wystapien slow w tekstach", 
      ylab="Licznosc",
      main=stri_paste("Histogram dla liczby wystapien slow w tekscie" ))

hist(word_stat$word_cnt)



mean(word_stat$word_cnt)


ggplot(word_stat[which(word_stat$word_cnt>cnt),], aes(x=word_cnt)) +
  geom_histogram(fill="white", colour="black")

ggplot(word_stat[which(word_stat$word_cnt>cnt),], 
       aes(x=1, y=word_cnt)) + geom_boxplot()
cnt <- 3
summary(word_stat$word_cnt[which(word_stat$word_cnt>cnt)])

stopwords <- as.vector(as.matrix(read.table("/dragon/Text-clustering-basing-on-string-metrics//Data//RObjects//stopwords2.txt", sep=",")[1,]))


x <- stri_extract_all_regex(word_stat[,2], "\\p{script=latin}+")
ind <- sapply(x, function(x){
  which(!is.na(x))
})
x <- x[ind]

length(ind)

which(is.na(x))


