#!/usr/bin/Rscript --vanilla

#install.packages("RSQLite")
library(RSQLite)


### Worked text database ###

con <- dbConnect(SQLite(), dbname = "./Data/DataBase/wiki.sqlite")

dbSendQuery(con, "CREATE TABLE IF NOT EXISTS wiki_page (
  id INTEGER NOT NULL PRIMARY KEY,
  title VARCHAR(256) NOT NULL UNIQUE
);")

dbSendQuery(con, "CREATE TABLE IF NOT EXISTS wiki_category_name (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR(256) UNIQUE
);")

dbSendQuery(con, "CREATE TABLE IF NOT EXISTS wiki_category_text (
  id INTEGER NOT NULL PRIMARY KEY,
  id_title INTEGER NOT NULL,
  id_category INTEGER NOT NULL,
  FOREIGN KEY (id_title) REFERENCES wiki_page(id),
  FOREIGN KEY (id_category) REFERENCES wiki_category(id)
);")

dbSendQuery(con, "CREATE TABLE IF NOT EXISTS wiki_link (
  id INTEGER NOT NULL PRIMARY KEY,
  id_title_from INTEGER NOT NULL,
  id_title_to INTEGER NOT NULL,
  FOREIGN KEY (id_title_from) REFERENCES wiki_page(id)
);")



dbSendQuery(con, "CREATE TABLE IF NOT EXISTS wiki_redirect (
  id INTEGER NOT NULL PRIMARY KEY,
  id_from INTEGER NOT NULL,
  id_to INTEGER NOT NULL
);")


dbSendQuery(con, "CREATE TABLE IF NOT EXISTS wiki_tag (
  id INTEGER NOT NULL PRIMARY KEY,
  id_title INTEGER NOT NULL,
  text TEXT NOT NULL,
  FOREIGN KEY (id_title) REFERENCES wiki_page(id)
);")

dbSendQuery(con, "CREATE TABLE IF NOT EXISTS wiki_curly (
  id INTEGER NOT NULL PRIMARY KEY,
  id_title INTEGER NOT NULL,
  text TEXT NOT NULL,
  FOREIGN KEY (id_title) REFERENCES wiki_page(id)
);")

dbSendQuery(con, "CREATE TABLE IF NOT EXISTS wiki_word (
  id INTEGER NOT NULL PRIMARY KEY,
  word VARCHAR(256) NOT NULL,
  UNIQUE(word)
);")

dbSendQuery(con, "CREATE TABLE IF NOT EXISTS wiki_card (
  id_title INTEGER NOT NULL,
  id_word INTEGER NOT NULL,
  FOREIGN KEY (id_title) REFERENCES wiki_page(id),
  FOREIGN KEY (id_word) REFERENCES wiki_word(id)
);")

#dbListTables(con)

dbDisconnect(con)

#############
