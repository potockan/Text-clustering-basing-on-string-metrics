# -*- coding: utf-8 -*-
"""
Created on Fri Nov 27 18:36:51 2015

@author: natalia
"""


def czytanie_sciezki(utwor):
    '''
    Odczytuje sciezki, ktore maja byc grane 
    i zwraca je w postaci listy napisow.
    '''
    with open(utwor + '/song.txt', 'r') as f:
        song = f.read()
    
    tracks = []
    for i in song.splitlines():
        with open(utwor + '/track' + i +'.txt', 'r') as f:
               tracks += (f.read().splitlines())
                
    return tracks
    
    
def czytanie_probek(tracks):
    '''
    Z podanych sciezek sczytuje probki, ktore maja byc odtworzone. 
    Zwraca liste unikalnych posortowanych sampli
    '''
    sample = []
    for i in set(tracks):
        sample += i.split()
    sample = [i for i in list(set(sample)) if i != '--']
    sample.sort()
    return sample