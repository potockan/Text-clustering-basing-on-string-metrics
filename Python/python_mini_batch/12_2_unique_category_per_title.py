# -*- coding: utf-8 -*-
"""
Created on Thu Jul 30 18:43:50 2015

@author: natalia
"""

import sqlite3
con = sqlite3.connect("/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")

c = con.cursor()

# Create table
c.execute('''drop table if exists wiki_unique_category''')

# Insert a row of data
c.execute('''create table if not exists wiki_unique_category (
             id_title INTEGER NOT NULL,
             id_category INTEGER NOT NULL,
             cnt INTEGER NOT NULL,
             FOREIGN KEY (id_category) REFERENCES wiki_category_name(id),
             FOREIGN KEY (id_title) REFERENCES wiki_page(id)
 )''')

print('Insert...')
c.execute('''insert into wiki_unique_category(id_title, id_category, cnt)
             
             select 
             a.id_title, 
             a.id_category, 
             max(b.cnt) cnt 
             from wiki_category_text a
            join
              (
              select 
              count(id_title) as cnt, 
              id_category 
              from wiki_category_text 
              group by 
              id_category
              ) b
            on 
            a.id_category = b.id_category
            group by 
            a.id_title
             ''')
             
print('Commit...')
# Save (commit) the changes
con.commit()

# We can also close the connection if we are done with it.
# Just be sure any changes have been committed or they will be lost.
con.close()
