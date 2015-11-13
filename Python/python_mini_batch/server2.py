# -*- coding: utf-8 -*-
"""
Created on Thu Nov 12 15:41:21 2015

@author: potockan
"""
import socket, pickle, numpy as np
import struct
from time import time


HOST = ''
PORT = 50007
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind((HOST, PORT))
s.listen(2)
print('0')

while 1:
    L = np.zeros((100, 43919))
    print('01')
    #wait to accept a connection - blocking call
    conn, addr = s.accept()
    print ('Connected with ', addr)
    buf = b''
    print('02')
    while len(buf) < 4:
        buf += conn.recv(4 - len(buf))
    print('03')
    length = struct.unpack('>I', buf)[0]
    print(length)
    data = b''
    l = length
    print('1')
    
    t0 = time()
    while l > 0:
        #print('2')
        d = conn.recv(l)
        #print('3')
        l -= len(d)
        #print('4')
        data += d
        #print('y')
    print("done in %fs" % (time() - t0))
    if not data: break
    print("loading")
    t0 = time()
    M = np.loads(data) # HERE IS AN ERROR
    print("loaded")
    print("done in %fs" % (time() - t0))
    L += M
    t0 = time()
    data_out = pickle.dumps(L)
    print("done in %fs" % (time() - t0))
    conn.sendall(data_out)
    conn.close() 
s.close()