# -*- coding: utf-8 -*-
"""
Created on Thu Nov 12 15:41:21 2015

@author: potockan
"""
import socket, pickle, numpy as np
import struct
import time

while 1:
    
    HOST = ''
    PORT = 50007
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.bind((HOST, PORT))
    s.listen(2)
    print('0')
    
    adresses = []
    
    i = 0
    while i < 2:
        i += 1    
        #print('01')
        #wait to accept a connection - blocking call
        print('2')
        conn, addr = s.accept()
        print ('Connected with ', addr)
        adresses.append(addr[0])
        buf = b''
        #print('02')
        while len(buf) < 4:
            buf += conn.recv(4 - len(buf))
        #print('03')
        length = struct.unpack('>I', buf)[0]
        #print(length)
        data = b''
        l = length
        #print('1')
        
        #t0 = time.time()
        while l > 0:
            #print('2')
            d = conn.recv(l)
            #print('3')
            l -= len(d)
            #print('4')
            data += d
            #print('y')
        #print("done in %fs" % (time.time() - t0))
        if not data: break
        #print("loading")
        #t0 = time.time()
        M = np.loads(data) # HERE IS AN ERROR
        #print("loaded")
        #print("done in %fs" % (time.time() - t0))
        if i == 1:
            L = M
        else:
            L += M
    #    t0 = time.time()
    #    data_out = pickle.dumps(L)
    #    print("done in %fs" % (time.time() - t0))
    #    conn.sendall(data_out)
        conn.close() 
    s.close()
    
    
    L /= i
    
    time.sleep(5)
    
    for addr in adresses:
        HOST = addr
        PORT = 50007
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((HOST, PORT))
        #centers = np.zeros((100, 43919))
        packet = pickle.dumps(L)
        length = struct.pack('>I', len(packet))
        packet = length + packet
        t0 = time.time()
        s.sendall(packet)
        print("done in %fs" % (time.time() - t0))
        s.close()
    
    