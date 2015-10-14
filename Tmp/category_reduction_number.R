
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


load("/home/npotocka/mgr/Data/RObjects/level6.rda")
print(7)


ciag <- c(seq(1, nrow(level6), by = 5000), nrow(level6))
for(i in 1:length(ciag)){
  tryCatch({
  level60 <- level6[ciag[i]:(ciag[i+1]-1),]
  level70 <- level60 %>% group_by(level6.link) %>% do(expand_tree(first(.$level6.link), 'level7')) %>% ungroup
  save(list = 'level70', file = paste0('/home/npotocka/mgr/Data/RObjects/level7/level7', i, '.rda'))
  }, error = function(e) print(paste("error", i)))
}




load("/home/npotocka/mgr/Data/RObjects/level71.rda")
level7 <- level70

for(i in 2:length(ciag)){
  load(paste0("/home/npotocka/mgr/Data/RObjects/level7", i, ".rda"))
  level6 <- bind_rows(level7, level70)
}

save(list = 'level7', file = "/home/npotocka/mgr/Data/RObjects/level7.rda")
