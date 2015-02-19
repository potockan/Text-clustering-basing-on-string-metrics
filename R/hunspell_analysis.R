library(stringi)

txt <- readLines("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/words_analiza_morfologiczna-sorted.txt", n=10000)
txt <- txt[which(stri_length(txt)>0)]

txt_split <- lapply(stri_split_fixed(txt, " "), function(txt){
  p <- unlist(stri_split_fixed(txt, "st:") )
  p <- p[which(stri_length(p)>0 & p!="st" & p!="fl")]
  n <- length(p)
  if(n==1)
    p[2] <- ""
  p[1:2]
    
})
txt_split

m1 <- matrix(unlist(txt_split), ncol = 2, byrow = TRUE)
m1 <- m1[-which(duplicated(m1)),]
kt <- which(duplicated(m1[,1]))
m2 <- m1[-kt,]






con <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")

dbExecQuery(con, "CREATE TABLE IF NOT EXISTS wiki_hunspell_clust (
  id_word INTEGER NOT NULL,
  id_stem_word INTEGER NOT NULL,
  FOREIGN KEY (id_word) REFERENCES wiki_word(id),
  FOREIGN KEY (id_stem_word) REFERENCES wiki_word(id)
);")

dbDisconnect(con)

