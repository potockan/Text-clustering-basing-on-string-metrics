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
import time

import numpy as np
import sqlite3
import socket, pickle
import struct



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
              
print(__doc__)
op.print_help()

(opts, args) = op.parse_args()
if len(args) > 0:
    op.error("this script takes no arguments.")
    sys.exit(1)


def reading_data(i, typ):
#c.execute('select * from wiki_stem_word_reorder')
    print("Reading data...")
     
    #con = sqlite3.connect("/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/partitions/czesc%d/wiki%s.sqlite" % (i, typ))
    con = sqlite3.connect("/home/samba/potockan/mgr/czesc%d/wiki%s.sqlite" % (i, typ))
    c = con.cursor()
    
    if typ == "_":
        typ = ""
    
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
   
def clustering3(my_sparse_data, true_k, results, i, typ):
   km = MiniBatchKMeans(n_clusters=true_k, init=results, n_init=1, batch_size=1000, init_size = 2*true_k)
   km.fit(my_sparse_data)
   np.savetxt("/home/samba/potockan/mgr/czesc%d/wyniki_%s.txt" % (i, typ), km.labels_, delimiter = ', ')
   #np.savetxt("/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/partitions/czesc%d/wyniki_%s.txt" % (i, typ), km.labels_, delimiter = ', ')




def connection(centers, kl):
    
    #HOST = "10.0.0.105"
    HOST = "192.168.143.79"
    PORT = 50007
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    #s.setdefaulttimeout(3600)
    s.settimeout(3600)
    try:
        s.connect((HOST, PORT))
        s.settimeout(None)
    except EOFError:
        print('error ', kl)
        connection(centers, kl)
    packet = pickle.dumps([centers, kl]) ## ???
    length = struct.pack('>I', len(packet))
    packet = length + packet
    s.sendall(packet)
    s.close()
    #print ('Received', data_new)
    
    
    
    HOST = ''
    PORT = 50007 + kl
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.bind((HOST, PORT))

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
        #print(length)
        data = b''
        l = length
        while l > 0:
            d = conn.recv(l)
            l -= len(d)
            data += d
            #print('y')
        if not data: break
            
        new_centers = np.loads(data)
        conn.close()
     
    s.close()
    return new_centers




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
t0 = time.time()
dane = reading_data(i ,typ)
print("done in %fs" % (time.time() - t0))
t0 = time.time()
dane = transforming_data(dane)
print("done in %fs" % (time.time() - t0))
print("n_samples: %d, n_features: %d" % dane.shape)
t0 = time.time()
centers = clustering1(dane, true_k)
print("done in %fs" % (time.time() - t0))

centers = connection(centers, i)

for k in range(44):
    print(k)
    centers = clustering2(dane, true_k, centers)
    time.sleep(90)
    centers = connection(centers, i)

clustering3(dane, true_k, centers, i, typ)

