library("stringi")
library("rvest")

find_links <- function(link){
  strona <- read_html(link)
  kategorie <- html_nodes(strona, ".CategoryTreeLabel")
  if(length(kategorie)==0) return(NA)
  as.list(stri_paste("http://pl.wikipedia.org", html_attr(kategorie, "href")))
}

find_titles <- function(link){
  strona <- read_html(link)
  kategorie <- html_nodes(strona, ".CategoryTreeLabel")
  if(length(kategorie)==0) return(NA)
  as.list(html_text(kategorie))
}

link <- 'http://pl.wikipedia.org/wiki/Wikipedia:Drzewo_kategorii'
strona <- read_html(link)
kategorie <- html_nodes(strona, ".CategoryTreeLabel")[-c(1:10, 14, 69, 96, 101, 155, 176, 188, 220, 234)]
kategorie <- kategorie[220:225]
if(length(kategorie)==0) return(NA)
linki <- as.list(stri_paste("http://pl.wikipedia.org", html_attr(kategorie, "href")))
tytuly <- as.list(html_text(kategorie))
tytuly <- list(tytuly, linki)


zapetlenie <- function(linki){
  
    znalezione <- znajdz_tytuly(linki)
   
      #tytuly[[i]] <- c(tytuly[[i]], list(znalezione[[1]]))
     return(list(znalezione[[2]]))
      
}


aa <- rapply(linki, find_links,  how = 'replace')
aa1 <- rapply(linki, find_titles, how = 'replace')
bb <- rapply(aa, find_links,  how = 'replace')
bb1 <- rapply(aa, find_titles,  how = 'replace')
...





library(rvest)
library(dplyr)

