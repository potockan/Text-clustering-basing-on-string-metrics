# -*- coding: utf-8 -*-
"""
Created on Sat Nov 29 14:22:42 2014

@author: natalia
"""

## to do: 
# 1. prepare title, text and redirect for inserting into db
# 2. insert it into db

import xml.etree.ElementTree as ET #element tree for parsing XML
import re #regular expressions
import sqlite3 #sqlite


def prepare_string_or_NULL(str):
    ret = re.sub("'{1,}", "''", str)
    ret = "'" + ret + "'"
    return ret




#path = '/home/natalia/Text-clustering-basing-on-string-metrics/Data/XML/plwiki-20141102-pages-articles1-1000lines.xml'
path = '/home/natalia/Text-clustering-basing-on-string-metrics/Data/XML/plwiki-20141102-pages-articles1.xml'
tree = ET.parse(open(path))
root = tree.getroot()


conn = sqlite3.connect('/home/natalia/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki_raw.sqlite')

i = 0
for event, elem in ET.iterparse(path):
    redirect = "'NULL'"
    if elem.tag=='{http://www.mediawiki.org/xml/export-0.9/}title':
        title = prepare_string_or_NULL(elem.text)
        print(title)
        i = i+1
    elif elem.tag=='{http://www.mediawiki.org/xml/export-0.9/}redirect':
        redirect = prepare_string_or_NULL(elem.text)
        i = i+1
    elif elem.tag=='{http://www.mediawiki.org/xml/export-0.9/}text':
        text = prepare_string_or_NULL(elem.text)
        i = i+1
    elem.clear()
    if i>= 2:
        stmt = '''
        INSERT INTO wiki_raw (title, text, redirect)
        VALUES (%s, %s, %s)
        '''
        query = stmt % (title, text, redirect)
        conn.execute(query)
        conn.commit()
        i = 0
            
     

