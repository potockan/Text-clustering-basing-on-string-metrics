
#download.file("http://pl.wikipedia.org/wiki/Kategoria:Matematyka", 
 #             "./Data/KatMat.html")

#downloading SkarbnicaWiedzy page
download.file("http://pl.wikipedia.org/wiki/Wikipedia:Skarbnica_Wikipedii/Przegl%C4%85d_zagadnie%C5%84_z_zakresu_matematyki", 
              "./Data/SkarbnicaWiedzy.html")


library('stringi')

#extracting all the links that we want to download that is just the articles
text <- stri_flatten(readLines("./Data/SkarbnicaWiedzy.html"))
links <- unique(stri_match_all_regex(text, 'href=\\"/wiki/([^\\:]+?)\\"')[[1]][,2])
#links1 <- stri_extract_all_regex(text, 'href=\\"/wiki/(.)+?\\"')[[1]]
n <- lenght(links)
#2293

#downloading the articles and extracting links that are connected to them
for(i in 1:n){
  filename <- stri_paste("./Data/", links[i], ".html")
  download.file(stri_paste("http://pl.wikipedia.org/wiki/", links[i]), 
                filename)
  newtext <- stri_flatten(readLines(filename))
  newlinks <- unique(stri_match_all_regex(newtext, 'href=\\"/wiki/([^\\:]+?)\\"')[[1]][,2])
  links <- unique(c(links, newlinks))
}
  

#the same as above for extracted links
n1 <- length(links)
#15201
for(i in (n+1):n1){
  filename <- stri_paste("./Data/", links[i], ".html")
  download.file(stri_paste("http://pl.wikipedia.org/wiki/", links[i]), 
                filename)
  newtext <- stri_flatten(readLines(filename))
  newlinks <- unique(stri_match_all_regex(newtext, 'href=\\"/wiki/([^\\:]+?)\\"')[[1]][,2])
  links <- unique(c(links, newlinks))
}

