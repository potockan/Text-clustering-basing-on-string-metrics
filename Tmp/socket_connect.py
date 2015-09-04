# -*- coding: utf-8 -*-
"""
Created on Mon Aug 31 19:48:40 2015

@author: natalia
"""

import socket

s = socket.socket()
HOST = "10.0.0.107"
PORT = 22
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

import socket
import select
import sys
import time
while(1) :
    s,addr=server1.accept()    
    data=int(s.recv(4))
    s = socket.socket()
    s.connect((host,port))
    while (1):
        f=open ("aa.txt", "rb")
        l = f.read(1024)
        s.send(l)
        l = f.read(1024)
        time.sleep(5)
s.close()