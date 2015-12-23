#!/usr/bin/Rscript --vanilla

library(RSQLite)
library(stringi)
library(ggplot2)
library(scales)
library(xtable)
#library(compiler)


#"select count(1) from wiki_word_freq"
n_words_freq <- readRDS("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/n_word_freq.rds")

#"select count(1) from wiki_page"
n_articles <- readRDS("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/n_articles.rds")

# "select count(1) from wiki_category_name"
n_categories <- readRDS("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/n_categories.rds")

#cnt == in how many texts a word occured
# word_stat <- dbGetQuery(con, "
#                         select count(a.freq) as word_cnt, b.word as word
#                         from wiki_word_freq a 
#                         join
#                         wiki_word b
#                         on a.id_word=b.id
#                         group by a.id_word
#                         order by word_cnt desc")
word_stat <- readRDS("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/words_cnt.rds")

#word_cnt_all == how many times a word apperead in all texts
# word_stat_all <- dbGetQuery(con, "
#                             select sum(a.freq) as word_cnt_all, b.word as word
#                             from wiki_word_freq a
#                             join
#                             wiki_word b
#                             on a.id_word=b.id
#                             group by a.id_word
#                             order by word_cnt_all desc
#                             ")
word_stat_all <- readRDS("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/words_cnt_all.rds")

#word_art == how many words apperead in the text
# word_art <- dbGetQuery(con, "
#                             select count(1) as cnt, a.id_title, b.title
#                             from wiki_word_freq a
#                             join 
#                             wiki_page b
#                             on a.id_title = b.id
#                             group by a.id_title
#                             ")

word_art <- readRDS("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/word_art.rds")






word_stat %>% 
  arrange(desc(word_cnt)) %>% 
  ggplot(aes(x=log10(word_cnt)), main="Liczba występowania słów w artykułach") + 
  geom_histogram(fill="white", colour="black") +
  xlab("log10(licznosc)") +
  ylab("czestosc") +
  theme(text = element_text(size=25),
        axis.text.x = element_text(size = 25), 
        axis.text.y = element_text(size = 25)) 

word_stat_all %>% 
  arrange(desc(word_cnt_all)) %>% 
  ggplot(aes(x=log10(word_cnt_all)), main="Liczba występowania słów w artykułach") + 
  geom_histogram(fill="white", colour="black") +
  xlab("log10(licznosc)") +
  ylab("czestosc") +
  theme(text = element_text(size=25),
        axis.text.x = element_text(size = 25), 
        axis.text.y = element_text(size = 25)) +
  scale_y_continuous(label=scientific_format())


n_words <- nrow(word_stat)
(n_once <- sum(word_stat$word_cnt==1)/n_words*100)

(n_hundr <- sum(word_stat$word_cnt > 100)/n_words*100)
(n_hundr <- sum(word_stat$word_cnt > 1000)/n_words*100)
(n_hundr <- sum(word_stat$word_cnt > 100000)/n_words*100)


n_words_all <- nrow(word_stat_all)
(n_once_all <- sum(word_stat_all$word_cnt==1)/n_words_all*100)
(n_hundr_all <- sum(word_stat_all$word_cnt > 100)/n_words_all*100)
(n_hundr_all <- sum(word_stat_all$word_cnt > 1000)/n_words_all*100)
(n_hundr_all <- sum(word_stat_all$word_cnt > 100000)/n_words_all*100)

set.seed(6785)
cat(sample(word_stat$word[word_stat$word_cnt==1], 10), sep = ", ")

data.frame(dl = stri_length(word_stat$word)) -> word_length
word_length <- bind_cols(word_length, data.frame(l = rep(1, nrow(word_length))))


# ggplot(word_length, aes(factor(l), dl)) +
#   geom_boxplot() +
#   xlab("") +
#   ylab("") +
#   theme(text = element_text(size=25),
#         axis.text.x = element_text(size = 25), 
#         axis.text.y = element_text(size = 25))
# 
# word_length %>% 
#   filter(dl <= 11) %>% 
# ggplot(aes(factor(l), dl)) +
#   geom_boxplot()

word_length %>% 
  ggplot(aes(x=log2(dl)), main="Liczba występowania słów w artykułach") + 
  geom_histogram(fill="white", colour="black") +
  xlab("log10(licznosc)") +
  ylab("czestosc") +
  theme(text = element_text(size=25),
        axis.text.x = element_text(size = 25), 
        axis.text.y = element_text(size = 25)) +
  scale_y_continuous(label=scientific_format())


top10 <- head(word_stat, 20)
top10 <- cbind(top10, top10[,1])[,-1]
top10_all <- numeric(20)
for(i in 1:length(top10[,1])){
  top10_all[i] <- word_stat_all$word_cnt_all[which(word_stat_all$word==top10[i,1])]
}
top10 <- cbind(top10, top10_all)
names(top10) <- c("Słowo", "Liczba artykułów", "Liczba wystąpień słowa")
tab <- xtable(top10, caption="Lista dziesięciu najczęściej występujących słów.")
digits(tab)[c(3,4)] <- 0
print(tab)


stopwords <- as.vector(read.table("Data//RObjects//stopwords2.txt", sep="")[,1]) %>% 
  stri_flatten(collapse = ", ")
aa <- c(seq(1, stri_length(stopwords), by=75), stri_length(stopwords))
stri_sub(stopwords, aa[1:(length(aa)-1)], aa[2:length(aa)]-1) %>% 
  cat(sep = "\n", file = "~/Desktop/aa.txt")




word_art %>% 
  arrange(desc(cnt)) %>% 
  ggplot(aes(x=log10(cnt)), main="Liczba występowania słów w artykułach") + 
  geom_histogram(fill="white", colour="black") +
  xlab("log10(licznosc)") +
  ylab("czestosc") +
  theme(text = element_text(size=25),
        axis.text.x = element_text(size = 25), 
        axis.text.y = element_text(size = 25)) +
  scale_y_continuous(label=scientific_format())

summary(word_art$cnt)



######################################################




con <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics//Data/DataBase/wiki.sqlite")

n_words <- dbGetQuery(con, "select count(1) from wiki_word")[1,1]
n_words_freq <- dbGetQuery(con, "select count(1) from wiki_word_freq")[1,1]

# setwd("/dragon/Text-clustering-basing-on-string-metrics/")
# x <- readRDS("./Data//RObjects//words_cnt.rds")
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


