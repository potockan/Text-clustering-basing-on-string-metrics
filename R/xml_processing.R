
#install.packages('XML')
install.packages('plyr')
library(XML)
library(plyr)

xmlfile <- xmlParse("./Data//plwiki-20141102-pages-articles1-1000linesCW.xml")


df <- xmlToDataFrame(xmlfile)
lista <- xmlToList(xmlfile)
length(lista)
ldply(lista, )


nodes  <-  getNodeSet(doc, "//data/item")
df2 <- xmlToDataFrame(nodes = xmlChildren(xmlRoot(xmlfile)[["page"]]))
xmlChildren(xmlRoot(xmlfile)[["page"]])

help(package = "plyr")

names.XMLNode(xmlRoot(xmlfile))
xmlSize(xmlRoot(xmlfile))


xmltop <- xmlRoot(xmlfile)
xmltop[[2]]
pagenodes <- xmlSApply(xmltop[[2]][[4]], xmlName) #name(s)
xmlChildren(xmltop)[['wikimedia']]


df2 <- xmlToDataFrame(xmlfile, nodes=list(c("page", pagenodes)))
getNodeSet(xmlfile, "./Data//plwiki-20141102-pages-articles1-1000linesCW.xml")


data <- xmlParse("http://forecast.weather.gov/MapClick.php?lat=29.803&lon=-82.411&FcstType=digitalDWML")
xmlToDataFrame(nodes=getNodeSet(data1,"//data"))[c("location","time-layout")]
step1 <- xmlToDataFrame(nodes=getNodeSet(data1,"//location/point"))[c("latitude","longitude")]
step2 <- xmlToDataFrame(nodes=getNodeSet(data1,"//time-layout/start-valid-time"))
step3 <- xmlToDataFrame(nodes=getNodeSet(data1,"//parameters/temperature"))[c("type="hourly"")]


