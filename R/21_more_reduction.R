
library(rvest)
library(dplyr)
library(stringi)
library(Hmisc)
library(RSQLite)
library(compiler)

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


###############

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

level00 <- 
  'http://pl.wikipedia.org/wiki/Wikipedia:Drzewo_kategorii' %>%
  expand_tree("level1") %>%
  slice(c(10, 14, 69, 96, 101, 155, 176, 188, 220, 234))


load("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/categories/level1.rda")


sum(unique(kategorie$nowa_kat) %in% stri_trans_tolower(c('Ezoteryka',
'Kreacjonizm',
'Medycyna niekonwencjonalna',
'Paranauka',
'Parapsychologia',
'Programowanie neurolingwistyczne',
'Przepowiednie',
'Pseudonaukowcy',
'Radiestezja',
'Spirytyzm',
'Wolna energia',
'Zjawiska paranormalne'))) #pseudonauka



sum(unique(kategorie$nowa_kat) %in% stri_trans_tolower(c(
'Nauki techniczne',
'Strony przeglądowe - technika',
'Historia techniki',
'Modelarstwo',
'Pożarnictwo',
'Prawo własności przemysłowej',
'Produkcja',
'Przedmioty codziennego użytku',
'Rzemiosło',
'Społeczność techniczna',
'Technika filmowa',
'Technika jądrowa',
'Technika satelitarna',
'Technika szpiegowska',
'Technika wojskowa',
'Technologia',
'Technologia fantastyczna',
'Transport',
'Uczelnie techniczne według państw',
'Urządzenia'
))) # Technika

technika <- stri_trans_tolower(c(
  'Nauki techniczne',
  'Strony przeglądowe - technika',
  'Historia techniki',
  'Modelarstwo',
  'Pożarnictwo',
  'Prawo własności przemysłowej',
  'Produkcja',
  'Przedmioty codziennego użytku',
  'Rzemiosło',
  'Społeczność techniczna',
  'Technika filmowa',
  'Technika jądrowa',
  'Technika satelitarna',
  'Technika szpiegowska',
  'Technika wojskowa',
  'Technologia',
  'Technologia fantastyczna',
  'Transport',
  'Uczelnie techniczne według państw',
  'Urządzenia'
))

sum(unique(kategorie$nowa_kat) %in% stri_trans_tolower(c(
'Rankingi',
'Tablice'
,'Skarbnica Wikipedii'
,'Strony przeglądowe - biografie'
,'Kalendaria'
,'Strony przeglądowe - kultura'
,'Listy zamachów terrorystycznych'
,'Listy na medal'
,'Strony przeglądowe - nauka'
,'Strony przeglądowe - społeczeństwo'
,'Strony przeglądowe - technika'
,'Strony przeglądowe - uczelnie'
))) # Strony przeglądowe

str_prz <- stri_trans_tolower(c(
  'Rankingi',
  'Tablice'
  ,'Skarbnica Wikipedii'
  ,'Strony przeglądowe - biografie'
  ,'Kalendaria'
  ,'Strony przeglądowe - kultura'
  ,'Listy zamachów terrorystycznych'
  ,'Listy na medal'
  ,'Strony przeglądowe - nauka'
  ,'Strony przeglądowe - społeczeństwo'
  ,'Strony przeglądowe - technika'
  ,'Strony przeglądowe - uczelnie'
))

kategorie <- cbind(kategorie, character(nrow(kategorie)))
names(kategorie)[6] <- "nowa_kat2"
kategorie$nowa_kat2 <- as.character(kategorie$nowa_kat2)
kategorie$nowa_kat2 <- kategorie$nowa_kat
for(i in 1:nrow(kategorie)){
  kat <- kategorie$nowa_kat[i]
  if(kat %in% technika)
    kategorie$nowa_kat2[i] <- 'technika'
  if(kat %in% str_prz)
    kategorie$nowa_kat2[i] <- 'strony przeglądowe'
    
}

kategorie$nowa_kat2[kategorie$nowa_kat2 == 'chleb'] <- 'potrawy według głównych składników'

save(list = 'kategorie', file = "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/categories/kategorie20151118.rda")
load("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/categories/kategorie20151118.rda")


###############





nieskl <- kategorie$name_new[kategorie$nowa_kat == ""]

nieskl <- data.frame(name = nieskl)


nieskl <- left_join(nieskl, level10)

