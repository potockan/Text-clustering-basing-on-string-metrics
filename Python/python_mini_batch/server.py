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
    #wait to accept a connection - blocking call
    conn, addr = s.accept()
    print ('Connected with ', addr)
    i += 1 
    #start new thread takes 1st argument as a function name to be run, second is the tuple of arguments to the function.
    #L = th.Thread(target = clientthread , args = (conn, L, )).start()
    buf = b''
    while len(buf) < 4:
        buf += conn.recv(4 - len(buf))
        
    length = struct.unpack('>I', buf)[0]
    print(length)
    data = conn.recv(length)
    if not data: break
        
    try:
        M = np.loads(data)
        print("udalo sie")
    except EOFError:
        print("nie udalo sie")
        M = np.zeros((100, 43919))
    print("lecimy dalej")
    L += M
    print("jeden")
    packet = pickle.dumps(L)
    length = struct.pack('>I', len(packet))
    packet = length + packet
    conn.sendall(packet)    
    conn.close()
 
s.close()


