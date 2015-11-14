
library(RSQLite)
library(dplyr)
library(stringi)

source("./R/db_exec.R")


con <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")


dbListTables(con)
dbListFields(con, "wiki_category_text_after_reduction")
dbListFields(con, "wiki_category_after_reduction")


kategorie <- dbGetQuery(con, "select a.name_new, a.id_new
                        from wiki_category_after_reduction a
                        join
                        (select distinct id_new_cat from wiki_category_text_after_reduction) b
                        on a.id_new = b.id_new_cat
                        ") 


dbDisconnect(con)

kategorie %>% distinct() -> kategorie


##################


for(i in 1:7)
  load(paste0("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/categories/level", i, ".rda"))

kateg <- level1

for(i in 1:6){
  kateg <- kateg %>% 
    left_join(eval(parse(text = paste0('level', i+1)))) %>% 
    select_(paste0('-level', i, '.link'))
}

rm(level1, level2, level3, level4, level5, level6, level7)

kateg <- kateg %>% select(-level7.link)
for(i in names(kateg)){
  varval <- sprintf("tolower(%s)", i)
  kateg <- kateg %>% mutate_(.dots= setNames(list(varval), i))
}



kategorie <- cbind(kategorie, numeric(nrow(kategorie)), numeric(nrow(kategorie)))
names(kategorie)[3] <- "level"
names(kategorie)[4] <- "roww"
#kategorie$nowa_kat <- as.character(kategorie$nowa_kat)

for(i in 1:nrow(kategorie)){
  for(j in 2:7){
    index <- which(eval(parse(text = paste0("kateg$level", j, ".name")))
                   == kategorie$name_new[i])
    if(length(index) != 0){
      kategorie$level[i] <- j
      kategorie$roww[i] <- index[1]
        #eval(parse(text = paste0("kateg$level", j-1, ".name[index][1]")))
      break()
    }
    
  }
  if(i %% 500 == 0)
    print(i)
  
}

kategorie <- cbind(kategorie, character(nrow(kategorie)))
names(kategorie)[5] <- "nowa_kat"
kategorie$nowa_kat <- as.character(kategorie$nowa_kat)
kategorie$level <- as.numeric(kategorie$level)

for(i in 1:nrow(kategorie)){
  if(kategorie$level[i] != 0)
    #k <- kategorie$level[i]-1
    kategorie$nowa_kat[i] <- eval(parse(text = paste0("kateg$level1.name[", kategorie$roww[i],"]")))
}

kategorie$nowa_kat <- ifelse(kategorie$level == 0, "", kategorie$nowa_kat)

save(list = 'kategorie', file = "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/categories/kategorie20151114.rda")
load("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/categories/kategorie20151114.rda")


load("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/categories/level10.rda")
level10 %>% select(-level1.link) -> level10

for(i in names(level10)){
  varval <- sprintf("tolower(%s)", i)
  level10 <- level10 %>% mutate_(.dots= setNames(list(varval), i))
}

nieskl <- kategorie$name_new[kategorie$nowa_kat == ""]

nieskl <- data.frame(name = nieskl)


nieskl <- left_join(nieskl, level10)