for(i in 1:nrow(nieskl)){
  index <- c(which(kategorie$nowa_kat2 == nieskl$name[i]), 
    which(kategorie$nowa_kat == nieskl$name[i]))
  if(length(index) != 0)
    nieskl$level1.name[i] <- kategorie$nowa_kat2[index[1]]
  
}

nieskl <- nieskl %>% group_by(name) %>% distinct()

for(i in 1:nrow(nieskl)){
  index <- c(which(kategorie$name_new == nieskl$level1.name[i]))
  if(length(index) != 0 & any(kategorie$nowa_kat2[index] != ''))
    nieskl$level1.name[i] <- kategorie$nowa_kat2[index[(kategorie$name_new[index] != '')[1]]]
  
}

nieskl$level1.name[4] <- 'klasyfikacja nauk'
nieskl$level1.name[9] <- 'klasyfikacja nauk'
nieskl$level1.name[10] <- 'kategorie według istot i stworzeń fantastycznych'
nieskl$level1.name[11] <- 'społeczeństwo'
nieskl$level1.name[14] <- 'klasyfikacja nauk'
nieskl$level1.name[15] <- 'klasyfikacja nauk'
nieskl$level1.name[17] <- 'klasyfikacja nauk'
nieskl$level1.name[19] <- 'kategorie według położenia geograficznego'
nieskl$level1.name[20] <- 'sport'
nieskl$level1.name[19] <- 'kategorie według położenia geograficznego'
nieskl$level1.name[c(21,22,23,25,26,27,39:48,56,58:61, 63, 67,72, 74:76, 78,85,89,92:96, 100, 101, 103:111,114,120,120)] <- 'kategorie według położenia geograficznego'


geo <- which(stri_detect_regex(stri_trans_tolower(nieskl$name), "raczy|sydney|pobrzeże|rudawy|cmentarz|skałki|wody|warszaw|krakow|wyżyn|słowack|pienin|wodne|rejony buriacji|nizin|wop|praga|państw|pojezierze|warszawa|krajobraz|kamienic|rynek|północ|nizina|linia|wodna|prl|gatun|strażni|region|nornik|kraj|ocean|gdańsk|powiat|alp|rio|azja|pasmo|przełęcz|hrabstw|śląsk|dzielnic|tatr|beskid|szczyt|wysp|administr|potok|rzek|wsi|miejscowoś|gmin|jezior|miast|porty|dystrykt|gór"))
nieskl$level1.name[geo] <- 'kategorie według położenia geograficznego'

sw <- which(stri_detect_regex(stri_trans_tolower(nieskl$name), 'kanonu|kurii|katolic|orunia|zakonni|eparchi|kości|diecezj|świątynie|chrystus|wezwani|zbor|jehow|parafi|święt'))
nieskl$level1.name[sw] <- 'religie'

woj <- which(stri_detect_regex(stri_trans_tolower(nieskl$name), 'organizacje|ordynacje|druży|władz|rządy|order|sił powietrznych|fantastycz|staroż|senat|sejm|żołnierz|polowe|herb|pistole|batalion|arm|wojsk|pułk|dywizj|altyleri|kawaleri|piechot'))
nieskl$level1.name[woj] <- 'społeczeństwo'


sp <- which(stri_detect_regex(stri_trans_tolower(nieskl$name), 'memoria|żagl|żużlu|żeglug|siatkar|stadion|sezon|league|piłka|formuł|żużel|sport|mistrzostwa|świat|puchar'))
nieskl$level1.name[sp] <- 'sport'

eak <- which(stri_detect_regex(stri_trans_tolower(nieskl$name), 'panther|amonit|diaz|jaszczur|łaszo|ryby|gady|bławatniki|synaps|ssaki|krzepni|morfogenet|kształtne|szczuroskoczkowate|argiolestidae|krętorog|azolidy|głupkow|mięczak|ślimak|zębowc|mroczko|roślin|gorzyk|kawa|azynany|makako|ptak'))
nieskl$level1.name[eak] <- 'klasyfikacja nauk'

kult <- which(stri_detect_regex(stri_trans_tolower(nieskl$name), 'teloschistales|brygad|orderem|staroż|parti|średniow|chińs'))
nieskl$level1.name[kult] <- 'etnologia i antropologia kulturowa'

szt <-  which(stri_detect_regex(stri_trans_tolower(nieskl$name), 'adelajda|scena|romek|film|oper|album|artys|artyś|piosenk|singl|sztuka|koncert|zespoł|zespół'))
nieskl$level1.name[szt] <- 'sztuka'

