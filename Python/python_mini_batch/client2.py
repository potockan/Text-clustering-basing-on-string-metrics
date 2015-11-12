# -*- coding: utf-8 -*-
"""
Created on Thu Nov 12 15:39:00 2015

@author: potockan
"""

import numpy as np
import socket, pickle
import struct

HOST = "192.168.143.109"
PORT = 50007
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((HOST, PORT))
centers = np.zeros((100, 43919))
packet = pickle.dumps(centers)
length = struct.pack('>I', len(packet))
packet = length + packet
s.send(packet)

data = s.recv(8192)
data_new = pickle.loads(data)
s.close()
print ('Received', data_new)