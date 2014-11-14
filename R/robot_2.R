install.packages('XML')
library(XML)
library(stringi)

download.file("http://dumps.wikimedia.org/plwiki/latest/plwiki-latest-pages-meta-current.xml.bz2", 
                "./Data/wiki.xml.bz2")

# untar("./Data/wiki.xml.bz2", compressed = "bzip2")
# bzfile("./Data//wiki.xml.bz2")
#unziped manually