tech <- which(stri_detect_regex(stri_trans_tolower(nieskl$name), 'autobus|proceso|linuks|kolej|motorola|lokomot|ubunt|licyt|silnik'))
nieskl$level1.name[tech] <- 'technika'

str <- which(stri_detect_regex(stri_trans_tolower(nieskl$name), 'siog|nts'))
nieskl$level1.name[str] <- 'strony przeglądowe'

para <- which(stri_detect_regex(stri_trans_tolower(nieskl$name), 'paraps|paranau'))
nieskl$level1.name[para] <- 'paranauka'

trylo <- which(stri_detect_regex(stri_trans_tolower(nieskl$name), 'biografie|trylobit'))
nieskl$level1.name[trylo] <- 'biografie według epok i okresów historycznych'

bio <- which(stri_detect_regex(stri_trans_tolower(nieskl$name), 'encyklopedii'))
nieskl$level1.name[bio] <- 'biografie według profesji'

info <- which(stri_detect_regex(stri_trans_tolower(nieskl$name), 'ukryte kategorie|kategorie'))
nieskl$level1.name[info] <- 'informacja'

potr <- which(stri_detect_regex(stri_trans_tolower(nieskl$name), 'potrawy'))
nieskl$level1.name[potr] <- 'potrawy według głównych składników'

zon <- which(stri_detect_regex(stri_trans_tolower(nieskl$name), 'żony|imiona'))
nieskl$level1.name[zon] <- 'kobieta'

histsp <- which(stri_detect_regex(stri_trans_tolower(nieskl$name), 'lotnisk|życie|rzeczypospolit|ławeczki|polityka|przedrozbiorowej|orientacje'))
nieskl$level1.name[histsp] <- 'historia społeczna'

mn <- which(stri_detect_regex(stri_trans_tolower(nieskl$name), 'transmisj'))
nieskl$level1.name[mn] <- 'metodologia nauki'

wie <- which(stri_detect_regex(stri_trans_tolower(nieskl$name), 'wiedźm'))
nieskl$level1.name[wie] <- 'fikcja'

nieskl$level1.name %>% setdiff(kategorie$nowa_kat2) -> reszta

nieskl$level1.name[nieskl$level1.name %in% reszta] <- 'klasyfikacja nauk'

nieskl$name[is.na(nieskl$level1.name)]
sum(is.na(nieskl$level1.name))




kategorie %>% left_join(nieskl, by = c('name_new' = 'name')) -> kategorie
kategorie$nowa_kat2 <- ifelse(!is.na(kategorie$level1.name) & kategorie$nowa_kat2 == '', kategorie$level1.name, kategorie$nowa_kat2)

kategorie$name_new[kategorie$nowa_kat2 == 'klasyfikacja nauk'] -> klnk

kategorie$nowa_kat2[kategorie$name_new %in% klnk[c(1,2,4:16, 19:22, 26:31, 33:40, 42:49, 51, 53, 55:57, 59:60, 62:64, 67:70, 72:84, 86:87, 89:93, 95:108, 110, 112:115, 118:125, 127:129,131,132,134:145,147:150,152:158,160:161,163:165, 169,170, 173:181, 184:204,206:216,218:222, 224, 225)]] <- 
  'nauki przyrodnicze'

kategorie %>% names()

kategorie <- kategorie[,c(1,2,6)]

kategorie$nowa_kat2 %>% unique() %>% sort() -> kat_unq
kat_unq <- data.frame(nowa_kat2 = kat_unq, id_new2 = 1:length(kat_unq))
kategorie %>% left_join(kat_unq) -> kategorie

save(list = 'kategorie', file = "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/categories/kategorie20151119_ost.rda")
load("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/categories/kategorie20151119_ost.rda")

kategorie %>% group_by(nowa_kat2) %>% count(nowa_kat2) -> aa

nowe_kat <- c("lotnictwo", 
              "bron", 
              "historia", 
              "kosciol", 
              "archipelagi", 
              "architektura swiata", 
              "architektura pl", 
              "geografia pl", 
              "geografia swiata",
              "armia", 
              "gory", 
              "dzielnice", 
              "cmentarze", 
              "jedn. teryt.", 
              "oświata", 
              "gminy", 
              "hrabstwa", 
              "jeziora", 
              "kolej", 
              "miasta", 
              "miejscowosci", 
              "dystrykt",
              "departament", 
              "obiekty sportowe", 
              "przelecze", 
              "religia", 
              "rzeki", 
              "sport", 
              "szczyty", 
              "transport", 
              "ulice i place", 
              "wody", 
              "wsie", 
              "zabytki", 
              "zwierzeta") 

