
install.packages('rvest')
library(rvest)
gazeta <- html("http://pl.wikipedia.org/wiki/Kategoria:Matematyka")
cast <- html_nodes(gazeta, ".CategoryTreeLabelCategory")
tyt <- html_text(cast)
calosc <- character(0)


sesja <- html_session("http://pl.wikipedia.org/wiki/Kategoria:Matematyka")
tyt <- html_text(html_nodes(sesja, ".CategoryTreeLabelCategory"))


while(length(tyt) > 0)
  sesja <- sesja %>% follow_link(tyt[2])
  current_tyt <- html_text(html_nodes(sesja, ".CategoryTreeLabelCategory"))
  if(length(current_tyt) == 0){
    sesja <- sesja %>% back()
    calosc <- c(calosc, tyt[1])
    tyt <- tyt[-1]
    current_tyt <- tyt
  }  
}



# i <- 1
# while(length(tyt2)>0){
#   ses1 <- sesja %>% follow_link(tyt2[i])
#   tyt2 <- html_text(html_nodes(ses1, ".CategoryTreeLabelCategory"))  
#   
# }
# 
# cat_extract <- function(sesja, tyt, calosc){
#   n <- length(tyt)
#   if(n == 0){  
#     sesja <- sesja %>% back(sesja)
#     return calosc
#   }else{
#     for(i in 1:n){
#       sesja <- sesja %>% follow_link(tyt[i])
#       tyt <- html_text(html_nodes(sesja, ".CategoryTreeLabelCategory"))
#       calosc <- calosc(tyt)
#       tyt <- tyt[-1]
#       calosc <- c(calosc, cat_extract(sesja, tyt, calosc))
#     }
#   }
# }
