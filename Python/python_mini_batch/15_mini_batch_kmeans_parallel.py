# -*- coding: utf-8 -*-
"""
Created on Thu Aug 27 12:53:40 2015

@author: natalia
"""


from multiprocessing import Pool, freeze_support
from functools import partial
from itertools import repeat
from __future__ import print_function
from sklearn import metrics
from sklearn.cluster import MiniBatchKMeans, KMeans
from scipy.sparse import coo_matrix
import scipy.sparse as sps
import logging
from optparse import OptionParser
import sys
from time import time
import numpy as np



# <codecell>

# Display progress logs on stdout
logging.basicConfig(level=logging.INFO,
                    format='%(asctime)s %(levelname)s %(message)s')

# parse commandline arguments
op = OptionParser()
op.add_option("--lsa",
              dest="n_components", type="int",
              help="Preprocess documents with latent semantic analysis.")
op.add_option("--no-minibatch",
              action="store_false", dest="minibatch", default=True,
              help="Use ordinary k-means algorithm (in batch mode).")
op.add_option("--no-idf",
              action="store_false", dest="use_idf", default=True,
              help="Disable Inverse Document Frequency feature weighting.")
op.add_option("--use-hashing",
              action="store_true", default=False,
              help="Use a hashing feature vectorizer")
op.add_option("--n-features", type=int, default=10000,
              help="Maximum number of features (dimensions)"
                   " to extract from text.")
op.add_option("--verbose",
              action="store_true", dest="verbose", default=False,
              help="Print progress reports inside k-means algorithm.")
op.add_option("--k-num", type=int, dest="true_k", default=0,
              help="Number of clusters")

print(__doc__)
op.print_help()

(opts, args) = op.parse_args()
if len(args) > 0:
    op.error("this script takes no arguments.")
    sys.exit(1)



###############################
#import sqlite3
#con = sqlite3.connect("/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")
#c = con.cursor()
#
#c.execute('select id_category from wiki_unique_category')
#print("Reading labels...")
#labels = c.fetchall()
#
##c.execute('select * from wiki_stem_word_reorder')
#print("Reading data...")
#c.execute('''select 
#a.id_title, b.id, a.freq 
#from wiki_word_clust_freq a 
#
#join 
#
#wiki_stem_word_reorder b 
#on 
#a.id_stem_word = b.id_stem_word 
#''')
#my_data = c.fetchall()
#con.close()
###############################
#
#print("Data transformations...")
#labels = np.asarray([val[0] for val in labels])
#
#my_sparse_data = sps.csr_matrix(([val[2] for val in my_data], ([val[0] for val in my_data], [val[1] - 1 for val in my_data])))
#print("Data deletation...")
#del my_data
#print("Data transformations...")
#my_sparse_data = sps.csr_matrix((my_sparse_data.data, my_sparse_data.indices, my_sparse_data.indptr[np.concatenate(([True], my_sparse_data.indptr[1:] != my_sparse_data.indptr[:-1]))]))


#my_sparse_data1 = my_sparse_data[:10241,]
#my_sparse_data2 = my_sparse_data[10241:,]



def clustering(km, data_all):
    km.fit(data_all)
    return(km.cluster_centers_ * data_all.shape[0])
    
def clustering2(km, data_all):
    km.fit(data_all)
    return(km.labels_)
    
#def main():  
t0 = time()
labels = np.delete(np.genfromtxt('/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/labels.csv', delimiter=',', dtype = 'int32'), 0, 0) - 1
my_data = np.delete(np.genfromtxt('/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/sparse_matrix.csv', delimiter=','), 0, 0)
my_sparse_data = coo_matrix((my_data[:,0], (my_data[:, 1]-1, my_data[:, 2]-1)))
my_sparse_data = my_sparse_data.tocsr()
print("done in %fs" % (time() - t0))
print("n_samples: %d, n_features: %d" % my_sparse_data.shape)
print()
true_k = np.size(np.unique(labels))
km_all = [MiniBatchKMeans(n_clusters=true_k, init='k-means++', n_init=1, batch_size=1000, init_size = 2*true_k), MiniBatchKMeans(n_clusters=true_k, init='k-means++', n_init=1, batch_size=1000, init_size = 2*true_k)]
data_all = [my_sparse_data[:10241,], my_sparse_data[10241:,]]
pool = Pool(processes=2)
results = pool.starmap(clustering, zip(km_all, data_all))
results = sum(results) / my_sparse_data.shape[0]

