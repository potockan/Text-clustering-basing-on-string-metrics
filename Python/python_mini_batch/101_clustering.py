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
import math
from evaluate import fm_index
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


def wagi(typ, ss):

    if typ == "_":
            typ = ""    
    
    con = sqlite3.connect( "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")
    #con = sqlite3.connect("/home/samba/potockan/mgr/czesc%d/wiki%s.sqlite" % (i, typ))
    c = con.cursor()
    
    
    c.execute('''select id_stem_word, %s(freq) as freq_w 
                 from wiki_word_clust3%s_freq 
                 group by id_stem_word
    '''  % (ss, typ))
    #   order by id_title 
    
    data1 = c.fetchall()

    con.close()
    
    data1 = [list(x) for x in data1]
        
    
    return(data1)

def reading_data(i, typ, wagi):
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
    
    data = [list(x) for x in data]
    
    t0 = time.time()
    
    data = [[val1[0], val1[1], val1[2] / wagi[val1[1]-1][1]] for val1 in data]
    print("done in %fs" % (time.time() - t0))  
        
    return(data)
    

def transforming_data(my_data):
    #labels = np.asarray([val[0] for val in labels])    
    my_sparse_data = sps.csr_matrix(([val[2] for val in my_data], ([val[0] - 1 for val in my_data], [val[1] - 1 for val in my_data])))
    my_sparse_data = sps.csr_matrix((my_sparse_data.data, my_sparse_data.indices, my_sparse_data.indptr[np.concatenate(([True], my_sparse_data.indptr[1:] != my_sparse_data.indptr[:-1]))]))
    return(my_sparse_data)


def clustering1(my_sparse_data, true_k, b, ff):
    km = MiniBatchKMeans(n_clusters=true_k, init='k-means++', n_init=3, batch_size=b, max_no_improvement = None, max_iter = 30)
    km.fit(my_sparse_data)
    np.savetxt("/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/partitions%d/czesc%d/wyniki_%d_%s.txt" % (ff, i, b, typ), km.labels_, delimiter = ', ')
    return(km)
    

#def clustering2(my_sparse_data, true_k, results):
#   km = MiniBatchKMeans(n_clusters=true_k, init=results, n_init=1, batch_size=5000, init_size = 2*true_k)
#   km.fit(my_sparse_data)
#   return(km.cluster_centers_ * my_sparse_data.shape[0])
#   
#def clustering3(my_sparse_data, true_k, results, i, typ):
#   km = MiniBatchKMeans(n_clusters=true_k, init=results, n_init=1, batch_size=5000, init_size = 2*true_k)
#   km.fit(my_sparse_data)
#   np.savetxt("/home/samba/potockan/mgr/czesc%d/wyniki_%s.txt" % (i, typ), km.labels_, delimiter = ', ')
#   #np.savetxt("/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/partitions/czesc%d/wyniki_%s.txt" % (i, typ), km.labels_, delimiter = ', ')


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
    
    

def sticking_data(i, typ, wagi):
    dane = reading_data(i, typ, wagi)
    id_title = list(set([x[0] for x in dane]))
    id_title.sort()
    dane = transforming_data(dane)
#    for aa in range(3,14):
#        print(aa)
#        dane2 = reading_data(aa, typ, wagi)
#        id_title2 = list(set([x[0] for x in dane2]))
#        id_title2.sort()
#        id_title = id_title + id_title2
#        dane = sps.vstack([dane,transforming_data(dane2)])
#        print(len(id_title))
#        del dane2
    return [dane, id_title]



if opts.i:
    i = opts.i
else:
    i = 1
    
if opts.typ:
    typ = opts.typ
else:
    typ = "_red_lcs"
    
if opts.true_k:
    true_k = opts.true_k
else:
    true_k = 100

if opts.b:
    b = opts.b
else:
    b = 5000
    
print("____" + typ + "____") 
np.random.seed(12321)
t0 = time.time()
for ttt in ["sum"]:#, "count"]:
    print("*******" + str(ttt) + "*******")
    t0 = time.time()
    wagi0 = wagi(typ, ttt)
    print("done in %fs" % (time.time() - t0))
    ff = 6
    for fcja in [0,1,2,3,4]:
        print("*******" + str(fcja) + "*******")
        if fcja == 0:
            wagi1 = [[x[0], x[1]**2] for x in wagi0]
        elif fcja == 1:
            wagi1 = [[x[0], x[1]**0.5] for x in wagi0]
        elif fcja == 2:
            wagi1 = [[x[0], np.exp(x[1])] for x in wagi0]
        elif fcja == 3:
            wagi1 = [[x[0], np.log(x[1])] for x in wagi0]
        else:
            wagi1 = wagi0.copy()
    
        dane = sticking_data(i, typ, wagi1)
        id_title = dane[1]
        dane = dane[0]
        for dd in [2]: #[100, 15, 2]:
            if dd == 15:
                id_title = id_title[0:152772]
                dane = dane[0:152772]
                ff = 7
            elif dd == 2:
                id_title = id_title[0:25000]
                dane = dane[0:25000,:]
                ff = 8
    
            labels = reading_labels(typ, i, tuple(id_title))
            print("n_samples: %d, n_features: %d" % dane.shape)
    
            for b in [10000]:#[5000, 10000, 35000, 70000]:
                print("*******" + str(b) + "*******")
                t0 = time.time()
                km = clustering1(dane, true_k, b, ff)
                print("done in %fs" % (time.time() - t0))
                
                
                #print("Homogeneity: %0.3f" % metrics.homogeneity_score(labels, km.labels_))
                #print("Completeness: %0.3f" % metrics.completeness_score(labels, km.labels_))
                #print("V-measure: %0.3f" % metrics.v_measure_score(labels, km.labels_))
                #print("Adjusted Rand-Index: %.3f" % metrics.adjusted_rand_score(labels, km.labels_))
                #print("Silhouette Coefficient: %0.3f" % metrics.silhouette_score(dane, km.labels_, sample_size=10000))
                #print("Adjusted Mutual Information: %0.3f" % metrics.adjusted_mutual_info_score(labels, km.labels_)) 
                #print("Normalized Mutual Information: %0.3f" % metrics.normalized_mutual_info_score(labels, km.labels_))
                
                wyn = [
                metrics.homogeneity_score(labels, km.labels_),
                metrics.completeness_score(labels, km.labels_),
                metrics.v_measure_score(labels, km.labels_),
                metrics.adjusted_rand_score(labels, km.labels_),
                metrics.silhouette_score(dane, km.labels_, sample_size=10000),
                metrics.adjusted_mutual_info_score(labels, km.labels_),
                metrics.normalized_mutual_info_score(labels, km.labels_),
                fm_index(np.array(labels), np.array(km.labels_))
                ]
                
                thefile = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/partitions%d/czesc%d/wyn_%d_%s_%d_%s" % (ff, i, b, typ, fcja, ttt)
                with open(thefile, 'w') as f:
                    for s in wyn:
                        f.write(str(s) + '\n')
