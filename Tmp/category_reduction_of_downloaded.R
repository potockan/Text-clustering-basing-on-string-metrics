
ciag <- c(seq(1, nrow(level6), by = 5000), nrow(level6))
ciag2 <- setdiff(1:length(ciag), c(13, 25, 27, 31, 35, 39, 42:49))



load("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/categories/level7/level71.rda")
level7 <- level70

for(i in ciag2[-1]){
  load(paste0("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/categories/level7/level7", i, ".rda"))
  level7 <- bind_rows(level7, level70)
}

save(list = 'level7', file = "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/categories/level7/level7.rda")

for(i in 1:7)
  load(paste0("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/categories/level", i, ".rda"))

kategorie <- character()
for(i in 1:7)
  kategorie <- c(kategorie, eval(parse(text=paste0("level", i, "$level", i, ".name" ))))

######################################

#install.packages("RSQLite")
library(RSQLite)
library(stringdist)
library(compiler)
library(dplyr)
library(stringi)

source("./R/db_exec.R")
prepare_string <- cmpfun(function(str) {
  stri_paste("'", stri_replace_all_fixed(str, "'", "''"), "'")
})
### Worked text database ###

con <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")

dbGetQuery(con, "select count(*) from wiki_category_name")

kategorie_baza <- dbGetQuery(con, "select distinct b.name, a.cnt, a.id_category from wiki_unique_category a
                             left join
                             wiki_category_name b
                             on b.id = a.id_category")
kategorie <- unique(stri_trans_tolower(unique(kategorie)))


intersect(kategorie_baza$name, kategorie) %>% length()

brak_sciagnietych <- kategorie_baza[!(kategorie_baza$name %in% kategorie),]


sciagniete <- kategorie_baza[(kategorie_baza$name %in% kategorie),]

kateg <- level1

for(i in 1:6){
  kateg <- kateg %>% 
    left_join(eval(parse(text = paste0('level', i+1)))) %>% 
    select_(paste0('-level', i, '.link'))
}


kateg <- kateg %>% select(-level7.link)
for(i in names(kateg)){
  varval <- sprintf("tolower(%s)", i)
  kateg <- kateg %>% mutate_(.dots= setNames(list(varval), i))
}
  
  
  
sciagniete <- cbind(sciagniete, character(nrow(sciagniete)))
names(sciagniete)[4] <- "nowa_kat"
sciagniete$nowa_kat <- as.character(sciagniete$nowa_kat)

for(i in 1:nrow(sciagniete)){
  for(j in 2:7){
    index <- which(eval(parse(text = paste0("kateg$level", j, ".name")))
        == sciagniete$name[i])
    if(length(index) != 0){
      sciagniete$nowa_kat[i] <- eval(parse(text = paste0("kateg$level", j-1, ".name[index][1]")))
      break()
    }
    
  }
  if(i %% 500 == 0)
    print(i)
  
}
save(list = 'sciagniete', file = "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/sciagniete.rda")


statystyki <- sciagniete %>% group_by(nowa_kat) %>% summarise(cnt2 = sum(cnt))

stat2 <- statystyki %>% filter(cnt2 <= 5) 


stat2 <- cbind(stat2, character(nrow(stat2)))
names(stat2)[3] <- "nowa_kat2"
stat2$nowa_kat2 <- as.character(stat2$nowa_kat2)
for(i in 325:nrow(stat2)){
  for(j in 2:7){
    index <- which(eval(parse(text = paste0("kateg$level", j, ".name")))
                   == stat2$nowa_kat[i])
    if(length(index) != 0){
      stat2$nowa_kat2[i] <- eval(parse(text = paste0("kateg$level", j-1, ".name[index][1]")))
      break()
    }
    
  }
  if(i %% 500 == 0)
    print(i)
  
}

stat_all <- left_join(sciagniete, stat2[,-2])
stat_all$nowa_kat2 <- ifelse(is.na(stat_all$nowa_kat2), stat_all$nowa_kat, stat_all$nowa_kat2)
stat_all$nowa_kat2 <- ifelse(stat_all$nowa_kat2 == 'urodzeni w xx wieku', stat_all$name, stat_all$nowa_kat2)


statystyki <- stat_all %>% group_by(nowa_kat2) %>% summarise(cnt2 = sum(cnt))

stat_all2 <- bind_rows()

