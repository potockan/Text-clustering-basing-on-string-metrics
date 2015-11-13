# -*- coding: utf-8 -*-
"""
Created on Fri Nov 13 11:23:41 2015

@author: natalia
"""



from sklearn.cluster import MiniBatchKMeans
#from scipy.sparse import coo_matrix
import scipy.sparse as sps

import logging
from optparse import OptionParser
import sys
from time import time

import numpy as np
import sqlite3
import socket, pickle
import struct
from kmeans_functions import *


# Display progress logs on stdout
logging.basicConfig(level=logging.INFO,
                    format='%(asctime)s %(levelname)s %(message)s')

# parse commandline arguments
op = OptionParser()
#op.add_option("--res",
#              dest="results", type=np.ndarray,
#              help="A sparse matrix with cluster centers")
op.add_option("--k-num", type=int, dest="true_k", default=0,
              help="Number of clusters")
op.add_option("--i", dest="i", type=int,
              help="A number specyfying the partition")
op.add_option("--typ", type=str, dest="typ", default=0,
              help="Type of the data")
              
print(__doc__)
op.print_help()

(opts, args) = op.parse_args()
if len(args) > 0:
    op.error("this script takes no arguments.")
    sys.exit(1)

if opts.i:
    i = opts.i
else:
    i = 1
    
if opts.typ:
    typ = opts.typ
else:
    typ = "_red_qgram"
t0 = time()
#dane = reading_data(i ,typ)
print("done in %fs" % (time() - t0))
t0 = time()
#dane = transforming_data(dane)
print("done in %fs" % (time() - t0))
#print("n_samples: %d, n_features: %d" % dane.shape)
t0 = time()
#centers = clustering1(dane, 100)
print("done in %fs" % (time() - t0))