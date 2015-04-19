library(RSQLite)
library(stringi)
library(compiler)
library(stringdist)
library(wordcloud)


con <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")

words <- dbGetQuery(con, "
          select *
          from wiki_hunspell_clust a
          join
          wiki_word b
          on
          b.id = a.id_stem_word
          join
          wiki_word d
          on
          d.id = a.id_word
          order by a.id_stem_word
            ")

words <- words[,c(1,2,4,6)]
names(words) <- c("id_word", "id_stem_word", "stem_word", "word")
slowa1 <- words$word[words$stem_word == 'użyć']
slowa2 <- words$word[words$stem_word == 'kamień']
slowa3 <- words$word[words$stem_word == 'błoto']
slowa4 <- words$word[words$stem_word == 'czerwony']

saveRDS(slowa1, "./Seminarium/slowa1.rds")
saveRDS(slowa2, "./Seminarium/slowa2.rds")
saveRDS(slowa3, "./Seminarium/slowa3.rds")

par(mfrow=c(1,3))

wordcloud(slowa1, sample(1:length(slowa1)), scale = c(2.5, 0.5))
wordcloud(slowa2, sample(1:length(slowa2)), scale = c(2.5, 0.5))
wordcloud(slowa3, sample(1:length(slowa3)), scale = c(2.5, 0.5))


dbDisconnect(con)


