# -*- coding: utf-8 -*-
"""
Created on Mon Aug 31 19:48:40 2015

@author: natalia
"""


#################
# Echo client program
import socket

HOST = "192.168.0.11"
PORT = 50007
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((HOST, PORT))
s.sendall(str([1,2,3,3]))
data = s.recv(1024)
s.close()
print 'Received', repr(data)
#################

#################
# Echo server program
import socket

HOST = ''                 # Symbolic name meaning all available interfaces
PORT = 50007              # Arbitrary non-privileged port
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind((HOST, PORT))
s.listen(1)
conn, addr = s.accept()
print 'Connected by', addr
while 1:
    data = conn.recv(1024)
    if not data: break
    conn.sendall(data)
conn.close()
#################

####################################################################
########################### improvements ###########################
####################################################################


#################
# Echo client program
import socket, pickle, numpy as np

HOST = "192.168.0.11"
PORT = 50007
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((HOST, PORT))
arr = np.array([[1, 2], [3, 4]])
data_string = pickle.dumps(arr)
s.send(data_string)

data = s.recv(4096)
data_arr = pickle.loads(data)
s.close()
print 'Received', repr(data_arr)


#################
# Echo server program
import socket, pickle, numpy as np

HOST = ''
PORT = 50007
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind((HOST, PORT))
s.listen(1)
conn, addr = s.accept()
print 'Connected by', addr
while 1:
    data = conn.recv(4096)
    if not data: break
    L = pickle.loads(data)
    L = np.vstack((L, np.array([[5,6]])))
    data_out = pickle.dumps(L)
    conn.send(data_out)
conn.close()
s.close()