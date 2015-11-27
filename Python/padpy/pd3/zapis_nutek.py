# -*- coding: utf-8 -*-
"""
Created on Fri Nov 27 18:46:44 2015

@author: natalia
"""

import numpy as np


def co_po_czym(tracks, sample, y, s):
    '''
    Zapisuje kolejnosc odtwarzanych dzwiekow.
    Zwraca y taki juz do zapisu.
    '''
    y2 = np.zeros(1)
    for a,i in enumerate(tracks):
        idx = {x for x in set(i.split()) if x != '--'}
        if idx:
            #idx
            kk = []
            for j in idx:
                kk.append(sample.index(j))
            y3 = np.zeros(1)
            for x in kk:
                y3 = np.r_[y3 + np.tile(y[x], 2)]
            if a == 0:
                y2 = y3.copy()
            y2 = np.r_[y2,y3]
        else:
            y2 = np.r_[y2,np.zeros((s, 4))]
        
        y2 = np.mean(y2, axis=1)
        y2 /= 32767
            
        return y2