#lotnictwo
kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(1, 9, 73, 98, 259, 270, 271, 730, 731, 1217, 1358,1360, 1374,1380, 1423:1424, 1522, 1718, 1719)] -> kk1

#bron
kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(3,4,5,93,94, 268, 1215, 1421, 1422)] -> kk2


#historia
kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(2, 86:91, 669:690, 700, 818:821,826, 1285, 1388,1555, 1735)] -> kk3

#kosciol
kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(10, 11,101, 144, 145, 804:817, 1231:1233, 1304:1310,1589:1591)] -> kk4

#archipelagi
kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(12:14, 68, 69, 82, 83, 1838:1854)] -> kk5


#architektura swiata
kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(16,18,19,22,25:29, 31:35, 38, 41:45, 47, 50)] -> kk6

#architektura polski
kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(15, 17, 20, 21, 23, 24, 30, 36, 37, 39, 40, 46, 48, 49, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65,99)] -> kk7

#geografia pl
kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(293, 307, 308, 320, 321, 322,1325,1328)] -> kk8


#geografia swiata
kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(72,277:292, 294:306, 309:319,323,1375,1417,1831)] -> kk9


#armia
kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(6,7,66,67, 71, 78, 79,96,97,102,151,231,267,269,272,273,666,796,1216,1284,1296,1318:1320,1346,1362:1364,1367,1372,1373,1416,1452,1529,1554,1632,1639,1717,1736:1747)] -> kk10

#gory
kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(81, 146:149,266,651:660,667,703,704,1218:1221,1276,1314:1317,1321,1329,1341:1345, 1350:1355,1450,1451,1453,1526,1530,1634,1637,1669,1670,1701,1881:1883)] -> kk11

#dzielnice
kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(84,95,232:256,275,1289,1391,1392,1418,1557,1558,1714,1748)] -> kk12

#cmentarze
kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(107:123,1326)] -> kk13

#jedn. teryt.
kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(128:143,705,706,1329:1340, 1635,1636,1734)] -> kk14

#oswiata
kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(257,1213,1290,1291,1676,1677,1697)] -> kk15

#gminy
kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(326:648,831,834,835,846,847,1102,1103,1110:1201, 1556, 1586, 1588,1863,1880)] -> kk16

#hrabstwa
kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(693:699,880:915,1757:1798)] -> kk17

#jeziora
kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(707:725,1347,1348)] -> kk18

#kolej
kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(836:842,1560:1578,1640:1645)] -> kk19

#miasta
kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(74,260,264,265,274,276,325,649,650,661,668,701,728,855:879,915:978,994:1000,
                 70,77,80,100,127,150,324,795,797,798,824,844,845,849,851,853,1208,1224,1226,1286,1287,1313,1389,1390,1394,1411,1419,1420,1447,1524,1525,1533,1538,1581,1583,1587,1633,1638,1668,1675,1703:1706,1708,1716,1749,1873,1884)] -> kk20

#miejscowosci
kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(1001:1007,1101,1104:1109,1202:1204,1871,734:791)] -> kk21

#dystrykt
kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(153:230,979:993,1754:1756)] -> kk22

#departament
kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(1008:1100)] -> kk23

#obiekty sportowe
kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(1234:1275)] -> kk24

#przelecze
kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(1397:1410)] -> kk25

#religia
kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(726,727,854,1393,1430:1446,1585,1589:1591)] -> kk26

#rzeki
kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(75,76,261,1454:1521)] -> kk27

#sport
kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(799,1206,1539:1553,1302,1303)] -> kk28

#szczyty
kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(124,125,663:665,1368:1371,1594:1626,1855:1862)] -> kk29

#transport
kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(801, 1646:1663)] -> kk30

#ulice i place
kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(691,692,794,1209,1679:1696,1698:1700,1712,1713)] -> kk31

#wody
kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(105,106,729,1227,1381:1384,1425,1528,1537,1720:1733, 1877:1879)] -> kk32

#wsie
kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(1223,1707,1750:1753,1799:1830)] -> kk33

#zabytki
kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(92,152, 833,1210:1212,1277,1294,1295,1376:1379,1532,1582,1864:1869,1875,1876,1885)] -> kk34

#zwierzeta
kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(103,104,832,1222,1225,1278:1281,1292,1293,1311,1312,1327,1414,1415,1559,1833:1837,1886:1890)] -> kk35


