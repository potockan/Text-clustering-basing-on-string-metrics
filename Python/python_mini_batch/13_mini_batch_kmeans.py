# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>
# source :
# http://scikit-learn.org/stable/auto_examples/text/document_clustering.html#example-text-document-clustering-py
# <codecell>

# Author: Peter Prettenhofer <peter.prettenhofer@gmail.com>
#         Lars Buitinck <L.J.Buitinck@uva.nl>
# License: BSD 3 clause

from __future__ import print_function

#from sklearn.datasets import fetch_20newsgroups
#from sklearn.decomposition import TruncatedSVD
#from sklearn.feature_extraction.text import TfidfVectorizer
#from sklearn.feature_extraction.text import HashingVectorizer
#from sklearn.feature_extraction.text import TfidfTransformer
#from sklearn.pipeline import make_pipeline
#from sklearn.preprocessing import Normalizer
from sklearn import metrics

from sklearn.cluster import MiniBatchKMeans
#from scipy.sparse import coo_matrix
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


# <codecell>


###############################################################################
# Load some categories from the training set
#categories = [
#    'sztuka',
#    'matma',
#    'wojna',
#]
# Uncomment the following to do the analysis on all the categories
#categories = None

#print("Loading 3 groups dataset for categories:")
#print(categories)
#
#dataset = fetch_20newsgroups(subset='all', categories=categories,
#                             shuffle=True, random_state=42)
#
#print("%d documents" % len(dataset.data))
#print("%d categories" % len(dataset.target_names))
#print()
#
#labels = dataset.target
#true_k = np.unique(labels).shape[0]

#print("Extracting features from the training dataset using a sparse vectorizer")
t0 = time()
#if opts.use_hashing:
#    if opts.use_idf:
#        # Perform an IDF normalization on the output of HashingVectorizer
#        hasher = HashingVectorizer(n_features=opts.n_features,
#                                   stop_words='english', non_negative=True,
#                                   norm=None, binary=False)
#        vectorizer = make_pipeline(hasher, TfidfTransformer())
#    else:
#        vectorizer = HashingVectorizer(n_features=opts.n_features,
#                                       stop_words='english',
#                                       non_negative=False, norm='l2',
#                                       binary=False)
#else:
#    vectorizer = TfidfVectorizer(max_df=0.5, max_features=opts.n_features,
#                                 min_df=2, stop_words='english',
#                                 use_idf=opts.use_idf)

###############################
import sqlite3


con = sqlite3.connect("/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/wiki.sqlite")
c = con.cursor()

c.execute('select id_category from wiki_unique_category order by id_title')
print("Reading labels...")
labels = c.fetchall()

def reading_data(typ):
#c.execute('select * from wiki_stem_word_reorder')
    print("Reading data...")
    c.execute('''select 
    id_title, id_stem_word, freq 
    from wiki_word_clust2%s_freq
    order by id_title
    ''' % (typ))
    return(c.fetchall())
    

###############################

print("Data transformations...")
labels = np.asarray([val[0] for val in labels])

typ1 = '_red_lcs'
print(typ1)
my_data = reading_data(typ1)

con.close()

my_sparse_data = sps.csr_matrix(([val[2] for val in my_data], ([val[0] for val in my_data], [val[1] - 1 for val in my_data])))
print("Data deletation...")
del my_data
print("Data transformations...")
# get rid of the all-zero rows
my_sparse_data = sps.csr_matrix((my_sparse_data.data, my_sparse_data.indices, my_sparse_data.indptr[np.concatenate(([True], my_sparse_data.indptr[1:] != my_sparse_data.indptr[:-1]))]))



################### cython #######################
# import numpy as np
# cimport numpy as np
# ...
# cdef np.ndarray[np.intc_t] rows, cols
# cdef np.ndarray[double] values
# rows = np.zeros(nnz, dtype=np.intc)
# cols = np.zeros(nnz, dtype=np.intc)
# values = np.zeros(nnz, dtype=np.double)
# cdef int idx = 0
# for idx in range(0, nnz):
#      # Compute next non-zero matrix element
#      ...
#      rows[idx] = row; cols[idx] = col
#      values[idx] = value
# # Finally, we construct a regular
# # SciPy sparse matrix:
# return scipy.sparse.coo_matrix((values, (rows, cols)), shape=(N,N))
##########################################


#labels = np.delete(np.genfromtxt('/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/labels.csv', delimiter=',', dtype = 'int32'), 0, 0) - 1
#my_data = np.delete(np.genfromtxt('/dragon/Text-clustering-basing-on-string-metrics/Data/RObjects/sparse_matrix.csv', delimiter=','), 0, 0)
#my_sparse_data = coo_matrix((my_data[:,0], (my_data[:, 1]-1, my_data[:, 2]-1)))
#

#X = vectorizer.fit_transform(dataset.data)

print("done in %fs" % (time() - t0))
print("n_samples: %d, n_features: %d" % my_sparse_data.shape)
print()


#if opts.n_components:
#    print("Performing dimensionality reduction using LSA")
#    t0 = time()
#    # Vectorizer results are normalized, which makes KMeans behave as
#    # spherical k-means for better results. Since LSA/SVD results are
#    # not normalized, we have to redo the normalization.
#    svd = TruncatedSVD(opts.n_components)
#    lsa = make_pipeline(svd, Normalizer(copy=False))
#
#    X = lsa.fit_transform(X)
#
#    print("done in %fs" % (time() - t0))
#
#    explained_variance = svd.explained_variance_ratio_.sum()
#    print("Explained variance of the SVD step: {}%".format(
#        int(explained_variance * 100)))
#
#    print()


# <codecell>


###############################################################################
# Do the actual clustering

if opts.true_k:
    true_k = opts.true_k
else:
    true_k = np.size(np.unique(labels))


#if opts.minibatch:
km = MiniBatchKMeans(n_clusters=true_k, init='k-means++', n_init=1, batch_size=1000, init_size = 2*true_k, verbose=opts.verbose)
#else:
#    km = KMeans(n_clusters=true_k, init='k-means++', max_iter=100, n_init=1,
#                verbose=opts.verbose)

print("Clustering sparse data with %s" % km)
t0 = time()
km.fit(my_sparse_data)
print("done in %0.3fs" % (time() - t0))
print()

np.savetxt("/dragon/Text-clustering-basing-on-string-metrics/Data/pyObjects/km_labels.txt", km.labels_, delimiter = ', ')
np.savetxt("/dragon/Text-clustering-basing-on-string-metrics/Data/pyObjects/km_centers.txt", km.cluster_centers_, delimiter = ', ')



print("Homogeneity: %0.3f" % metrics.homogeneity_score(labels, km.labels_))
print("Completeness: %0.3f" % metrics.completeness_score(labels, km.labels_))
print("V-measure: %0.3f" % metrics.v_measure_score(labels, km.labels_))
print("Adjusted Rand-Index: %.3f" % metrics.adjusted_rand_score(labels, km.labels_))
#print("Silhouette Coefficient: %0.3f" % metrics.silhouette_score(my_sparse_data, km.labels_, sample_size=1000))

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

