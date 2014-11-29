# -*- coding: utf-8 -*-
"""
Created on Sat Nov 29 14:22:42 2014

@author: natalia
"""

import xml.etree.ElementTree as ET #element tree for parsing XML
import re #regular expressions
import sqlite3 #sqlite
 
conn = sqlite3.connect('../Data/DataBase/wiki_raw.sqlite')


def prepare_string_or_NULL(str):
  n = len(str)
  if n==0:
    ret = "NULL"
  else:
    ret = re.sub("'{1,}", "''", str)
    ret = "'" + ret + "'"
  return ret



path = '../Data/XML/plwiki-20141102-pages-articles1-1000linesCW.xml'
tree = ET.parse(open(path))
root = tree.getroot()




element = root.getchildren()[0].getchildren()[0]
ch = root.getchildren()
for i in range(len(ch)):
    if ch[i].tag=='{http://www.mediawiki.org/xml/export-0.9/}page':
        for j in range(len(ch[i].getchildren())):
            ch2 = ch[i].getchildren()[j]
            if ch2.tag == '{http://www.mediawiki.org/xml/export-0.9/}title':
                title = ch2.text
                print(title)
            elif ch2.tag == '{http://www.mediawiki.org/xml/export-0.9/}redirect':
                redirect = ch2.text
                print(redirect)
            elif ch2.tag == '{http://www.mediawiki.org/xml/export-0.9/}revision':
                text = ch2.getchildren()[5].text
                print(text)
        



stmt = "INSERT INTO test VALUES(?, ?, ?, ?)"
con.executemany(stmt, data)
con.commit()