#
# kategorie$name_new[
#   kategorie$nowa_kat2 == 
#     "kategorie według położenia geograficznego"] %>% 
#   sort() %>% .[] -> kk


kategorie$nowa_kat2[kategorie$name_new %in% kk1] <- nowe_kat[1]
kategorie$nowa_kat2[kategorie$name_new %in% kk2] <- nowe_kat[2]
kategorie$nowa_kat2[kategorie$name_new %in% kk3] <- nowe_kat[3]
kategorie$nowa_kat2[kategorie$name_new %in% kk4] <- nowe_kat[4]
kategorie$nowa_kat2[kategorie$name_new %in% kk5] <- nowe_kat[5]
kategorie$nowa_kat2[kategorie$name_new %in% kk6] <- nowe_kat[6]
kategorie$nowa_kat2[kategorie$name_new %in% kk7] <- nowe_kat[7]
kategorie$nowa_kat2[kategorie$name_new %in% kk8] <- nowe_kat[8]
kategorie$nowa_kat2[kategorie$name_new %in% kk9] <- nowe_kat[9]
kategorie$nowa_kat2[kategorie$name_new %in% kk10] <- nowe_kat[10]
kategorie$nowa_kat2[kategorie$name_new %in% kk11] <- nowe_kat[11]
kategorie$nowa_kat2[kategorie$name_new %in% kk12] <- nowe_kat[12]
kategorie$nowa_kat2[kategorie$name_new %in% kk13] <- nowe_kat[13]
kategorie$nowa_kat2[kategorie$name_new %in% kk14] <- nowe_kat[14]
kategorie$nowa_kat2[kategorie$name_new %in% kk15] <- nowe_kat[15]
kategorie$nowa_kat2[kategorie$name_new %in% kk16] <- nowe_kat[16]
kategorie$nowa_kat2[kategorie$name_new %in% kk17] <- nowe_kat[17]
kategorie$nowa_kat2[kategorie$name_new %in% kk18] <- nowe_kat[18]
kategorie$nowa_kat2[kategorie$name_new %in% kk19] <- nowe_kat[19]
kategorie$nowa_kat2[kategorie$name_new %in% kk20] <- nowe_kat[20]
kategorie$nowa_kat2[kategorie$name_new %in% kk21] <- nowe_kat[21]
kategorie$nowa_kat2[kategorie$name_new %in% kk22] <- nowe_kat[22]
kategorie$nowa_kat2[kategorie$name_new %in% kk23] <- nowe_kat[23]
kategorie$nowa_kat2[kategorie$name_new %in% kk24] <- nowe_kat[24]
kategorie$nowa_kat2[kategorie$name_new %in% kk25] <- nowe_kat[25]
kategorie$nowa_kat2[kategorie$name_new %in% kk26] <- nowe_kat[26]
kategorie$nowa_kat2[kategorie$name_new %in% kk27] <- nowe_kat[27]
kategorie$nowa_kat2[kategorie$name_new %in% kk28] <- nowe_kat[28]
kategorie$nowa_kat2[kategorie$name_new %in% kk29] <- nowe_kat[29]
kategorie$nowa_kat2[kategorie$name_new %in% kk30] <- nowe_kat[30]
kategorie$nowa_kat2[kategorie$name_new %in% kk31] <- nowe_kat[31]
kategorie$nowa_kat2[kategorie$name_new %in% kk32] <- nowe_kat[32]
kategorie$nowa_kat2[kategorie$name_new %in% kk33] <- nowe_kat[33]
kategorie$nowa_kat2[kategorie$name_new %in% kk34] <- nowe_kat[34]
kategorie$nowa_kat2[kategorie$name_new %in% kk35] <- nowe_kat[35]

save(list = 'kategorie', file = "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/categories/kategorie20151123.rda")
load("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/categories/kategorie20151123.rda")

kategorie %>% group_by(nowa_kat2) %>% count(nowa_kat2) -> aa

kategorie$nowa_kat2[kategorie$nowa_kat2 %in% c(
  "członkowie towarzystw naukowych", 
  "działalność naukowa",
  "ludzie związani z oświatą",
  "naukowcy",
  "popularyzacja nauki",
  "szkolnictwo wyższe",
  "organizacje naukowe"
  )] <- "oświata"


kategorie$nowa_kat2[kategorie$nowa_kat2 %in% c(
  "przestępcy",
  "palenie tytoniu",
  "ofiary przestępstw"
)] <- "problemy społeczne"

