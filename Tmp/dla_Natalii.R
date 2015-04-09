library("stringi")
library("rvest")

znajdz_tytuly <- function(link){
  strona <- html(link)
  kategorie <- html_nodes(strona, ".CategoryTreeLabelCategory")
  if(length(kategorie)==0) return(NA)
  linki <- stri_paste("http://pl.wikipedia.org", html_attr(kategorie, "href"))
  tytuly <- html_text(kategorie)
  tytuly
}

znajdz_linki <- function(link){
  strona <- html(link)
  kategorie <- html_nodes(strona, ".CategoryTreeLabelCategory")
  if(length(kategorie)==0) return(NA)
  linki <- stri_paste("http://pl.wikipedia.org", html_attr(kategorie, "href"))
  tytuly <- html_text(kategorie)
  linki
}

wiki <- html("http://pl.wikipedia.org/wiki/Kategoria:Matematyka")

kategorie <- html_nodes(wiki, ".CategoryTreeLabelCategory")
linki <- stri_paste("http://pl.wikipedia.org", html_attr(kategorie, "href"))
tytuly <- html_text(kategorie)

wszystkie_tytuly <- tytuly 
wszystkie_linki <- linki

for(i in 1:length(wszystkie_linki)){
  nowe_linki <- znajdz_linki(wszystkie_linki[i])
  if(!any(is.na(nowe_linki))) wszystkie_linki <- c(wszystkie_linki, nowe_linki)
  nowe_tytuly <- znajdz_tytuly(wszystkie_linki[i])
  if(!any(is.na(nowe_tytuly))) wszystkie_tytuly <- c(wszystkie_tytuly, nowe_tytuly)
}

wszystkie_tytuly











