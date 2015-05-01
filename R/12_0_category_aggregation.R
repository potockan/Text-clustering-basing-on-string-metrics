

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
# wiki <- html("http://pl.wikipedia.org/wiki/Kategoria:Historia_sztuki")
# wiki <- html("http://pl.wikipedia.org/wiki/Kategoria:Wojny")


kategorie <- html_nodes(wiki, ".CategoryTreeLabelCategory")
linki <- stri_paste("http://pl.wikipedia.org", html_attr(kategorie, "href"))
tytuly <- html_text(kategorie)

wszystkie_tytuly <- tytuly 
wszystkie_linki <- linki

n1 <- 1
n <- length(wszystkie_linki)
while(n1 < n){
  n1 <- n
  for(i in 1:n){
    #nowe_linki 
    if(!any(is.na(nowe_linki <- znajdz_linki(wszystkie_linki[i])))) wszystkie_linki <- unique(c(wszystkie_linki, nowe_linki))
    #nowe_tytuly
    if(!any(is.na(nowe_tytuly <- znajdz_tytuly(wszystkie_linki[i])))) wszystkie_tytuly <- unique(c(wszystkie_tytuly, nowe_tytuly))
  }
  n <- length(wszystkie_linki)
}
wszystkie_tytuly
saveRDS(wszystkie_tytuly, "./wszystkietyt.rds")
# saveRDS(wszystkie_tytuly, "./wszystkietyt2.rds")
# saveRDS(wszystkie_tytuly, "./wszystkietyt3.rds")







