#!/home/npotocka/anaconda3/bin/python3

"""
Created on Fri Nov 27 18:49:20 2015

@author: natalia
"""

import scipy.io.wavfile
import os
import numpy as np
import pyglet



import odczyt_sciezki as ods
import wczytywanie_sampli as ws
import zapis_nutek as zn

print(os.getcwd())

utwor = os.getcwd() + "/utwor1"
tracks = ods.czytanie_sciezki(utwor)
sample = ods.czytanie_probek(tracks)
ll = ws.wczytywanie_probek(utwor, sample)
y2 = zn.co_po_czym(tracks, sample, ll[1], ll[2])

plik_audio = utwor + "/pd_proba1.wav"
print(plik_audio)

scipy.io.wavfile.write(plik_audio, 
                       ll[0], 
                       np.int16(y2/max(np.abs(y2))*32767))


audio = pyglet.resource.media(plik_audio, streaming = False)

audio.play()
#pyglet.app.run()

#os.remove(plik_audio)