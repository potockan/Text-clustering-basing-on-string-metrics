#!/usr/bin/Rscript --vanilla

#install.packages("RSQLite")
library(RSQLite)

source("./R/db_exec.R")
### Worked text database ###

con <- dbConnect(SQLite(), dbname = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")

dbExecQuery(con, "CREATE TABLE IF NOT EXISTS wiki_page (
  id INTEGER NOT NULL PRIMARY KEY,
  title VARCHAR(256) NOT NULL
);")

dbExecQuery(con, "CREATE TABLE IF NOT EXISTS wiki_category_name (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR(256) UNIQUE
);")

dbExecQuery(con, "CREATE TABLE IF NOT EXISTS wiki_category_text (
  id INTEGER NOT NULL PRIMARY KEY,
  id_title INTEGER NOT NULL,
  id_category INTEGER NOT NULL,
  FOREIGN KEY (id_title) REFERENCES wiki_page(id),
  FOREIGN KEY (id_category) REFERENCES wiki_category(id)
);")

dbExecQuery(con, "CREATE TABLE IF NOT EXISTS wiki_link (
  id INTEGER NOT NULL PRIMARY KEY,
  id_from INTEGER NOT NULL,
  id_to INTEGER NOT NULL,
  FOREIGN KEY (id_from) REFERENCES wiki_page(id)
);")



dbExecQuery(con, "CREATE TABLE IF NOT EXISTS wiki_redirect (
  id INTEGER NOT NULL PRIMARY KEY,
  id_from INTEGER NOT NULL,
  id_to INTEGER NOT NULL
);")

# 
# dbExecQuery(con, "CREATE TABLE IF NOT EXISTS wiki_tag (
#   id INTEGER NOT NULL PRIMARY KEY,
#   id_title INTEGER NOT NULL,
#   text TEXT NOT NULL,
#   FOREIGN KEY (id_title) REFERENCES wiki_page(id)
# );")
# 
# dbExecQuery(con, "CREATE TABLE IF NOT EXISTS wiki_curly (
#   id INTEGER NOT NULL PRIMARY KEY,
#   id_title INTEGER NOT NULL,
#   text TEXT NOT NULL,
#   FOREIGN KEY (id_title) REFERENCES wiki_page(id)
# );")

dbExecQuery(con, "CREATE TABLE IF NOT EXISTS wiki_word (
  id INTEGER NOT NULL PRIMARY KEY,
  word VARCHAR(256) NOT NULL UNIQUE
);")

dbExecQuery(con, "CREATE TABLE IF NOT EXISTS wiki_word_freq (
  id_title INTEGER NOT NULL,
  id_word INTEGER NOT NULL,
  freq INTEGER NOT NULL,
  FOREIGN KEY (id_title) REFERENCES wiki_page(id),
  FOREIGN KEY (id_word) REFERENCES wiki_word(id)
);")

#dbListTables(con)

dbDisconnect(con)

#############
