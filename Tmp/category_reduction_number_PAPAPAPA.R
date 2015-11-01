
library(rvest)
library(dplyr)
library(stringi)

expand_tree <- function(link, level) {
  #print(link)
  
  tree_nodes <- 
    link %>%
    read_html %>%
    html_nodes(".CategoryTreeLabel")
  
  if (length(tree_nodes) > 0)
    data_frame(link = 
                 tree_nodes %>% 
                 html_attr("href") %>%
                 paste0("http://pl.wikipedia.org", .),
               name = html_text(tree_nodes) ) %>%
    setNames(names(.) %>% paste(level, . , sep = ".") ) else data_frame() 
}


load("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/categories/level7.rda")
print(7)


ciag <- c(seq(1, nrow(level6), by = 5000), nrow(level6))

c(13, 25, 27, 31, 35, 39, 42:49)
level61 <- level6[ciag[13]:(ciag[14]-1),]
for(i in c(25, 27, 31, 35, 39, 42:49)){
  level61 <- rbind(level61, level6[ciag[i]:(ciag[i+1]-1),])
}

ciag2 <- c(seq(1, nrow(level61), by = 1000), nrow(level61))

for(i in 1:length(ciag)){
  tryCatch({
  level70 <- level7[ciag[i]:(ciag[i+1]-1),]
  level80 <- level70 %>% group_by(level7.link) %>% do(expand_tree(first(.$level7.link), 'level7')) %>% ungroup
  save(list = 'level80', file = paste0('/home/npotocka/mgr/Data/RObjects/level8/level8', i, '.rda'))
  }, error = function(e) print(paste("error", i)))
}




load("/home/npotocka/mgr/Data/RObjects/level71.rda")
level7 <- level70

for(i in 2:length(ciag)){
  load(paste0("/home/npotocka/mgr/Data/RObjects/level7", i, ".rda"))
  level7 <- bind_rows(level7, level70)
}

save(list = 'level7', file = "/home/npotocka/mgr/Data/RObjects/level7.rda")
