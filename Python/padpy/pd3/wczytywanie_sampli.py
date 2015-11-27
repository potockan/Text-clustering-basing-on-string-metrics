# -*- coding: utf-8 -*-
"""
Created on Fri Nov 27 18:42:45 2015

@author: natalia
"""

import scipy.io.wavfile

def wczytywanie_probek(utwor, sample):
    '''
    Wczytuje i odpowiednio modyfikuje sample. 
    Zwraca liste fs i y.
    '''
    fs = []
    y = []
    for i, s in enumerate(sample):
        fs1, y1 = scipy.io.wavfile.read(utwor + '/sample' + s + '.wav')
        fs.append(fs1)
        y.append(y1)
        
    s = min([x.shape[0] for x in y])
    y = [x[:s] for x in y]
    
    return [fs[0], y, s]