kategorie$nowa_kat2[kategorie$nowa_kat2 %in% c(
  "społeczeństwo według państw",
  "ruchy społeczne",
  "zbiorowości społeczne"
)] <- "społeczeństwo"

kategorie$nowa_kat2[kategorie$nowa_kat2 %in% c(
  "biografie według daty urodzin"                
  ,"biografie według epok i okresów historycznych"
  ,"biografie według miast"                       
  ,"biografie według narodowości"                 
  ,"biografie według osiągnięć i zasług"          
  ,"biografie według państw"                      
  ,"biografie według profesji"                    
  ,"biografie według regionów"                    
  ,"biografie według religii i wyznań"
  ,"biografie według daty śmierci"
)] <- "biografie"

kategorie$nowa_kat2[kategorie$nowa_kat2 %in% c(
  "instytucje kultury",
  "kulturoznawstwo",
  "obiekty kultury",
  "obiekty z listy dziedzictwa unesco",
  "wystawiennictwo",
  "kultura według kontynentów",
  "kultura według państw" 
)] <- "kultura"

kategorie$nowa_kat2[kategorie$nowa_kat2 %in% c(
  "mleko",
  "wino",
  "ziemniak",
  "potrawy według głównych składników"
)] <- "jedzenie"

kategorie$nowa_kat2[kategorie$nowa_kat2 %in% c(
 "religie"
)] <- "religia"

# kategorie$nowa_kat2[kategorie$nowa_kat2 %in% c(
#   "kultura starożytnego rzymu"     
# )] <- "historia"

kategorie %>% group_by(nowa_kat2) %>% count(nowa_kat2) -> aa
aa[aa$n <= 5,]
aa$nowa_kat2[aa$n > 5]


kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(91,92,97)] -> kk1

kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(1,4,7,30:32,49,54,55)] -> kk2


kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(2,25)] -> kk3


kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(3,27,50,64,69,72)] -> kk4

kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(5,6,19:22,41,43,81:87,89)] -> kk5

kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(9,10,14:18,56:61,75:77,80)] -> kk6

kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(8,11:13,23,24,26,28,29,33:40,44,45,47,48,51,52,53,62,63,66:68,73,79,88,90,93,96,96)] -> kk7


kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[42] -> kk8

kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[46] -> kk9


kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[65] -> kk10

kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(70,94)] -> kk11


kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[71] -> kk12

kategorie$name_new[
  kategorie$nowa_kat2 == 
    "kategorie według położenia geograficznego"] %>% 
  sort() %>% .[c(74,78)] -> kk13





kategorie$nowa_kat2[kategorie$name_new %in% kk1] <- "problemy społeczne"
kategorie$nowa_kat2[kategorie$name_new %in% kk2] <- "gospodarka"
kategorie$nowa_kat2[kategorie$name_new %in% kk3] <- "biografie"
kategorie$nowa_kat2[kategorie$name_new %in% kk4] <- "społeczeństwo"
kategorie$nowa_kat2[kategorie$name_new %in% kk5] <- "kultura"
kategorie$nowa_kat2[kategorie$name_new %in% kk6] <- "geografia swiata"
kategorie$nowa_kat2[kategorie$name_new %in% kk7] <- "geografia społeczno-ekonomiczna"
kategorie$nowa_kat2[kategorie$name_new %in% kk8] <- "gory"
kategorie$nowa_kat2[kategorie$name_new %in% kk9] <- "polityka"
kategorie$nowa_kat2[kategorie$name_new %in% kk10] <- "jedzenie"
kategorie$nowa_kat2[kategorie$name_new %in% kk11] <- "media"
kategorie$nowa_kat2[kategorie$name_new %in% kk12] <- "zabytki"
kategorie$nowa_kat2[kategorie$name_new %in% kk13] <- "kategorie według specjalności lekarskich"
kategorie$nowa_kat2[69] <- "geografia swiata"

kategorie %>% group_by(nowa_kat2) %>% count(nowa_kat2) -> aa
aa[aa$n <= 5,]
aa$nowa_kat2[aa$n > 5]

kategorie <- kategorie %>% select(-id_new2)
kategorie$nowa_kat2 %>% unique() %>% sort() -> kat_unq
kat_unq <- data.frame(nowa_kat2 = kat_unq, id_new2 = 1:length(kat_unq))
kategorie %>% left_join(kat_unq) -> kategorie

save(list = 'kategorie', file = "/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/categories/kategorie20151123_ost.rda")
load("/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/categories/kategorie20151123_ost.rda")

  