expand_tree <- function(link, level) {
  print(link)
  
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

level1 <- 
  'http://pl.wikipedia.org/wiki/Wikipedia:Drzewo_kategorii' %>%
  expand_tree("level1") %>%
  slice(-c(1:10, 14, 69, 96, 101, 155, 176, 188, 220, 234)) %>%
  slice(220:225)

level2 <- 
  level1 %>%
  group_by(level1.link) %>%
  do(expand_tree(first(.$level1.link), "level2")) %>%
  ungroup

level3 <- 
  level2 %>%
  group_by(level2.link) %>%
  do(expand_tree(first(.$level2.link), "level3")) %>%
  ungroup

level4 <- 
  level3 %>%
  group_by(level3.link) %>%
  do(expand_tree(first(.$level3.link), "level4")) %>%
  ungroup

for(i in 5:100){
  print(stri_flatten(c(sprintf("level%d <- level%d", i, i-1), 
    sprintf("group_by(level%d.link)", i-1),
    sprintf("do(expand_tree(first(.$level%d.link), 'level%d'))", i-1, i),
    "ungroup"), collapse = " %>% "))
}



level5 <- level4 %>% group_by(level4.link) %>% do(expand_tree(first(.$level4.link), 'level5')) %>% ungroup
level6 <- level5 %>% group_by(level5.link) %>% do(expand_tree(first(.$level5.link), 'level6')) %>% ungroup
level7 <- level6 %>% group_by(level6.link) %>% do(expand_tree(first(.$level6.link), 'level7')) %>% ungroup
level8 <- level7 %>% group_by(level7.link) %>% do(expand_tree(first(.$level7.link), 'level8')) %>% ungroup
level9 <- level8 %>% group_by(level8.link) %>% do(expand_tree(first(.$level8.link), 'level9')) %>% ungroup
level10 <- level9 %>% group_by(level9.link) %>% do(expand_tree(first(.$level9.link), 'level10')) %>% ungroup
level11 <- level10 %>% group_by(level10.link) %>% do(expand_tree(first(.$level10.link), 'level11')) %>% ungroup
level12 <- level11 %>% group_by(level11.link) %>% do(expand_tree(first(.$level11.link), 'level12')) %>% ungroup
level13 <- level12 %>% group_by(level12.link) %>% do(expand_tree(first(.$level12.link), 'level13')) %>% ungroup
level14 <- level13 %>% group_by(level13.link) %>% do(expand_tree(first(.$level13.link), 'level14')) %>% ungroup
level15 <- level14 %>% group_by(level14.link) %>% do(expand_tree(first(.$level14.link), 'level15')) %>% ungroup
level16 <- level15 %>% group_by(level15.link) %>% do(expand_tree(first(.$level15.link), 'level16')) %>% ungroup
level17 <- level16 %>% group_by(level16.link) %>% do(expand_tree(first(.$level16.link), 'level17')) %>% ungroup
level18 <- level17 %>% group_by(level17.link) %>% do(expand_tree(first(.$level17.link), 'level18')) %>% ungroup
level19 <- level18 %>% group_by(level18.link) %>% do(expand_tree(first(.$level18.link), 'level19')) %>% ungroup
level20 <- level19 %>% group_by(level19.link) %>% do(expand_tree(first(.$level19.link), 'level20')) %>% ungroup
level21 <- level20 %>% group_by(level20.link) %>% do(expand_tree(first(.$level20.link), 'level21')) %>% ungroup
level22 <- level21 %>% group_by(level21.link) %>% do(expand_tree(first(.$level21.link), 'level22')) %>% ungroup
level23 <- level22 %>% group_by(level22.link) %>% do(expand_tree(first(.$level22.link), 'level23')) %>% ungroup
level24 <- level23 %>% group_by(level23.link) %>% do(expand_tree(first(.$level23.link), 'level24')) %>% ungroup
level25 <- level24 %>% group_by(level24.link) %>% do(expand_tree(first(.$level24.link), 'level25')) %>% ungroup
level26 <- level25 %>% group_by(level25.link) %>% do(expand_tree(first(.$level25.link), 'level26')) %>% ungroup
level27 <- level26 %>% group_by(level26.link) %>% do(expand_tree(first(.$level26.link), 'level27')) %>% ungroup
level28 <- level27 %>% group_by(level27.link) %>% do(expand_tree(first(.$level27.link), 'level28')) %>% ungroup
level29 <- level28 %>% group_by(level28.link) %>% do(expand_tree(first(.$level28.link), 'level29')) %>% ungroup
level30 <- level29 %>% group_by(level29.link) %>% do(expand_tree(first(.$level29.link), 'level30')) %>% ungroup
level31 <- level30 %>% group_by(level30.link) %>% do(expand_tree(first(.$level30.link), 'level31')) %>% ungroup
level32 <- level31 %>% group_by(level31.link) %>% do(expand_tree(first(.$level31.link), 'level32')) %>% ungroup
level33 <- level32 %>% group_by(level32.link) %>% do(expand_tree(first(.$level32.link), 'level33')) %>% ungroup
level34 <- level33 %>% group_by(level33.link) %>% do(expand_tree(first(.$level33.link), 'level34')) %>% ungroup
level35 <- level34 %>% group_by(level34.link) %>% do(expand_tree(first(.$level34.link), 'level35')) %>% ungroup
level36 <- level35 %>% group_by(level35.link) %>% do(expand_tree(first(.$level35.link), 'level36')) %>% ungroup
level37 <- level36 %>% group_by(level36.link) %>% do(expand_tree(first(.$level36.link), 'level37')) %>% ungroup
level38 <- level37 %>% group_by(level37.link) %>% do(expand_tree(first(.$level37.link), 'level38')) %>% ungroup
level39 <- level38 %>% group_by(level38.link) %>% do(expand_tree(first(.$level38.link), 'level39')) %>% ungroup
level40 <- level39 %>% group_by(level39.link) %>% do(expand_tree(first(.$level39.link), 'level40')) %>% ungroup
level41 <- level40 %>% group_by(level40.link) %>% do(expand_tree(first(.$level40.link), 'level41')) %>% ungroup
level42 <- level41 %>% group_by(level41.link) %>% do(expand_tree(first(.$level41.link), 'level42')) %>% ungroup
level43 <- level42 %>% group_by(level42.link) %>% do(expand_tree(first(.$level42.link), 'level43')) %>% ungroup
level44 <- level43 %>% group_by(level43.link) %>% do(expand_tree(first(.$level43.link), 'level44')) %>% ungroup
level45 <- level44 %>% group_by(level44.link) %>% do(expand_tree(first(.$level44.link), 'level45')) %>% ungroup
level46 <- level45 %>% group_by(level45.link) %>% do(expand_tree(first(.$level45.link), 'level46')) %>% ungroup
level47 <- level46 %>% group_by(level46.link) %>% do(expand_tree(first(.$level46.link), 'level47')) %>% ungroup
level48 <- level47 %>% group_by(level47.link) %>% do(expand_tree(first(.$level47.link), 'level48')) %>% ungroup
level49 <- level48 %>% group_by(level48.link) %>% do(expand_tree(first(.$level48.link), 'level49')) %>% ungroup
level50 <- level49 %>% group_by(level49.link) %>% do(expand_tree(first(.$level49.link), 'level50')) %>% ungroup
level51 <- level50 %>% group_by(level50.link) %>% do(expand_tree(first(.$level50.link), 'level51')) %>% ungroup
level52 <- level51 %>% group_by(level51.link) %>% do(expand_tree(first(.$level51.link), 'level52')) %>% ungroup
level53 <- level52 %>% group_by(level52.link) %>% do(expand_tree(first(.$level52.link), 'level53')) %>% ungroup
level54 <- level53 %>% group_by(level53.link) %>% do(expand_tree(first(.$level53.link), 'level54')) %>% ungroup
level55 <- level54 %>% group_by(level54.link) %>% do(expand_tree(first(.$level54.link), 'level55')) %>% ungroup
level56 <- level55 %>% group_by(level55.link) %>% do(expand_tree(first(.$level55.link), 'level56')) %>% ungroup
level57 <- level56 %>% group_by(level56.link) %>% do(expand_tree(first(.$level56.link), 'level57')) %>% ungroup
level58 <- level57 %>% group_by(level57.link) %>% do(expand_tree(first(.$level57.link), 'level58')) %>% ungroup
level59 <- level58 %>% group_by(level58.link) %>% do(expand_tree(first(.$level58.link), 'level59')) %>% ungroup
level60 <- level59 %>% group_by(level59.link) %>% do(expand_tree(first(.$level59.link), 'level60')) %>% ungroup
level61 <- level60 %>% group_by(level60.link) %>% do(expand_tree(first(.$level60.link), 'level61')) %>% ungroup
level62 <- level61 %>% group_by(level61.link) %>% do(expand_tree(first(.$level61.link), 'level62')) %>% ungroup
level63 <- level62 %>% group_by(level62.link) %>% do(expand_tree(first(.$level62.link), 'level63')) %>% ungroup
level64 <- level63 %>% group_by(level63.link) %>% do(expand_tree(first(.$level63.link), 'level64')) %>% ungroup
level65 <- level64 %>% group_by(level64.link) %>% do(expand_tree(first(.$level64.link), 'level65')) %>% ungroup
level66 <- level65 %>% group_by(level65.link) %>% do(expand_tree(first(.$level65.link), 'level66')) %>% ungroup
level67 <- level66 %>% group_by(level66.link) %>% do(expand_tree(first(.$level66.link), 'level67')) %>% ungroup
level68 <- level67 %>% group_by(level67.link) %>% do(expand_tree(first(.$level67.link), 'level68')) %>% ungroup
level69 <- level68 %>% group_by(level68.link) %>% do(expand_tree(first(.$level68.link), 'level69')) %>% ungroup
level70 <- level69 %>% group_by(level69.link) %>% do(expand_tree(first(.$level69.link), 'level70')) %>% ungroup
level71 <- level70 %>% group_by(level70.link) %>% do(expand_tree(first(.$level70.link), 'level71')) %>% ungroup
level72 <- level71 %>% group_by(level71.link) %>% do(expand_tree(first(.$level71.link), 'level72')) %>% ungroup
level73 <- level72 %>% group_by(level72.link) %>% do(expand_tree(first(.$level72.link), 'level73')) %>% ungroup
level74 <- level73 %>% group_by(level73.link) %>% do(expand_tree(first(.$level73.link), 'level74')) %>% ungroup
level75 <- level74 %>% group_by(level74.link) %>% do(expand_tree(first(.$level74.link), 'level75')) %>% ungroup
level76 <- level75 %>% group_by(level75.link) %>% do(expand_tree(first(.$level75.link), 'level76')) %>% ungroup
level77 <- level76 %>% group_by(level76.link) %>% do(expand_tree(first(.$level76.link), 'level77')) %>% ungroup
level78 <- level77 %>% group_by(level77.link) %>% do(expand_tree(first(.$level77.link), 'level78')) %>% ungroup
level79 <- level78 %>% group_by(level78.link) %>% do(expand_tree(first(.$level78.link), 'level79')) %>% ungroup
level80 <- level79 %>% group_by(level79.link) %>% do(expand_tree(first(.$level79.link), 'level80')) %>% ungroup
level81 <- level80 %>% group_by(level80.link) %>% do(expand_tree(first(.$level80.link), 'level81')) %>% ungroup
level82 <- level81 %>% group_by(level81.link) %>% do(expand_tree(first(.$level81.link), 'level82')) %>% ungroup
level83 <- level82 %>% group_by(level82.link) %>% do(expand_tree(first(.$level82.link), 'level83')) %>% ungroup
level84 <- level83 %>% group_by(level83.link) %>% do(expand_tree(first(.$level83.link), 'level84')) %>% ungroup
level85 <- level84 %>% group_by(level84.link) %>% do(expand_tree(first(.$level84.link), 'level85')) %>% ungroup
level86 <- level85 %>% group_by(level85.link) %>% do(expand_tree(first(.$level85.link), 'level86')) %>% ungroup
level87 <- level86 %>% group_by(level86.link) %>% do(expand_tree(first(.$level86.link), 'level87')) %>% ungroup
level88 <- level87 %>% group_by(level87.link) %>% do(expand_tree(first(.$level87.link), 'level88')) %>% ungroup
level89 <- level88 %>% group_by(level88.link) %>% do(expand_tree(first(.$level88.link), 'level89')) %>% ungroup
level90 <- level89 %>% group_by(level89.link) %>% do(expand_tree(first(.$level89.link), 'level90')) %>% ungroup
level91 <- level90 %>% group_by(level90.link) %>% do(expand_tree(first(.$level90.link), 'level91')) %>% ungroup
level92 <- level91 %>% group_by(level91.link) %>% do(expand_tree(first(.$level91.link), 'level92')) %>% ungroup
level93 <- level92 %>% group_by(level92.link) %>% do(expand_tree(first(.$level92.link), 'level93')) %>% ungroup
level94 <- level93 %>% group_by(level93.link) %>% do(expand_tree(first(.$level93.link), 'level94')) %>% ungroup
level95 <- level94 %>% group_by(level94.link) %>% do(expand_tree(first(.$level94.link), 'level95')) %>% ungroup
level96 <- level95 %>% group_by(level95.link) %>% do(expand_tree(first(.$level95.link), 'level96')) %>% ungroup
level97 <- level96 %>% group_by(level96.link) %>% do(expand_tree(first(.$level96.link), 'level97')) %>% ungroup
level98 <- level97 %>% group_by(level97.link) %>% do(expand_tree(first(.$level97.link), 'level98')) %>% ungroup
level99 <- level98 %>% group_by(level98.link) %>% do(expand_tree(first(.$level98.link), 'level99')) %>% ungroup
level100 <- level99 %>% group_by(level99.link) %>% do(expand_tree(first(.$level99.link), 'level100')) %>% ungroup


