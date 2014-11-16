#install.packages('XML')

library(XML)
library(stringi)
library(RSQLite)


#### from Rpkg project ####
# functions which prepares a text to insert it into DB 
# or if its empty then its NULL
prepare_string_or_NULL <- function(str) {
  str <- as.character(str)
  n <- length(str)
  if(n==0)
    ret <- "NULL"
  else{
    ret <- stri_replace_all_regex(str, "'{1,}", "''")
    ret <- stri_paste("'", ret, "'")
  }
  ret
}
##########################

conn <- dbConnect(SQLite(), dbname = "./Data/DataBase/wiki_raw.sqlite")


#xmlfile <- xmlParse("./Data//XML/plwiki-20141102-pages-articles1-1000linesCW.xml")
xmlfile <- xmlParse("./Data//XML/gawiki-20140223-pages-articles.xml")


xml_list <- xmlToList(xmlfile)
index <- which(names(xml_list) == "page")

###################
#inserting into DB
#for polish 1000 lines it works
#for gawiki:
# Error in is(object, Cl) : 
#   error in evaluating the argument 'statement' in selecting a method for function 'dbSendQuery': Error in xml_list[[i]][["revision"]][["text"]][["text"]] : 
#   subscript out of bounds

for(i in index){
  dbSendQuery(conn, sprintf(
    "INSERT INTO wiki_raw (title, text ,redirect)
    VALUES (%s)
    ", stri_flatten(
    c(prepare_string_or_NULL( xml_list[[i]][["title"]]),
    prepare_string_or_NULL( xml_list[[i]][["revision"]][["text"]][["text"]]), 
    prepare_string_or_NULL(xml_list[[i]][["redirect"]]))
        , collapse=",")
                )
        )
  
  
}



#dbReadTable(conn, "wiki_raw")

dbDisconnect(conn)

#########################









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
# names(xml_list[["page"]][["revision"]][["text"]][["text"]])
#
# index <- which(names(xml_list) == "page")
# 
# xml_list[[8]][["redirect"]]
# 
#
# a <- prepare_string_or_NULL( xml_list[[i]][["revision"]][["text"]][["text"]])
# stri_replace_all_regex("str difv '''nsdk ' mkf ''' msd'' ", "'{1,}", "''")
# 
# stri_extract_all_regex(prepare_string_or_NULL( xml_list[[i]][["revision"]][["text"]][["text"]]), "'''(.+?)'''")
# stri_extract_all_regex( xml_list[[i]][["revision"]][["text"]][["text"]], "'(.+?)'")
# stri_extract_all_regex(a, "''(.+?)'")
# 
# 
# i <- 2

##############################


