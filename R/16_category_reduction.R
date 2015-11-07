#!/usr/bin/Rscript --vanilla

#############################


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

# level1 <- 
#   'http://pl.wikipedia.org/wiki/Wikipedia:Drzewo_kategorii' %>%
#   expand_tree("level1") %>%
#   slice(-c(1:10, 14, 69, 96, 101, 155, 176, 188, 220, 234))# %>%
#   #slice(220:225)
# 
# save(list = 'level1', file = "/home/npotocka/mgr/Data/RObjects/level1.rda")
# 
# load("/home/npotocka/mgr/Data/RObjects/level1.rda")
# level2 <- 
#   level1 %>%
#   group_by(level1.link) %>%
#   do(expand_tree(first(.$level1.link), "level2")) %>%
#   ungroup
# 
# save(list = 'level2', file = "/home/npotocka/mgr/Data/RObjects/level2.rda")
# rm(level1)
# 
# 
# level3 <- 
#   level2 %>%
#   group_by(level2.link) %>%
#   do(expand_tree(first(.$level2.link), "level3")) %>%
#   ungroup
# 
# save(list = 'level3', file = "/home/npotocka/mgr/Data/RObjects/level3.rda")
# rm(level2)
# 
# level4 <- 
#   level3 %>%
#   group_by(level3.link) %>%
#   do(expand_tree(first(.$level3.link), "level4")) %>%
#   ungroup
# save(list = 'level4', file = "/home/npotocka/mgr/Data/RObjects/level4.rda")
# rm(level3)

# for(i in 5:100){
#   print(stri_flatten(c('print(', i, ')')))
#   print(stri_flatten(c(sprintf("level%d <- level%d", i, i-1), 
#     sprintf("group_by(level%d.link)", i-1),
#     sprintf("do(expand_tree(first(.$level%d.link), 'level%d'))", i-1, i),
#     "ungroup"), collapse = " %>% "))
#   print(sprintf("save(list = 'level%d', file = '/home/npotocka/mgr/Data/RObjects/level%d.rda')", i, i))
#   print(sprintf("rm(level%d)", i-1))
# }

########################
########################
# 
# print(5)
# level5 <- level4 %>% group_by(level4.link) %>% do(expand_tree(first(.$level4.link), 'level5')) %>% ungroup
# save(list = 'level5', file = '/home/npotocka/mgr/Data/RObjects/level5.rda')
# rm(level4)
load("/home/npotocka/mgr/Data/RObjects/level5.rda")
print(6)
<<<<<<< HEAD
level51 <- level5[1:27831,]
level52 <- level5[27832:55663,]
level53 <- level5[55664:83494,]
level54 <- level5[83495:111326,]

level61 <- level51 %>% group_by(level5.link) %>% do(expand_tree(first(.$level5.link), 'level6')) %>% ungroup
level62 <- level52 %>% group_by(level5.link) %>% do(expand_tree(first(.$level5.link), 'level6')) %>% ungroup
level63 <- level53 %>% group_by(level5.link) %>% do(expand_tree(first(.$level5.link), 'level6')) %>% ungroup
level64 <- level54 %>% group_by(level5.link) %>% do(expand_tree(first(.$level5.link), 'level6')) %>% ungroup


save(list = 'level61', file = '/home/npotocka/mgr/Data/RObjects/level61.rda')
level6 <- bind_rows(level61, level62)

