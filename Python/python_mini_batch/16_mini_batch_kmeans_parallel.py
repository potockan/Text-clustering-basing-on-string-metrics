# -*- coding: utf-8 -*-
"""
Created on Thu Aug 27 12:53:40 2015

@author: natalia
"""


from sklearn.cluster import MiniBatchKMeans
from scipy.sparse import coo_matrix
#import scipy.sparse as sps
import numpy as np
from optparse import OptionParser
import sys


# parse commandline arguments
op = OptionParser()
op.add_option("--res",
              dest="results", type="ndarray",
              help="A sparse matrix with cluster centers")
              
(opts, args) = op.parse_args()
if len(args) > 0:
    op.error("this script takes no arguments.")
    sys.exit(1)


def clustering1():
    my_data = np.delete(np.genfromtxt('/home/Text-clustering-basing-on-string-metrics/Data/RObjects/sparse_matrix.csv', delimiter=','), 0, 0)
    my_sparse_data = coo_matrix((my_data[:,0], (my_data[:, 1]-1, my_data[:, 2]-1)))
    my_sparse_data = my_sparse_data.tocsr()
    true_k = 67969
    km = MiniBatchKMeans(n_clusters=true_k, init='k-means++', n_init=1, batch_size=1000, init_size = 2*true_k)
    km.fit(my_sparse_data)
    return(km.cluster_centers_ * my_sparse_data.shape[0])
    
clustering1()
#    
#def clustering2(results):
#    my_data = np.delete(np.genfromtxt('/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/sparse_matrix.csv', delimiter=','), 0, 0)
#    my_sparse_data = coo_matrix((my_data[:,0], (my_data[:, 1]-1, my_data[:, 2]-1)))
#    my_sparse_data = my_sparse_data.tocsr()
#    true_k = 67969
#    km = MiniBatchKMeans(n_clusters=true_k, init=results, n_init=1, batch_size=1000, init_size = 2*true_k)
#    km.fit(my_sparse_data)
#    return(km.cluster_centers_ * my_sparse_data.shape[0])
#    
#clustering2(opts.results)
#    
#    
#def clustering3(results):
#    my_data = np.delete(np.genfromtxt('/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/sparse_matrix.csv', delimiter=','), 0, 0)
#    my_sparse_data = coo_matrix((my_data[:,0], (my_data[:, 1]-1, my_data[:, 2]-1)))
#    my_sparse_data = my_sparse_data.tocsr()
#    true_k = 67969
#    km = MiniBatchKMeans(n_clusters=true_k, init=results, n_init=1, batch_size=1000, init_size = 2*true_k)
#    km.predict(my_sparse_data)
#    np.savetxt("/dragon/Text-clustering-basing-on-string-metrics/Data/pyObjects/km_labels2.txt", km.labels_, delimiter = ', ')
#
#clustering3(opts.results)
#
