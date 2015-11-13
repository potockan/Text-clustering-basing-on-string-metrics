# -*- coding: utf-8 -*-
"""
Created on Thu Nov 12 15:39:00 2015

@author: potockan
"""

import numpy as np
import socket, pickle
import struct
from time import time
#
#HOST = "10.0.0.105"
#PORT = 50007
#s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
#s.connect((HOST, PORT))
#centers = np.zeros((100, 43919))
#packet = pickle.dumps(centers)
#length = struct.pack('>I', len(packet))
#packet = length + packet
#t0 = time()
#s.sendall(packet)
#print("done in %fs" % (time() - t0))
#
#
#
#buf = b''
#while len(buf) < 4:
#   buf += s.recv(4 - len(buf))
#        
#length = struct.unpack('>I', buf)[0]
#print(length)
#data = b''
#l = length
#t0 = time()
#while l > 0:
#    d = s.recv(l)
#    l -= len(d)
#    data += d
#print("done in %fs" % (time() - t0))      
#new_centers = np.loads(data)
#s.close()
#print ('Received', new_centers)
#




HOST = "10.0.0.105"
PORT = 50007
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((HOST, PORT))
centers = np.zeros((100, 43919))
packet = pickle.dumps(centers)
length = struct.pack('>I', len(packet))
packet = length + packet
t0 = time()
s.sendall(packet)
print("done in %fs" % (time() - t0))
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


while 1:
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
    while l > 0:
        d = conn.recv(l)
        l -= len(d)
        data += d
        print('y')
    if not data: break
        
    new_centers = np.loads(data)
    conn.close()
 
s.close()

