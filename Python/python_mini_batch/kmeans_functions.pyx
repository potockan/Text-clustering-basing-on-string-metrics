# -*- coding: utf-8 -*-
"""
Created on Thu Nov 12 10:02:12 2015

@author: natalia
"""

from __future__ import print_function

#from sklearn.datasets import fetch_20newsgroups
#from sklearn.decomposition import TruncatedSVD
#from sklearn.feature_extraction.text import TfidfVectorizer
#from sklearn.feature_extraction.text import HashingVectorizer
#from sklearn.feature_extraction.text import TfidfTransformer
#from sklearn.pipeline import make_pipeline
#from sklearn.preprocessing import Normalizer
# from sklearn import metrics

from sklearn.cluster import MiniBatchKMeans
#from scipy.sparse import coo_matrix
import scipy.sparse as sps

# import logging
# from optparse import OptionParser
# import sys
# from time import time

import numpy as np
import sqlite3
cimport numpy as np
cimport cython

ctypedef np.int32_t cINT32
ctypedef np.double_t cDOUBLE


def reading_data(unsigned int i, unsigned char* typ):
#c.execute('select * from wiki_stem_word_reorder')
    print("Reading data...")
     
    con = sqlite3.connect("/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/partitions/czesc%d/wiki%s.sqlite" % (i, typ))
    c = con.cursor()
    
    c.execute('''select 
    id_title, id_stem_word, freq 
    from art_word_freq%s
    order by id_title
    ''' % (typ))
    
    cdef list data = c.fetchall()
    
    con.close()
        
    
#    con = sqlite3.connect("/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/partitions/czesc%d/wiki_art_cat.sqlite" % (i))
#    c = con.cursor()    
#    
#    c.execute('select id_category from wiki_unique_category order by id_title')
#    print("Reading labels...")
#    labels = c.fetchall()    
#    con.close()
    
    return(data)
    

def transforming_data(list my_data):
    #labels = np.asarray([val[0] for val in labels])   
    cdef tuple val
    my_sparse_data = sps.csr_matrix(([val[2] for val in my_data], ([val[0] -1 for val in my_data], [val[1] - 1 for val in my_data])))
    my_sparse_data = sps.csr_matrix((my_sparse_data.data, my_sparse_data.indices, my_sparse_data.indptr[np.concatenate(([True], my_sparse_data.indptr[1:] != my_sparse_data.indptr[:-1]))]))
    return(my_sparse_data)


def clustering1(my_sparse_data, unsigned int true_k):
    km = MiniBatchKMeans(n_clusters=true_k, init='k-means++', n_init=1, batch_size=100, init_size = 2*true_k)
    km.fit(my_sparse_data)
    return(km.cluster_centers_ * my_sparse_data.shape[0])
    
    
def clustering2(my_sparse_data, unsigned int true_k, results):
   km = MiniBatchKMeans(n_clusters=true_k, init=results, n_init=1, batch_size=1000, init_size = 2*true_k)
   km.fit(my_sparse_data)
   return(km.cluster_centers_ * my_sparse_data.shape[0])
   
def clustering3(my_sparse_data, unsigned int true_k, results):
   km = MiniBatchKMeans(n_clusters=true_k, init=results, n_init=1, batch_size=1000, init_size = 2*true_k)
   km.predict(my_sparse_data)
   np.savetxt("/dragon/Text-clustering-basing-on-string-metrics/Data/pyObjects/km_labels2.txt", km.labels_, delimiter = ', ')

