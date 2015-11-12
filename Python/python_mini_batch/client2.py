# -*- coding: utf-8 -*-
"""
Created on Thu Nov 12 15:39:00 2015

@author: potockan
"""

import numpy as np
import socket, pickle
import struct

HOST = "10.0.0.105"
PORT = 50007
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((HOST, PORT))
centers = np.zeros((100, 43919))
packet = pickle.dumps(centers)
length = struct.pack('>I', len(packet))
packet = length + packet
s.sendall(packet)

buf = b''
while len(buf) < 4:
   buf += s.recv(4 - len(buf))
        
length = struct.unpack('>I', buf)[0]
print(length)
data = b''
l = length
while l > 0:
    d = s.recv(l)
    l -= len(d)
    data += d
    print('y')
        
new_centers = np.loads(data)
s.close()
print ('Received', new_centers)
