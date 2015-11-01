
library(rvest)
library(dplyr)
library(stringi)
library(Hmisc)

expand_tree <- function(link, level) {
  #print(link)
  
  #stri_sub(link, 1, 1) <- stri_trans_toupper(stri_sub(link, 1, 1))
  
  tree_nodes <- 
    link %>%
    capitalize() %>% 
    stri_replace_all_fixed(., " ", "_") %>% 
    stri_paste("https://pl.wikipedia.org/wiki/Kategoria:", .) %>% 
    read_html %>%
    html_nodes("#mw-normal-catlinks li a")
  
  if (length(tree_nodes) > 0)
    data_frame(link = 
                 tree_nodes %>% 
                 html_attr("href") %>%
                 paste0("http://pl.wikipedia.org", .),
               name = html_text(tree_nodes) ) %>%
    setNames(names(.) %>% paste(level, . , sep = ".") ) else data_frame() 
}



#######################
load("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/categories/level6.rda")
print(7)


ciag <- c(seq(1, nrow(brak_sciagnietych), by = 3000), nrow(brak_sciagnietych))

c(13, 25, 27, 31, 35, 39, 42:49)
level61 <- level6[ciag[13]:(ciag[14]-1),]
for(i in c(25, 27, 31, 35, 39, 42:49)){
  level61 <- rbind(level61, level6[ciag[i]:(ciag[i+1]-1),])
}

ciag2 <- c(seq(1, nrow(level6), by = 1000), nrow(level6))
#######################


for(i in 1:nrow(brak_sciagnietych)){
  tryCatch({
    #level0 <- brak_sciagnietych[ciag[i]:(ciag[i+1]-1),]
    level1 <- brak_sciagnietych[i,] %>% do(expand_tree(.$name, 'level1')) %>% ungroup
    save(list = 'level1', file = paste0('/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/categories/level7/level7', i, '.rda'))
  }, error = function(e) print(paste("error", i)))
  if(i %% 1000 == 0)
    print(i)
}




load("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/categories/level7/level71.rda")
level10 <- bind_cols(level1, select(brak_sciagnietych[1,], name))

pliki <- list.files("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/categories/level7", pattern = ".rda", full.names = TRUE)

for(i in 2:(length(pliki)-1)){
  plik <- pliki[i]
  load(plik)
  index <- stri_match_last_regex(plik, "/level7(\\d+)\\.rda")[,2]
  to_bind <- do.call(what = "rbind", args = 
                       replicate(nrow(level1), select(brak_sciagnietych[as.numeric(index),], name), simplify = FALSE))
  level10 <- level1 %>% 
    bind_cols(to_bind) %>% 
    bind_rows(level10)
  if(i %% 500 == 0)
    print(i)
}

save(list = 'level10', file = "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/categories/level7/level10.rda")
load("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/categories/level10.rda")


level11 <- left_join(level10[,-1], brak_sciagnietych) %>% 
  select(name, cnt, id_category, level1.name) %>% 
  rename(nowa_kat = level1.name) %>% 
  mutate(nowa_kat = stri_trans_tolower(nowa_kat))

level11 <- level11 %>% 
  select(nowa_kat) %>% 
  rename(nowa_kat2 = nowa_kat) %>% 
  bind_cols(level11, .)

load("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/categories/stat_all.rda")



stat_all <- bind_rows(stat_all, level11) %>% 
  group_by(name, cnt, id_category) %>% 
  summarise(nowa_kat = first(nowa_kat), nowa_kat2 = first(nowa_kat2)) %>% 
  bind_cols(rename(select(., nowa_kat2), nowa_kat3 = nowa_kat2))

wspolne <- intersect(stat_all$name, stat_all$nowa_kat2)
for(i in 1:length(wspolne)){
  index1 <- which(stat_all$nowa_kat2 == wspolne[i])
  index2 <- which(stat_all$name == wspolne[i])
  stat_all$nowa_kat3[index1] <- stat_all$nowa_kat3[index2]
}

save(list = 'stat_all', file = "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/categories/stat_all_nowsze.rda")





