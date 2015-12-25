#!/usr/bin/python3

"""
Created on Thu Nov 12 12:29:04 2015

@author: potockan
"""



from sklearn.cluster import MiniBatchKMeans
from sklearn import metrics
#from scipy.sparse import coo_matrix
import scipy.sparse as sps

import logging
from optparse import OptionParser
import sys
import time

import numpy as np
import sqlite3
import os
#import socket, pickle
#import struct



# <codecell>

# Display progress logs on stdout
logging.basicConfig(level=logging.INFO,
                    format='%(asctime)s %(levelname)s %(message)s')

# parse commandline arguments
op = OptionParser()
#op.add_option("--res",
#              dest="results", type=np.ndarray,
#              help="A sparse matrix with cluster centers")
op.add_option("--truek", type=int, dest="true_k", default=0,
              help="Number of clusters")
op.add_option("--i", dest="i", type=int,
              help="A number specyfying the partition")
op.add_option("--typ", type=str, dest="typ", default=0,
              help="Type of the data")
op.add_option("--b", dest="b", type=int,
              help="A number specyfying the batch size")
              
print(__doc__)
op.print_help()

(opts, args) = op.parse_args()
if len(args) > 0:
    op.error("this script takes no arguments.")
    sys.exit(1)


def reading_data(i, typ):
    #c.execute('select * from wiki_stem_word_reorder')
    print("Reading data...")
    
    if typ == "_":
        typ = ""
     
    con = sqlite3.connect("/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/partitions/czesc%d/wiki%s.sqlite" % (i, typ))
    #con = sqlite3.connect("/home/samba/potockan/mgr/czesc%d/wiki%s.sqlite" % (i, typ))
    c = con.cursor()
    
    
    c.execute('''select 
    id_title, id_stem_word, freq 
    from art_word_freq%s
    '''  % (typ))
    #   order by id_title 
    
    data = c.fetchall()
    
    con.close()

        
    return(data)
    

def transforming_data(my_data):
    #labels = np.asarray([val[0] for val in labels])    
    my_sparse_data = sps.csr_matrix(([val[2] for val in my_data], ([val[0] -1 for val in my_data], [val[1] - 1 for val in my_data])))
    my_sparse_data = sps.csr_matrix((my_sparse_data.data, my_sparse_data.indices, my_sparse_data.indptr[np.concatenate(([True], my_sparse_data.indptr[1:] != my_sparse_data.indptr[:-1]))]))
    return(my_sparse_data)


def reading_labels(typ, i, id_title):
    if typ == "_":
        typ = ""
    con = sqlite3.connect("/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")
    c = con.cursor()    
    
    c.execute('''
    select a.id_new_cat from 
    wiki_category_text_after_reduction2 as a
    where a.id in %s
    ''' % str(id_title))
    print("Reading labels...")
    labels = c.fetchall()    
    con.close()
    labels = np.array(labels)
    labels.shape = (labels.shape[0],)
    return labels



i = 1
for typ in [
'_', '_lcs', '_dl', '_jaccard','_qgram',
'_red_lcs','_red_dl','_red_jaccard','_red_qgram',
'_red_lcs_lcs','_red_dl_dl','_red_jaccard_jaccard','_red_qgram_qgram'
]:    
    for d in [2, 15, 100]:
        print(str(d) + "____" + typ + "____") 
        np.random.seed(12321)
        t0 = time.time()
        dane = reading_data(i ,typ)
        print("done in %fs" % (time.time() - t0))
        id_title = list(set([x[0] for x in dane]))
        id_title.sort()
        if d == 2:
            id_title = id_title[0:25000]
        elif d == 100:
            dane = transforming_data(dane)
            for aa in range(3,14):
                print(aa)
                dane2 = reading_data(aa ,typ)
                id_title2 = list(set([x[0] for x in dane2]))
                id_title2.sort()
                id_title = id_title + id_title2
                #dane = sps.vstack([dane,transforming_data(dane2)])
                print(len(id_title))
                del dane2
                del dane
        print("done in %fs" % (time.time() - t0))   
        t0 = time.time()
        labels = reading_labels(typ, i, tuple(id_title))
        print("done in %fs" % (time.time() - t0))
        #print("n_samples: %d, n_features: %d" % dane.shape)
    
        thefile = os.getcwd() + "/labels_%s_%d" % (typ, d)
        np.savetxt(thefile, labels, delimiter = ', ')

