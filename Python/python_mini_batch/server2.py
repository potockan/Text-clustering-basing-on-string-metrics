# -*- coding: utf-8 -*-
"""
Created on Thu Nov 12 15:41:21 2015

@author: potockan
"""
import socket, pickle, numpy as np
import struct


HOST = ''
PORT = 50007
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind((HOST, PORT))
s.listen(2)

while 1:
    L = np.zeros((100, 43919))
    #wait to accept a connection - blocking call
    conn, addr = s.accept()
    print ('Connected with ', addr)
    buf = b''
    while len(buf) < 4:
        buf += conn.recv(4 - len(buf))

    length = struct.unpack('>I', buf)[0]
    print(length)
    data = b''
    l = length
    print('1')
    while l > 0:
        print('2')
        d = s.recv(l)
        print('3')
        l -= len(d)
        print('4')
        data += d
        print('y')
    if not data: break
    M = np.loads(data) # HERE IS AN ERROR
    L += M
    data_out = pickle.dumps(L)
    conn.sendall(data_out)
    conn.close() 
s.close()