level6 <- level5 %>% group_by(level5.link) %>% do(expand_tree(first(.$level5.link), 'level6')) %>% ungroup
save(list = 'level6', file = '/home/npotocka/mgr/Data/RObjects/level6.rda')
rm(level5)
print(7)
level7 <- level6 %>% group_by(level6.link) %>% do(expand_tree(first(.$level6.link), 'level7')) %>% ungroup
save(list = 'level7', file = '/home/npotocka/mgr/Data/RObjects/level7.rda')
rm(level6)
print(8)
level8 <- level7 %>% group_by(level7.link) %>% do(expand_tree(first(.$level7.link), 'level8')) %>% ungroup
save(list = 'level8', file = '/home/npotocka/mgr/Data/RObjects/level8.rda')
rm(level7)
print(9)
level9 <- level8 %>% group_by(level8.link) %>% do(expand_tree(first(.$level8.link), 'level9')) %>% ungroup
save(list = 'level9', file = '/home/npotocka/mgr/Data/RObjects/level9.rda')
rm(level8)
print(10)
level10 <- level9 %>% group_by(level9.link) %>% do(expand_tree(first(.$level9.link), 'level10')) %>% ungroup
save(list = 'level10', file = '/home/npotocka/mgr/Data/RObjects/level10.rda')
rm(level9)
print(11)
level11 <- level10 %>% group_by(level10.link) %>% do(expand_tree(first(.$level10.link), 'level11')) %>% ungroup
save(list = 'level11', file = '/home/npotocka/mgr/Data/RObjects/level11.rda')
rm(level10)
print(12)
level12 <- level11 %>% group_by(level11.link) %>% do(expand_tree(first(.$level11.link), 'level12')) %>% ungroup
save(list = 'level12', file = '/home/npotocka/mgr/Data/RObjects/level12.rda')
rm(level11)
print(13)
level13 <- level12 %>% group_by(level12.link) %>% do(expand_tree(first(.$level12.link), 'level13')) %>% ungroup
save(list = 'level13', file = '/home/npotocka/mgr/Data/RObjects/level13.rda')
rm(level12)
print(14)
level14 <- level13 %>% group_by(level13.link) %>% do(expand_tree(first(.$level13.link), 'level14')) %>% ungroup
save(list = 'level14', file = '/home/npotocka/mgr/Data/RObjects/level14.rda')
rm(level13)
print(15)
level15 <- level14 %>% group_by(level14.link) %>% do(expand_tree(first(.$level14.link), 'level15')) %>% ungroup
save(list = 'level15', file = '/home/npotocka/mgr/Data/RObjects/level15.rda')
rm(level14)
print(16)
level16 <- level15 %>% group_by(level15.link) %>% do(expand_tree(first(.$level15.link), 'level16')) %>% ungroup
save(list = 'level16', file = '/home/npotocka/mgr/Data/RObjects/level16.rda')
rm(level15)
print(17)
level17 <- level16 %>% group_by(level16.link) %>% do(expand_tree(first(.$level16.link), 'level17')) %>% ungroup
save(list = 'level17', file = '/home/npotocka/mgr/Data/RObjects/level17.rda')
rm(level16)
print(18)
level18 <- level17 %>% group_by(level17.link) %>% do(expand_tree(first(.$level17.link), 'level18')) %>% ungroup
save(list = 'level18', file = '/home/npotocka/mgr/Data/RObjects/level18.rda')
rm(level17)
print(19)
level19 <- level18 %>% group_by(level18.link) %>% do(expand_tree(first(.$level18.link), 'level19')) %>% ungroup
save(list = 'level19', file = '/home/npotocka/mgr/Data/RObjects/level19.rda')
rm(level18)
print(20)
level20 <- level19 %>% group_by(level19.link) %>% do(expand_tree(first(.$level19.link), 'level20')) %>% ungroup
save(list = 'level20', file = '/home/npotocka/mgr/Data/RObjects/level20.rda')
rm(level19)
print(21)
level21 <- level20 %>% group_by(level20.link) %>% do(expand_tree(first(.$level20.link), 'level21')) %>% ungroup
save(list = 'level21', file = '/home/npotocka/mgr/Data/RObjects/level21.rda')
rm(level20)
print(22)
level22 <- level21 %>% group_by(level21.link) %>% do(expand_tree(first(.$level21.link), 'level22')) %>% ungroup
save(list = 'level22', file = '/home/npotocka/mgr/Data/RObjects/level22.rda')
rm(level21)
print(23)
level23 <- level22 %>% group_by(level22.link) %>% do(expand_tree(first(.$level22.link), 'level23')) %>% ungroup
save(list = 'level23', file = '/home/npotocka/mgr/Data/RObjects/level23.rda')
rm(level22)
print(24)
level24 <- level23 %>% group_by(level23.link) %>% do(expand_tree(first(.$level23.link), 'level24')) %>% ungroup
save(list = 'level24', file = '/home/npotocka/mgr/Data/RObjects/level24.rda')
rm(level23)
print(25)
level25 <- level24 %>% group_by(level24.link) %>% do(expand_tree(first(.$level24.link), 'level25')) %>% ungroup
save(list = 'level25', file = '/home/npotocka/mgr/Data/RObjects/level25.rda')
rm(level24)
print(26)
level26 <- level25 %>% group_by(level25.link) %>% do(expand_tree(first(.$level25.link), 'level26')) %>% ungroup
save(list = 'level26', file = '/home/npotocka/mgr/Data/RObjects/level26.rda')
rm(level25)
print(27)
level27 <- level26 %>% group_by(level26.link) %>% do(expand_tree(first(.$level26.link), 'level27')) %>% ungroup
save(list = 'level27', file = '/home/npotocka/mgr/Data/RObjects/level27.rda')
rm(level26)
print(28)
level28 <- level27 %>% group_by(level27.link) %>% do(expand_tree(first(.$level27.link), 'level28')) %>% ungroup
save(list = 'level28', file = '/home/npotocka/mgr/Data/RObjects/level28.rda')
rm(level27)
print(29)
level29 <- level28 %>% group_by(level28.link) %>% do(expand_tree(first(.$level28.link), 'level29')) %>% ungroup
save(list = 'level29', file = '/home/npotocka/mgr/Data/RObjects/level29.rda')
rm(level28)
print(30)
level30 <- level29 %>% group_by(level29.link) %>% do(expand_tree(first(.$level29.link), 'level30')) %>% ungroup
save(list = 'level30', file = '/home/npotocka/mgr/Data/RObjects/level30.rda')
rm(level29)
print(31)
level31 <- level30 %>% group_by(level30.link) %>% do(expand_tree(first(.$level30.link), 'level31')) %>% ungroup
save(list = 'level31', file = '/home/npotocka/mgr/Data/RObjects/level31.rda')
rm(level30)
print(32)
level32 <- level31 %>% group_by(level31.link) %>% do(expand_tree(first(.$level31.link), 'level32')) %>% ungroup
save(list = 'level32', file = '/home/npotocka/mgr/Data/RObjects/level32.rda')
rm(level31)
print(33)
level33 <- level32 %>% group_by(level32.link) %>% do(expand_tree(first(.$level32.link), 'level33')) %>% ungroup
save(list = 'level33', file = '/home/npotocka/mgr/Data/RObjects/level33.rda')
rm(level32)
print(34)
level34 <- level33 %>% group_by(level33.link) %>% do(expand_tree(first(.$level33.link), 'level34')) %>% ungroup
save(list = 'level34', file = '/home/npotocka/mgr/Data/RObjects/level34.rda')
rm(level33)
print(35)
level35 <- level34 %>% group_by(level34.link) %>% do(expand_tree(first(.$level34.link), 'level35')) %>% ungroup
save(list = 'level35', file = '/home/npotocka/mgr/Data/RObjects/level35.rda')
rm(level34)
print(36)
level36 <- level35 %>% group_by(level35.link) %>% do(expand_tree(first(.$level35.link), 'level36')) %>% ungroup
save(list = 'level36', file = '/home/npotocka/mgr/Data/RObjects/level36.rda')
rm(level35)
print(37)
level37 <- level36 %>% group_by(level36.link) %>% do(expand_tree(first(.$level36.link), 'level37')) %>% ungroup
save(list = 'level37', file = '/home/npotocka/mgr/Data/RObjects/level37.rda')
rm(level36)
print(38)
level38 <- level37 %>% group_by(level37.link) %>% do(expand_tree(first(.$level37.link), 'level38')) %>% ungroup
save(list = 'level38', file = '/home/npotocka/mgr/Data/RObjects/level38.rda')
rm(level37)
print(39)
level39 <- level38 %>% group_by(level38.link) %>% do(expand_tree(first(.$level38.link), 'level39')) %>% ungroup
save(list = 'level39', file = '/home/npotocka/mgr/Data/RObjects/level39.rda')
rm(level38)
print(40)
level40 <- level39 %>% group_by(level39.link) %>% do(expand_tree(first(.$level39.link), 'level40')) %>% ungroup
save(list = 'level40', file = '/home/npotocka/mgr/Data/RObjects/level40.rda')
rm(level39)
print(41)
level41 <- level40 %>% group_by(level40.link) %>% do(expand_tree(first(.$level40.link), 'level41')) %>% ungroup
save(list = 'level41', file = '/home/npotocka/mgr/Data/RObjects/level41.rda')
rm(level40)
print(42)
level42 <- level41 %>% group_by(level41.link) %>% do(expand_tree(first(.$level41.link), 'level42')) %>% ungroup
save(list = 'level42', file = '/home/npotocka/mgr/Data/RObjects/level42.rda')
rm(level41)
print(43)
level43 <- level42 %>% group_by(level42.link) %>% do(expand_tree(first(.$level42.link), 'level43')) %>% ungroup
save(list = 'level43', file = '/home/npotocka/mgr/Data/RObjects/level43.rda')
rm(level42)
print(44)
level44 <- level43 %>% group_by(level43.link) %>% do(expand_tree(first(.$level43.link), 'level44')) %>% ungroup
save(list = 'level44', file = '/home/npotocka/mgr/Data/RObjects/level44.rda')
rm(level43)
print(45)
level45 <- level44 %>% group_by(level44.link) %>% do(expand_tree(first(.$level44.link), 'level45')) %>% ungroup
save(list = 'level45', file = '/home/npotocka/mgr/Data/RObjects/level45.rda')
rm(level44)
print(46)
level46 <- level45 %>% group_by(level45.link) %>% do(expand_tree(first(.$level45.link), 'level46')) %>% ungroup
save(list = 'level46', file = '/home/npotocka/mgr/Data/RObjects/level46.rda')
rm(level45)
print(47)
level47 <- level46 %>% group_by(level46.link) %>% do(expand_tree(first(.$level46.link), 'level47')) %>% ungroup
save(list = 'level47', file = '/home/npotocka/mgr/Data/RObjects/level47.rda')
rm(level46)
print(48)
level48 <- level47 %>% group_by(level47.link) %>% do(expand_tree(first(.$level47.link), 'level48')) %>% ungroup
save(list = 'level48', file = '/home/npotocka/mgr/Data/RObjects/level48.rda')
rm(level47)
print(49)
level49 <- level48 %>% group_by(level48.link) %>% do(expand_tree(first(.$level48.link), 'level49')) %>% ungroup
save(list = 'level49', file = '/home/npotocka/mgr/Data/RObjects/level49.rda')
rm(level48)
print(50)
level50 <- level49 %>% group_by(level49.link) %>% do(expand_tree(first(.$level49.link), 'level50')) %>% ungroup
save(list = 'level50', file = '/home/npotocka/mgr/Data/RObjects/level50.rda')
rm(level49)
print(51)
level51 <- level50 %>% group_by(level50.link) %>% do(expand_tree(first(.$level50.link), 'level51')) %>% ungroup
save(list = 'level51', file = '/home/npotocka/mgr/Data/RObjects/level51.rda')
rm(level50)
print(52)
level52 <- level51 %>% group_by(level51.link) %>% do(expand_tree(first(.$level51.link), 'level52')) %>% ungroup
save(list = 'level52', file = '/home/npotocka/mgr/Data/RObjects/level52.rda')
rm(level51)
print(53)
level53 <- level52 %>% group_by(level52.link) %>% do(expand_tree(first(.$level52.link), 'level53')) %>% ungroup
save(list = 'level53', file = '/home/npotocka/mgr/Data/RObjects/level53.rda')
rm(level52)
print(54)
level54 <- level53 %>% group_by(level53.link) %>% do(expand_tree(first(.$level53.link), 'level54')) %>% ungroup
save(list = 'level54', file = '/home/npotocka/mgr/Data/RObjects/level54.rda')
rm(level53)
print(55)
level55 <- level54 %>% group_by(level54.link) %>% do(expand_tree(first(.$level54.link), 'level55')) %>% ungroup
save(list = 'level55', file = '/home/npotocka/mgr/Data/RObjects/level55.rda')
rm(level54)
print(56)
level56 <- level55 %>% group_by(level55.link) %>% do(expand_tree(first(.$level55.link), 'level56')) %>% ungroup
save(list = 'level56', file = '/home/npotocka/mgr/Data/RObjects/level56.rda')
rm(level55)
print(57)
level57 <- level56 %>% group_by(level56.link) %>% do(expand_tree(first(.$level56.link), 'level57')) %>% ungroup
save(list = 'level57', file = '/home/npotocka/mgr/Data/RObjects/level57.rda')
rm(level56)
print(58)
level58 <- level57 %>% group_by(level57.link) %>% do(expand_tree(first(.$level57.link), 'level58')) %>% ungroup
save(list = 'level58', file = '/home/npotocka/mgr/Data/RObjects/level58.rda')
rm(level57)
print(59)
level59 <- level58 %>% group_by(level58.link) %>% do(expand_tree(first(.$level58.link), 'level59')) %>% ungroup
save(list = 'level59', file = '/home/npotocka/mgr/Data/RObjects/level59.rda')
rm(level58)
print(60)
level60 <- level59 %>% group_by(level59.link) %>% do(expand_tree(first(.$level59.link), 'level60')) %>% ungroup
save(list = 'level60', file = '/home/npotocka/mgr/Data/RObjects/level60.rda')
rm(level59)
print(61)
level61 <- level60 %>% group_by(level60.link) %>% do(expand_tree(first(.$level60.link), 'level61')) %>% ungroup
save(list = 'level61', file = '/home/npotocka/mgr/Data/RObjects/level61.rda')
rm(level60)
print(62)
level62 <- level61 %>% group_by(level61.link) %>% do(expand_tree(first(.$level61.link), 'level62')) %>% ungroup
save(list = 'level62', file = '/home/npotocka/mgr/Data/RObjects/level62.rda')
rm(level61)
print(63)
level63 <- level62 %>% group_by(level62.link) %>% do(expand_tree(first(.$level62.link), 'level63')) %>% ungroup
save(list = 'level63', file = '/home/npotocka/mgr/Data/RObjects/level63.rda')
rm(level62)
print(64)
level64 <- level63 %>% group_by(level63.link) %>% do(expand_tree(first(.$level63.link), 'level64')) %>% ungroup
save(list = 'level64', file = '/home/npotocka/mgr/Data/RObjects/level64.rda')
rm(level63)
print(65)
level65 <- level64 %>% group_by(level64.link) %>% do(expand_tree(first(.$level64.link), 'level65')) %>% ungroup
save(list = 'level65', file = '/home/npotocka/mgr/Data/RObjects/level65.rda')
rm(level64)
print(66)
level66 <- level65 %>% group_by(level65.link) %>% do(expand_tree(first(.$level65.link), 'level66')) %>% ungroup
save(list = 'level66', file = '/home/npotocka/mgr/Data/RObjects/level66.rda')
rm(level65)
print(67)
level67 <- level66 %>% group_by(level66.link) %>% do(expand_tree(first(.$level66.link), 'level67')) %>% ungroup
save(list = 'level67', file = '/home/npotocka/mgr/Data/RObjects/level67.rda')
rm(level66)
print(68)
level68 <- level67 %>% group_by(level67.link) %>% do(expand_tree(first(.$level67.link), 'level68')) %>% ungroup
save(list = 'level68', file = '/home/npotocka/mgr/Data/RObjects/level68.rda')
rm(level67)
print(69)
level69 <- level68 %>% group_by(level68.link) %>% do(expand_tree(first(.$level68.link), 'level69')) %>% ungroup
save(list = 'level69', file = '/home/npotocka/mgr/Data/RObjects/level69.rda')
rm(level68)
print(70)
level70 <- level69 %>% group_by(level69.link) %>% do(expand_tree(first(.$level69.link), 'level70')) %>% ungroup
save(list = 'level70', file = '/home/npotocka/mgr/Data/RObjects/level70.rda')
rm(level69)
print(71)
level71 <- level70 %>% group_by(level70.link) %>% do(expand_tree(first(.$level70.link), 'level71')) %>% ungroup
save(list = 'level71', file = '/home/npotocka/mgr/Data/RObjects/level71.rda')
rm(level70)
print(72)
level72 <- level71 %>% group_by(level71.link) %>% do(expand_tree(first(.$level71.link), 'level72')) %>% ungroup
save(list = 'level72', file = '/home/npotocka/mgr/Data/RObjects/level72.rda')
rm(level71)
print(73)
level73 <- level72 %>% group_by(level72.link) %>% do(expand_tree(first(.$level72.link), 'level73')) %>% ungroup
save(list = 'level73', file = '/home/npotocka/mgr/Data/RObjects/level73.rda')
rm(level72)
print(74)
level74 <- level73 %>% group_by(level73.link) %>% do(expand_tree(first(.$level73.link), 'level74')) %>% ungroup
save(list = 'level74', file = '/home/npotocka/mgr/Data/RObjects/level74.rda')
rm(level73)
print(75)
level75 <- level74 %>% group_by(level74.link) %>% do(expand_tree(first(.$level74.link), 'level75')) %>% ungroup
save(list = 'level75', file = '/home/npotocka/mgr/Data/RObjects/level75.rda')
rm(level74)
print(76)
level76 <- level75 %>% group_by(level75.link) %>% do(expand_tree(first(.$level75.link), 'level76')) %>% ungroup
save(list = 'level76', file = '/home/npotocka/mgr/Data/RObjects/level76.rda')
rm(level75)
print(77)
level77 <- level76 %>% group_by(level76.link) %>% do(expand_tree(first(.$level76.link), 'level77')) %>% ungroup
save(list = 'level77', file = '/home/npotocka/mgr/Data/RObjects/level77.rda')
rm(level76)
print(78)
level78 <- level77 %>% group_by(level77.link) %>% do(expand_tree(first(.$level77.link), 'level78')) %>% ungroup
save(list = 'level78', file = '/home/npotocka/mgr/Data/RObjects/level78.rda')
rm(level77)
print(79)
level79 <- level78 %>% group_by(level78.link) %>% do(expand_tree(first(.$level78.link), 'level79')) %>% ungroup
save(list = 'level79', file = '/home/npotocka/mgr/Data/RObjects/level79.rda')
rm(level78)
print(80)
level80 <- level79 %>% group_by(level79.link) %>% do(expand_tree(first(.$level79.link), 'level80')) %>% ungroup
save(list = 'level80', file = '/home/npotocka/mgr/Data/RObjects/level80.rda')
rm(level79)
print(81)
level81 <- level80 %>% group_by(level80.link) %>% do(expand_tree(first(.$level80.link), 'level81')) %>% ungroup
save(list = 'level81', file = '/home/npotocka/mgr/Data/RObjects/level81.rda')
rm(level80)
print(82)
level82 <- level81 %>% group_by(level81.link) %>% do(expand_tree(first(.$level81.link), 'level82')) %>% ungroup
save(list = 'level82', file = '/home/npotocka/mgr/Data/RObjects/level82.rda')
rm(level81)
print(83)
level83 <- level82 %>% group_by(level82.link) %>% do(expand_tree(first(.$level82.link), 'level83')) %>% ungroup
save(list = 'level83', file = '/home/npotocka/mgr/Data/RObjects/level83.rda')
rm(level82)
print(84)
level84 <- level83 %>% group_by(level83.link) %>% do(expand_tree(first(.$level83.link), 'level84')) %>% ungroup
save(list = 'level84', file = '/home/npotocka/mgr/Data/RObjects/level84.rda')
rm(level83)
print(85)
level85 <- level84 %>% group_by(level84.link) %>% do(expand_tree(first(.$level84.link), 'level85')) %>% ungroup
save(list = 'level85', file = '/home/npotocka/mgr/Data/RObjects/level85.rda')
rm(level84)
print(86)
level86 <- level85 %>% group_by(level85.link) %>% do(expand_tree(first(.$level85.link), 'level86')) %>% ungroup
save(list = 'level86', file = '/home/npotocka/mgr/Data/RObjects/level86.rda')
rm(level85)
print(87)
level87 <- level86 %>% group_by(level86.link) %>% do(expand_tree(first(.$level86.link), 'level87')) %>% ungroup
save(list = 'level87', file = '/home/npotocka/mgr/Data/RObjects/level87.rda')
rm(level86)
print(88)
level88 <- level87 %>% group_by(level87.link) %>% do(expand_tree(first(.$level87.link), 'level88')) %>% ungroup
save(list = 'level88', file = '/home/npotocka/mgr/Data/RObjects/level88.rda')
rm(level87)
print(89)
level89 <- level88 %>% group_by(level88.link) %>% do(expand_tree(first(.$level88.link), 'level89')) %>% ungroup
save(list = 'level89', file = '/home/npotocka/mgr/Data/RObjects/level89.rda')
rm(level88)
print(90)
level90 <- level89 %>% group_by(level89.link) %>% do(expand_tree(first(.$level89.link), 'level90')) %>% ungroup
save(list = 'level90', file = '/home/npotocka/mgr/Data/RObjects/level90.rda')
rm(level89)
print(91)
level91 <- level90 %>% group_by(level90.link) %>% do(expand_tree(first(.$level90.link), 'level91')) %>% ungroup
save(list = 'level91', file = '/home/npotocka/mgr/Data/RObjects/level91.rda')
rm(level90)
print(92)
level92 <- level91 %>% group_by(level91.link) %>% do(expand_tree(first(.$level91.link), 'level92')) %>% ungroup
save(list = 'level92', file = '/home/npotocka/mgr/Data/RObjects/level92.rda')
rm(level91)
print(93)
level93 <- level92 %>% group_by(level92.link) %>% do(expand_tree(first(.$level92.link), 'level93')) %>% ungroup
save(list = 'level93', file = '/home/npotocka/mgr/Data/RObjects/level93.rda')
rm(level92)
print(94)
level94 <- level93 %>% group_by(level93.link) %>% do(expand_tree(first(.$level93.link), 'level94')) %>% ungroup
save(list = 'level94', file = '/home/npotocka/mgr/Data/RObjects/level94.rda')
rm(level93)
print(95)
level95 <- level94 %>% group_by(level94.link) %>% do(expand_tree(first(.$level94.link), 'level95')) %>% ungroup
save(list = 'level95', file = '/home/npotocka/mgr/Data/RObjects/level95.rda')
rm(level94)
print(96)
level96 <- level95 %>% group_by(level95.link) %>% do(expand_tree(first(.$level95.link), 'level96')) %>% ungroup
save(list = 'level96', file = '/home/npotocka/mgr/Data/RObjects/level96.rda')
rm(level95)
print(97)
level97 <- level96 %>% group_by(level96.link) %>% do(expand_tree(first(.$level96.link), 'level97')) %>% ungroup
save(list = 'level97', file = '/home/npotocka/mgr/Data/RObjects/level97.rda')
rm(level96)
print(98)
level98 <- level97 %>% group_by(level97.link) %>% do(expand_tree(first(.$level97.link), 'level98')) %>% ungroup
save(list = 'level98', file = '/home/npotocka/mgr/Data/RObjects/level98.rda')
rm(level97)
print(99)
level99 <- level98 %>% group_by(level98.link) %>% do(expand_tree(first(.$level98.link), 'level99')) %>% ungroup
save(list = 'level99', file = '/home/npotocka/mgr/Data/RObjects/level99.rda')
rm(level98)
print(100)
level100 <- level99 %>% group_by(level99.link) %>% do(expand_tree(first(.$level99.link), 'level100')) %>% ungroup
save(list = 'level100', file = '/home/npotocka/mgr/Data/RObjects/level100.rda')
rm(level99)
########################

for(i in 1:100)
  eval(parse(text = sprintf("load('/home/npotocka/mgr/Data/RObjects/level%d.rda')", i)))

library(dplyr)

kateg <- level1

for(i in 1:100){
  kateg <- kateg %>% 
    full_join(eval(parse(text = paste0('level', i+1)))) %>% 
    select_(paste0('-level', i, '.link'))
}

kateg <- kateg %>% select(-level16.link)

save(list = 'kateg', file = '/home/npotocka/mgr/Data/RObjects/categ.rda')

# 
# for(i in 1:16)
#   print(nrow(unique(kateg[,i])))
