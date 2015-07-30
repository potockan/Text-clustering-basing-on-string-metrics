# -*- coding: utf-8 -*-
"""
Created on Thu Jul 30 13:41:04 2015

@author: natalia
"""                      
                          
                        
import sqlite3
con = sqlite3.connect("/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")

c = con.cursor()

# Create table
c.execute('''drop table if exists wiki_stem_word_reorder''')

# Insert a row of data
c.execute('''create table if not exists wiki_stem_word_reorder (
             id INTEGER PRIMARY KEY AUTOINCREMENT,
             id_stem_word INTEGER NOT NULL,
             FOREIGN KEY (id_stem_word) REFERENCES wiki_word(id)
 )''')

print('Insert...')
c.execute('''insert into wiki_stem_word_reorder(id_stem_word)
             
             select distinct id_stem_word
             from wiki_hunspell_clust
             order by id_stem_word
             ''')
             
print('Commit...')
# Save (commit) the changes
con.commit()

# We can also close the connection if we are done with it.
# Just be sure any changes have been committed or they will be lost.
con.close()

