#!/opt/anaconda/lib/python3.4
"""
Created on Thu Nov 12 12:29:04 2015

@author: potockan
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

#HOST = "192.168.0.11"




#from __future__ import print_function

#from sklearn.datasets import fetch_20newsgroups
#from sklearn.decomposition import TruncatedSVD
#from sklearn.feature_extraction.text import TfidfVectorizer
#from sklearn.feature_extraction.text import HashingVectorizer
#from sklearn.feature_extraction.text import TfidfTransformer
#from sklearn.pipeline import make_pipeline
#from sklearn.preprocessing import Normalizer
#from sklearn import metrics





# <codecell>

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


def reading_data(i, typ):
#c.execute('select * from wiki_stem_word_reorder')
    print("Reading data...")
     
    con = sqlite3.connect("/home/samba/potockan/mgr/czesc%d/wiki%s.sqlite" % (i, typ))
    c = con.cursor()
    
    c.execute('''select 
    id_title, id_stem_word, freq 
    from art_word_freq%s
    order by id_title
    ''' % (typ))
    
    data = c.fetchall()
    
    con.close()
        
    
#    con = sqlite3.connect("/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/partitions/czesc%d/wiki_art_cat.sqlite" % (i))
#    c = con.cursor()    
#    
#    c.execute('select id_category from wiki_unique_category order by id_title')
#    print("Reading labels...")
#    labels = c.fetchall()    
#    con.close()
    
    return(data)
    

def transforming_data(my_data):
    #labels = np.asarray([val[0] for val in labels])    
    my_sparse_data = sps.csr_matrix(([val[2] for val in my_data], ([val[0] -1 for val in my_data], [val[1] - 1 for val in my_data])))
    my_sparse_data = sps.csr_matrix((my_sparse_data.data, my_sparse_data.indices, my_sparse_data.indptr[np.concatenate(([True], my_sparse_data.indptr[1:] != my_sparse_data.indptr[:-1]))]))
    return(my_sparse_data)


def clustering1(my_sparse_data, true_k):
    km = MiniBatchKMeans(n_clusters=true_k, init='k-means++', n_init=1, batch_size=1000, init_size = 2*true_k)
    km.fit(my_sparse_data)
    return(km.cluster_centers_ * my_sparse_data.shape[0])
    
    
def clustering2(my_sparse_data, true_k, results):
   km = MiniBatchKMeans(n_clusters=true_k, init=results, n_init=1, batch_size=1000, init_size = 2*true_k)
   km.fit(my_sparse_data)
   return(km.cluster_centers_ * my_sparse_data.shape[0])
   
def clustering3(my_sparse_data, true_k, results):
   km = MiniBatchKMeans(n_clusters=true_k, init=results, n_init=1, batch_size=1000, init_size = 2*true_k)
   km.predict(my_sparse_data)
   np.savetxt("/dragon/Text-clustering-basing-on-string-metrics/Data/pyObjects/km_labels2.txt", km.labels_, delimiter = ', ')



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


HOST = "10.0.0.105"
PORT = 50007
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((HOST, PORT))
centers = np.zeros((100, 43919))
packet = pickle.dumps(centers)
length = struct.pack('>I', len(packet))
packet = length + packet
s.sendall(packet)
s.close()
#print ('Received', data_new)

print("done in %fs" % (time() - t0))


HOST = ''
PORT = 50007
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
try:
    s.bind((HOST, PORT))
except (socket.error, msg):
    print ('Bind failed. Error Code : ' + str(msg[0]) + ' Message ' + msg[1])
    sys.exit()
s.listen(2)

i = 0
while i < 1:
    #wait to accept a connection - blocking call
    conn, addr = s.accept()
    i += 1
    print ('Connected with ', addr)
    buf = b''
    while len(buf) < 4:
        buf += conn.recv(4 - len(buf))
        
    length = struct.unpack('>I', buf)[0]
    print(length)
    data = b''
    l = length
    while l > 0:
        d = conn.recv(l)
        l -= len(d)
        data += d
        print('y')
    if not data: break
        
    new_centers = np.loads(data)
    conn.close()
 
s.close()





