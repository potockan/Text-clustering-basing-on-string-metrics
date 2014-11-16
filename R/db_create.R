#install.packages("RSQLite")
library(RSQLite)

### Raw text database ###

#under Windows: dbConnect("SQLite",...)
conn <- dbConnect(SQLite(), dbname = "./Data/DataBase/wiki_raw.sqlite")

dbSendQuery(conn, "CREATE TABLE IF NOT EXISTS wiki_raw (
  id INTEGER NOT NULL PRIMARY KEY,
  title VARCHAR(256) NOT NULL,
  text TEXT NOT NULL,
  redirect VARCHAR(256) DEFAULT NULL
);")
dbListTables(conn)

dbDisconnect(conn)

###################


### Worked text database ###

con <- dbConnect(SQLite(), dbname = "./Data/DataBase/wiki.sqlite")

dbSendQuery(conn, "CREATE TABLE IF NOT EXISTS wiki_category (
  id SERIAL NOT NULL PRIMARY KEY,
  name VARCHAR(256)
);")

dbSendQuery(conn, "CREATE TABLE IF NOT EXISTS wiki_page (
  id SERIAL NOT NULL PRIMARY KEY,
  title INTEGER NOT NULL,
  text TEXT NOT NULL,
  id_category INTEGER NOT NULL,
  FOREIGN KEY (id_category) REFERENCES wiki_category(id)
);")

dbSendQuery(conn, "CREATE TABLE IF NOT EXISTS wiki_link_text (
  id SERIAL NOT NULL PRIMARY KEY,
  id_title_from INTEGER NOT NULL,
  id_title_to INTEGER NOT NULL,
  id_type INTEGER NOT NULL,
  FOREIGN KEY (id_title_from) REFERENCES wiki_page(id),
  FOREIGN KEY (id_title_to) REFERENCES wiki_page(id),
);")
#id_type - 1 for link in the text, 2 for link in the see also category


dbSendQuery(conn, "CREATE TABLE IF NOT EXISTS wiki_link_external (
  id SERIAL NOT NULL PRIMARY KEY,
  id_title_from INTEGER NOT NULL,
  link_to TEXT NOT NULL,
  FOREIGN KEY (id_title_from) REFERENCES wiki_page(id),
);")

dbSendQuery(conn, "CREATE TABLE IF NOT EXISTS wiki_redirect (
  id SERIAL NOT NULL PRIMARY KEY,
  id_title_from INTEGER NOT NULL,
  id_title_to INTEGER NOT NULL,
  FOREIGN KEY (id_title_from) REFERENCES wiki_page(id),
  FOREIGN KEY (id_title_to) REFERENCES wiki_page(id)
);")

dbListTables(con)

dbDisconnect(con)

#############
