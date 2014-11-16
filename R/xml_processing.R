#install.packages('XML')

library(XML)
library(stringi)

xmlfile <- xmlParse("./Data//plwiki-20141102-pages-articles1-1000linesCW.xml")




#### from Rpkg project ####
prepare_string_or_NULL <- function(str) {
  str <- as.character(str)
  which_na <- is.na(str)
  ret <- character(length(str))
  ret[which_na] <- "NULL"
  ret[!which_na] <- stri_paste("'", str[!which_na], "'")
  ret
}
##########################

conn <- dbConnect(SQLite(), dbname = "./Data/DataBase/wiki_raw.sqlite")


xml_list <- xmlToList(xmlfile)
###################
for(i in index){
  dbSendQuery(conn, sprintf(
    "INSERT INTO wiki_raw (title, text, redirect)
    VALUES (%s)
    ", stri_flatten(
    c(prepare_string_or_NULL( xml_list[[i]][["title"]]), 
    prepare_string_or_NULL( xml_list[[i]][["revision"]][["text"]][["text"]]), 
    prepare_string_or_NULL( xml_list[[i]][["redirect"]]))
        , collapse=",")
                          )
              )
  
  
}












############# SMIECI ############

# df <- xmlToDataFrame(xmlfile)
# lista <- xmlToList(xmlfile)
# length(lista)
# ldply(lista, )
# 
# 
# nodes  <-  getNodeSet(doc, "//data/item")
# df2 <- xmlToDataFrame(nodes = xmlChildren(xmlRoot(xmlfile)[["page"]]))
# xmlChildren(xmlRoot(xmlfile)[["page"]])
# 
# help(package = "plyr")
# 
# names.XMLNode(xmlRoot(xmlfile))
# xmlSize(xmlRoot(xmlfile))
# 
# 
# xmltop <- xmlRoot(xmlfile)
# xmltop[[2]]
# pagenodes <- xmlSApply(xmltop[[2]][[4]], xmlName) #name(s)
# xmlChildren(xmltop)[['wikimedia']]
# 
# 
# df2 <- xmlToDataFrame(xmlfile, nodes=list(c("page", pagenodes)))
# getNodeSet(xmlfile, "./Data//plwiki-20141102-pages-articles1-1000linesCW.xml")
# 
# #########################
# data <- xmlParse("http://forecast.weather.gov/MapClick.php?lat=29.803&lon=-82.411&FcstType=digitalDWML")
# xmlfile <- xmlParse("./Data//plwiki-20141102-pages-articles1-1000linesCW.xml")
# 
# 
# 
# xml_data <- xmlToList(data)
# 
# 
# 
# xmlRoot(xmlfile)
# 
# location <- as.list(xml_data[["data"]][["location"]][["point"]])
# text <- as.list(xml_list[["page"]][["revision"]][["text"]])
# 
# text <- unlist(xml_list[["page"]][["revision"]][
#   names(xml_list[["page"]][["revision"]]) == "text"])
# 
# 
# names(xml_list[[8]])
# 
# start_time <- unlist(xml_data[["data"]][["time-layout"]][
#   names(xml_data[["data"]][["time-layout"]]) == "start-valid-time"])
# temps <- xml_data[["data"]][["parameters"]]
# temps <- temps[names(temps) == "temperature"]
# temps <- temps[sapply(temps, function(x) any(unlist(x) == "hourly"))]
# temps <- unlist(temps[[1]][sapply(temps, names) == "value"])
# 
# out <- data.frame(
#   as.list(location),
#   "start_valid_time" = start_time,
#   "hourly_temperature" = temps)
# 
# 
# ldply(xml_list[names(xml_list) == "page"], data.frame)
# ldply(xml_list[names(xml_list) == "page"][1:6], data.frame)
# 
# index <- which(names(xml_list) == "page")
# 
# xml_list[[8]][["redirect"]]

##############################


