#install.packages('stringdist')
library(stringdist)
library(RSQLite)
library(tidyr)
library(stringi)
library(dplyr)
library(compiler)
## dbExecQuery function
source("./R/db_exec.R")

## function preparing strong to insert it to db
prepare_string <- cmpfun(function(str) {
  stri_paste("'", stri_replace_all_fixed(str, "'", "''"), "'")
})

#reading words with number of articles that they apperead in
word_stat <- 
  readRDS("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/words_cnt.rds")

#########################
word_stat <- readRDS("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/words_cnt.rds")
word_stat_all <- readRDS("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/words_cnt_all.rds")


slowa <- unique(c(unique(c(word_stat$word[1:2000],
                  word_stat_all$word[1:2000]))[1:344], 
                  word_stat_all$word[stri_length(word_stat_all$word) < 4]))

slowa1 <- unique(c(word_stat$word[word_stat$word_cnt < 3], 
                   word_stat_all$word[word_stat_all$word_cnt_all < 3]
                   ))

#reading stopwords
stopwords <- as.vector(read.table("/dragon/Text-clustering-basing-on-string-metrics/Data//RObjects//stopwords2.txt", sep="")[,1])

# saving stopwords and words that are weird or have one character
cat(unique(c(stopwords, slowa, slowa1)), 
    file = "/dragon/Text-clustering-basing-on-string-metrics/Data//RObjects//stopwords3.txt", sep='\n')

slowa_zostaja <- setdiff(word_stat$word, 
                         unique(c(stopwords, slowa, slowa1)))

###########
con <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")

dbListTables(con)


# 
# dbExecQuery(con, "drop table wiki_hunspell_clust;")
# dbExecQuery(con, "drop table wiki_hunspell_clust2;")
# dbExecQuery(con, "drop table wiki_hunspell_clust2_cosine;")
# dbExecQuery(con, "drop table wiki_hunspell_clust2_dl;")
# dbExecQuery(con, "drop table wiki_hunspell_clust2_jaccard;")
# dbExecQuery(con, "drop table wiki_hunspell_clust2_lcs;")
# dbExecQuery(con, "drop table wiki_hunspell_clust2_qgram;")
# dbExecQuery(con, "drop table wiki_hunspell_clust2_red_dl;")
# dbExecQuery(con, "drop table wiki_hunspell_clust2_red_dl_dl;")
# dbExecQuery(con, "drop table wiki_hunspell_clust2_red_jaccard;")
# dbExecQuery(con, "drop table wiki_hunspell_clust2_red_jaccard_jaccard;")
# dbExecQuery(con, "drop table wiki_hunspell_clust2_red_lcs;")
# dbExecQuery(con, "drop table wiki_hunspell_clust2_red_lcs_lcs;")
# dbExecQuery(con, "drop table wiki_hunspell_clust2_red_qgram;")
# dbExecQuery(con, "drop table wiki_hunspell_clust2_red_qgram_qgram;")
# 
#                   
# 
# dbExecQuery(con, "drop table wiki_word_clust2_dl_freq;")
# dbExecQuery(con, "drop table wiki_word_clust2_freq;")
# dbExecQuery(con, "drop table wiki_word_clust2_jaccard_freq;")
# dbExecQuery(con, "drop table wiki_word_clust2_lcs_freq;")
# dbExecQuery(con, "drop table wiki_word_clust2_qgram_freq;")
# dbExecQuery(con, "drop table wiki_word_clust2_red_dl_dl_freq;")
# dbExecQuery(con, "drop table wiki_word_clust2_red_dl_freq;")
# dbExecQuery(con, "drop table wiki_word_clust2_red_jaccard_freq;")
# dbExecQuery(con, "drop table wiki_word_clust2_red_jaccard_jaccard_freq;")
# dbExecQuery(con, "drop table wiki_word_clust2_red_lcs_freq;")
# dbExecQuery(con, "drop table wiki_word_clust2_red_lcs_lcs_freq;")
# dbExecQuery(con, "drop table wiki_word_clust2_red_qgram_freq;")
# dbExecQuery(con, "drop table wiki_word_clust2_red_qgram_qgram_freq;")
# dbExecQuery(con, "drop table wiki_word_clust3_dl_freq;")
# dbExecQuery(con, "drop table wiki_word_clust3_freq;")
# dbExecQuery(con, "drop table wiki_word_clust3_jaccard_freq;")
# dbExecQuery(con, "drop table wiki_word_clust3_lcs_freq;")
# dbExecQuery(con, "drop table wiki_word_clust3_qgram_freq;")
# dbExecQuery(con, "drop table wiki_word_clust3_red_dl_dl_freq;")
# dbExecQuery(con, "drop table wiki_word_clust3_red_dl_freq;")
# dbExecQuery(con, "drop table wiki_word_clust3_red_jaccard_freq;")
# dbExecQuery(con, "drop table wiki_word_clust3_red_jaccard_jaccard_freq;")
# dbExecQuery(con, "drop table wiki_word_clust3_red_lcs_freq;")
# dbExecQuery(con, "drop table wiki_word_clust3_red_lcs_lcs_freq;")
# dbExecQuery(con, "drop table wiki_word_clust3_red_qgram_freq;")
# dbExecQuery(con, "drop table wiki_word_clust3_red_qgram_qgram_freq;")

#dbExecQuery(con, "drop table wiki_word2")
#dbExecQuery(con, "drop table wiki_word_freq2")

dbExecQuery(con, sprintf("create table wiki_word2 as
            select * 
            from wiki_word
            where word in (%s)",
            stri_flatten(prepare_string(slowa_zostaja), collapse = ", ")
            ))

dbExecQuery(con, "create table wiki_word_freq2 as
            select * 
            from wiki_word_freq
            where id_word in (
                         select distinct id 
                        from wiki_word2
            )")

# dbGetQuery(con, "select count(distinct id) from wiki_word2")
# dbGetQuery(con, "select count(distinct id_word) from wiki_word_freq2")

dbDisconnect(con)

##########

#all the words that we would be analyzing
words <- slowa_zostaja

#word_no_stp <- merge(word_stat, words)
n_no_stp <- length(words)
#saving in two formats for further analysis
saveRDS(words, "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/words_to_analize.rds")
saveRDS(words, "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/words_no_stpw.rds")
cat(words, file = "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/words.txt", sep='\n')

saveRDS(slowa, "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/slowa_out.rds")

