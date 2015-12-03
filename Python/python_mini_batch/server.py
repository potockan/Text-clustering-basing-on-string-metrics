# -*- coding: utf-8 -*-
"""
Created on Thu Nov 12 15:41:21 2015

@author: potockan
"""
import socket, pickle, numpy as np
import struct
#import time
import math
from multiprocessing.pool import ThreadPool



def clientthread(conn, L):
    #Sending message to connected client
    #conn.send('Welcome to the server. Type something and hit enter\n') #send only takes string
     
    #infinite loop so that function do not terminate and thread do not end.
    #while True:
         
        #Receiving from client
    #print("1")
    buf = b''
    while len(buf) < 4:
        buf += conn.recv(4 - len(buf))
    #print("2")
    length = struct.unpack('>I', buf)[0]
    data = b''
    l = length
        
    #print("3")
    while l > 0:
        d = conn.recv(l)
        l -= len(d)
        data += d
    #print("5")
    #if not data: break
    #print("6")
    M = np.loads(data) # HERE IS AN ERROR
        
#        if i == 1:
#            L = M[0]
#        else:
#            L += M[0]
#        ports.append(M[1])
    #    t0 = time.time()
    #    data_out = pickle.dumps(L)
    #    print("done in %fs" % (time.time() - t0))
    #    conn.sendall(data_out)
        
    return(M)


nazwy = [ '_jaccard','_qgram',
'_red_lcs','_red_dl','_red_jaccard','_red_qgram',
'_red_lcs_lcs','_red_dl_dl','_red_jaccard_jaccard','_red_qgram_qgram']
           
typ = nazwy[0]

j = 0
while 1:
    HOST = ''
    PORT = 50007
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.bind((HOST, PORT))
    s.listen(2)
    #print('0')
    
    adresses = []
    ports = []
    
    i = 0
    print("receiving...")
    while i < 2:
        i += 1    
        #wait to accept a connection - blocking call
        conn, addr = s.accept()
        print ('Connected with ', addr)
        adresses.append(addr[0])
        
        print("Thread")
        pool = ThreadPool(processes=2)

# tuple of args for foo, please note a "," at the end of the arguments
        print("Apply")
        async_result = pool.apply_async(clientthread, (conn, i,))

# Do some other stuff in the main process
        print("Results")
        M = async_result.get()  
        print("Close")
        conn.close() 
        #M = threading.Thread(target = clientthread, args = (conn, i)).start()
#        buf = b''
#        while len(buf) < 4:
#            buf += conn.recv(4 - len(buf))
#        length = struct.unpack('>I', buf)[0]
#        data = b''
#        l = length
#        
#        while l > 0:
#
#            d = conn.recv(l)
#            l -= len(d)
#            data += d
#
#        if not data: break
#       
#        M = np.loads(data) # HERE IS AN ERROR
#        
        if i == 1:
            L = M[0]
        else:
            L += M[0]
        ports.append(M[1])
        print("Done")
#    #    t0 = time.time()
#    #    data_out = pickle.dumps(L)
#    #    print("done in %fs" % (time.time() - t0))
#    #    conn.sendall(data_out)
#        conn.close() 
        #print(i)
    s.close()
    
    
    L /= 993040
    
    packet = pickle.dumps(L)
    length = struct.pack('>I', len(packet))
    packet = length + packet
    
    print("sending...")
    for kl, addr in enumerate(adresses):
        HOST = addr
        PORT = 50007 + ports[kl]
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((HOST, PORT))
        #t0 = time.time()
        s.sendall(packet)
        #print("done in %fs" % (time.time() - t0))
        s.close()
    
    if j%100 == 0:
        typ = nazwy[math.floor(j/100)]
    print(j)
    print(typ)
    j += 1
    print("saving...")
    #np.savetxt("/home/samba/potockan/mgr/all/wyniki_%s.txt" % (typ), L, delimiter = '; ')
    np.savetxt("/dragon/Text-clustering-basing-on-string-metrics/Data/DataBase/partitions/all/wyniki_%s.txt" % (typ), L, delimiter = '; ')