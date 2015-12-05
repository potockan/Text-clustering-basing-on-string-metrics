#/usr/bin/python3

"""
Created on Thu Dec 5 16:49:04 2015

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
    from art_word_freq%s'''  % (typ))
    #   order by id_title 
    
    data = c.fetchall()
    
    con.close()
        
    
    #    con = sqlite3.connect("/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/partitions/czesc%d/wiki_art_cat.sqlite" % (i))
    #    c = con.cursor()    
        
    #    c.execute('''select a.id_cat from 
    #    (select id_cat, id_title from cat_art limit 76387) as a
    #    order by a.id_title''')
    #    print("Reading labels...")
    #    labels = c.fetchall()    
    #    con.close()
        
    return(data)
    

def transforming_data(my_data):
    #labels = np.asarray([val[0] for val in labels])    
    my_sparse_data = sps.csr_matrix(([val[2] for val in my_data], ([val[0] -1 for val in my_data], [val[1] - 1 for val in my_data])))
    my_sparse_data = sps.csr_matrix((my_sparse_data.data, my_sparse_data.indices, my_sparse_data.indptr[np.concatenate(([True], my_sparse_data.indptr[1:] != my_sparse_data.indptr[:-1]))]))
    return(my_sparse_data)
#
#
#def clustering1(my_sparse_data, true_k, b):
#    km = MiniBatchKMeans(n_clusters=true_k, init='k-means++', n_init=3, batch_size=b, init_size = 2*true_k)
#    km.fit(my_sparse_data)
#    np.savetxt("/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/partitions/czesc%d/wyniki_%d_%s.txt" % (i, b, typ), km.labels_, delimiter = ', ')
#    return(km)
#    
#
##def clustering2(my_sparse_data, true_k, results):
##   km = MiniBatchKMeans(n_clusters=true_k, init=results, n_init=1, batch_size=5000, init_size = 2*true_k)
##   km.fit(my_sparse_data)
##   return(km.cluster_centers_ * my_sparse_data.shape[0])
##   
##def clustering3(my_sparse_data, true_k, results, i, typ):
##   km = MiniBatchKMeans(n_clusters=true_k, init=results, n_init=1, batch_size=5000, init_size = 2*true_k)
##   km.fit(my_sparse_data)
##   np.savetxt("/home/samba/potockan/mgr/czesc%d/wyniki_%s.txt" % (i, typ), km.labels_, delimiter = ', ')
##   #np.savetxt("/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/partitions/czesc%d/wyniki_%s.txt" % (i, typ), km.labels_, delimiter = ', ')
#

def reading_labels(typ, i):
    if typ == "_":
        typ = ""
    con = sqlite3.connect("/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/partitions/czesc%d/wiki_art_cat.sqlite" % (i))
    c = con.cursor()    
    
    c.execute('''
    select a.id_cat from 
    cat_art2 as a
    where id_title != 391868
    order by id_title
    ''')
    print("Reading labels...")
    labels = c.fetchall()    
    con.close()
    labels = np.array(labels)
    labels.shape = (labels.shape[0],)
    return labels



if opts.i:
    i = opts.i
else:
    i = 1
    
if opts.typ:
    typ = opts.typ
else:
    typ = "_red_qgram"
    
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
dane = reading_data(i ,typ)
print("done in %fs" % (time.time() - t0))
t0 = time.time()
dane = transforming_data(dane)
print("done in %fs" % (time.time() - t0))
print("n_samples: %d, n_features: %d" % dane.shape)
#t0 = time.time()
#km = clustering1(dane, true_k, b)
#print("done in %fs" % (time.time() - t0))
t0 = time.time()
labels = reading_labels(typ, i)
print("done in %fs" % (time.time() - t0))

km_labels_ = np.loadtxt("/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/partitions/czesc%d/wyniki%s/wyniki_%d_%s.txt" % (i, typ, b, typ), delimiter = ', ')


#print("Homogeneity: %0.3f" % metrics.homogeneity_score(labels, km.labels_))
#print("Completeness: %0.3f" % metrics.completeness_score(labels, km.labels_))
#print("V-measure: %0.3f" % metrics.v_measure_score(labels, km.labels_))
#print("Adjusted Rand-Index: %.3f" % metrics.adjusted_rand_score(labels, km.labels_))
#print("Silhouette Coefficient: %0.3f" % metrics.silhouette_score(dane, km.labels_, sample_size=10000))
#print("Adjusted Mutual Information: %0.3f" % metrics.adjusted_mutual_info_score(labels, km.labels_)) 
#print("Normalized Mutual Information: %0.3f" % metrics.normalized_mutual_info_score(labels, km.labels_))

wyn = [
metrics.homogeneity_score(labels, km_labels_),
metrics.completeness_score(labels, km_labels_),
metrics.v_measure_score(labels, km_labels_),
metrics.adjusted_rand_score(labels, km_labels_),
metrics.silhouette_score(dane, km_labels_, sample_size=10000),
metrics.adjusted_mutual_info_score(labels, km_labels_),
metrics.normalized_mutual_info_score(labels, km_labels_)
]

thefile = "/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/partitions/czesc%d/wyniki%s/wyn_%d_%s" % (i, typ, b, typ)
with open(thefile, 'w') as f:
    for s in wyn:
        f.write(str(s) + '\n')
