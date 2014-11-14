
#download.file("http://pl.wikipedia.org/wiki/Kategoria:Matematyka", 
 #             "./Data/KatMat.html")

download.file("http://pl.wikipedia.org/wiki/Wikipedia:Skarbnica_Wikipedii/Przegl%C4%85d_zagadnie%C5%84_z_zakresu_matematyki", 
              "./Data/SkarbnicaWiedzy.html")

library('stringi')

text <- stri_flatten(readLines("./Data/SkarbnicaWiedzy.html"))
links <- unique(stri_match_all_regex(text, 'href=\\"/wiki/([^\\:]+?)\\"')[[1]][,2])
#links1 <- stri_extract_all_regex(text, 'href=\\"/wiki/(.)+?\\"')[[1]]

for(i in 1:n){
  filename <- stri_paste("./Data/", links[i], ".html")
  download.file(stri_paste("http://pl.wikipedia.org/wiki/", links[i]), 
                filename)
  newtext <- stri_flatten(readLines(filename))
  newlinks <- unique(stri_match_all_regex(newtext, 'href=\\"/wiki/([^\\:]+?)\\"')[[1]][,2])
  links <- unique(c(links, newlinks))
}
  