km_all = [MiniBatchKMeans(n_clusters=true_k, init=results, n_init=1, batch_size=1000, init_size = 2*true_k), MiniBatchKMeans(n_clusters=true_k, init=results, n_init=1, batch_size=1000, init_size = 2*true_k)]

for i in range(3):
    results = pool.starmap(clustering, zip(km_all, data_all))
    results = sum(results) / my_sparse_data.shape[0]
    
labels_out = pool.starmap(clustering2, zip(km_all, data_all))
labels_out = np.concatenate(labels_out)

pool.close()
#return(results)

#if __name__=="__main__":
#    freeze_support()
#    main()

#new_centers = np.zeros((true_k, data_all[0].shape[1]))
## for i in range(5):
#t0 = time()
#for i, km in enumerate(km_all):
#    print("Clustering sparse data with %s" % km)
#    km.fit(data_all[i])
#    new_centers += km.cluster_centers_ * data_all[i].shape[0]
# 
#new_centers /= my_sparse_data.shape[0]
#print("done in %0.3fs" % (time() - t0))
#print()
   

#km.fit(my_sparse_data1)
#km1.fit(my_sparse_data2)

#new_centers = (km.cluster_centers_ * my_sparse_data1.shape[0] +  km1.cluster_centers_ * my_sparse_data2.shape[0]) /  my_sparse_data.shape[0]

#km = MiniBatchKMeans(n_clusters=true_k, init=new_centers, n_init=1, batch_size=1000, init_size = 2*true_k, verbose=opts.verbose)
#km1 = MiniBatchKMeans(n_clusters=true_k, init=new_centers, n_init=1, batch_size=1000, init_size = 2*true_k, verbose=opts.verbose)
#    
#
#for x in range(100):    
#    print("Clustering sparse data with %s" % km)
#    t0 = time()
#    km.fit(my_sparse_data1)
#    km1.fit(my_sparse_data2)
#    print("done in %0.3fs" % (time() - t0))
#    print()
#    
#    new_centers = (km.cluster_centers_ * my_sparse_data1.shape[0] +  km1.cluster_centers_ * my_sparse_data2.shape[0]) /  my_sparse_data.shape[0]

labels_out = np.concatenate([km.labels_ for km in km_all])

np.savetxt("/dragon/Text-clustering-basing-on-string-metrics/Data/pyObjects/km_labels2.txt", labels_out, delimiter = ', ')

print("Homogeneity: %0.3f" % metrics.homogeneity_score(labels, labels_out))
print("Completeness: %0.3f" % metrics.completeness_score(labels, labels_out))
print("V-measure: %0.3f" % metrics.v_measure_score(labels, labels_out))
print("Adjusted Rand-Index: %.3f" % metrics.adjusted_rand_score(labels, labels_out))
#print("Silhouette Coefficient: %0.3f" % metrics.silhouette_score(my_sparse_data[0:100,], km.labels_, sample_size=1000))

print()

#if not (opts.n_components or opts.use_hashing):
#    print("Top terms per cluster:")
#    order_centroids = km.cluster_centers_.argsort()[:, ::-1]
##    terms = vectorizer.get_feature_names()
#    for i in range(true_k):
#        print("Cluster %d:" % i, end='')
##        for ind in order_centroids[i, :10]:
##            print(' %s' % terms[ind], end='')
#        print()

