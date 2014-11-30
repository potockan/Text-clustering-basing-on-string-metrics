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



path = '/home/natalia/Text-clustering-basing-on-string-metrics/Data/XML/plwiki-20141102-pages-articles1-1000lines.xml'
#path = '/home/natalia/Text-clustering-basing-on-string-metrics/Data/XML/plwiki-20141102-pages-articles1.xml'
tree = ET.parse(open(path))
root = tree.getroot()


conn = sqlite3.connect('/home/natalia/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki_raw.sqlite')

element = root.getchildren()[0].getchildren()[0]
ch = root.getchildren()
for i in range(len(ch)):
    if ch[i].tag=='{http://www.mediawiki.org/xml/export-0.9/}page':
        redirect = "'NULL'"
        for j in range(len(ch[i].getchildren())):
            ch2 = ch[i].getchildren()[j]
            if ch2.tag == '{http://www.mediawiki.org/xml/export-0.9/}title':
                print(type(ch2.text))
                title = prepare_string_or_NULL(ch2.text)
                print(title)
            elif ch2.tag == '{http://www.mediawiki.org/xml/export-0.9/}redirect':
                redirect = prepare_string_or_NULL(ch2.text)
                print(redirect)
            elif ch2.tag == '{http://www.mediawiki.org/xml/export-0.9/}revision':
                text = prepare_string_or_NULL(ch2.getchildren()[5].text)
                print(text)
        stmt = '''
        INSERT INTO wiki_raw (title, text, redirect)
        VALUES (%s, %s, %s)
        '''
        print(i)
        query = stmt % (title, text, redirect)
        conn.execute(query)
        conn.commit()


