#install.packages('stringdist')
library(stringdist)
library(stringi)

#reading words with number of articles that they apperead in
word_stat <- 
  readRDS("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/words_cnt.rds")

# n_words <- nrow(word_stat)
# n_once <- sum(word_stat$word_cnt==1)/n_words*100
# 
# n_articles <- readRDS("./Data//RObjects//n_articles.rds")
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

#reading stopwords
stopwords <- as.vector(read.table("/dragon/Text-clustering-basing-on-string-metrics/Data//RObjects//stopwords2.txt", sep="")[,1])

# saving stopwords and words that are weird or have one character
cat(c(stopwords, word_stat$word[2806173:2806765], word_stat$word[which(stri_length(word_stat$word)==1)]), 
    file = "/dragon/Text-clustering-basing-on-string-metrics/Data//RObjects//stopwords3.txt", sep='\n')

#all the words that we would be analyzing
words <- c(word=setdiff(word_stat$word, 
                        c(stopwords, word_stat$word[2806173:2806765])))
words <- words[-(which(stri_length(words)==1))]

#word_no_stp <- merge(word_stat, words)
n_no_stp <- length(words)
#saving in two formats for further analysis
saveRDS(words, "/dragon/Text-clustering-basing-on-string-metrics//Data//RObjects/words_to_analize.rds")
cat(words, file = "/dragon/Text-clustering-basing-on-string-metrics//Data//RObjects//words.txt", sep='\n')


