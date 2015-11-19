
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

kategorie %>% group_by(id_new2) %>% count(id_new2) ->aa
