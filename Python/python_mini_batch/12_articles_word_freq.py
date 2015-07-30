# -*- coding: utf-8 -*-
"""
Created on Thu Jul 30 13:41:04 2015

@author: natalia
"""                      
                          
                        
import sqlite3
con = sqlite3.connect("/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")

c = con.cursor()

# Create table
c.execute('''drop table if exists wiki_word_clust_freq''')

# Insert a row of data
c.execute('''create table if not exists wiki_word_clust_freq (
             id_title INTEGER NOT NULL,
             id_stem_word INTEGER NOT NULL,
             freq INTEGER NOT NULL,
             FOREIGN KEY (id_title) REFERENCES wiki_page(id),
             FOREIGN KEY (id_stem_word) REFERENCES wiki_word(id)
 )''')

c.execute('''insert into wiki_word_clust_freq(id_title, id_stem_word, freq)
             
             select 
             a.id_title, b.id_stem_word, sum(a.freq) as freq
             from 
             wiki_word_freq a
             
             join
             
             wiki_hunspell_clust b
             on
             a.id_word = b.id_word
             group by 
             a.id_title
             ,b.id_stem_word
             ''')

# Save (commit) the changes
con.commit()

# We can also close the connection if we are done with it.
# Just be sure any changes have been committed or they will be lost.
con.close()

