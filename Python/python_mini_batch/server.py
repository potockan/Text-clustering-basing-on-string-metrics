# -*- coding: utf-8 -*-
"""
Created on Thu Nov 12 12:29:30 2015

@author: potockan
"""

import socket, pickle, sys, threading as th, numpy as np
import struct





def clientthread(conn, L):
    #Sending message to connected client
    #conn.send('Welcome to the server. Type something and hit enter\n') #send only takes string
     
    #infinite loop so that function do not terminate and thread do not end.
    while True:
         
        #Receiving from client
        buf = b''
        while len(buf) < 4:
            buf += conn.recv(4 - len(buf))
        
        length = struct.unpack('!I', buf)[0]
        print(length)
        data = conn.recv(length)
        if not data: break
        
        M = pickle.loads(data)
        L += M
        data_out = pickle.dumps(L)
        conn.sendall(data_out)
     
    #came out of loop
    conn.close()
    return(L)



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
while i < 2:
    L = np.zeros((100, 43919))
    i += 1
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
 
 
 
 