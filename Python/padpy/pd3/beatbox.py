#!/usr/bin/python

"""
Created on Fri Nov 27 18:49:20 2015

@author: natalia
"""

import scipy.io.wavfile
import os
import numpy as np
import librosa
import IPython
import time, wave, pymedia.audio.sound as sound


import odczyt_sciezki as ods
import wczytywanie_sampli as ws
import zapis_nutek as zn

print(os.getcwd())

utwor = "./utwor1"
tracks = ods.czytanie_sciezki(utwor)
sample = ods.czytanie_probek(tracks)
ll = ws.wczytywanie_probek(utwor, sample)
y2 = zn.co_po_czym(tracks, sample, ll[1], ll[2])

plik_audio = utwor + "pd_proba1.wav"

scipy.io.wavfile.write(plik_audio, 
                       ll[0], 
                       np.int16(y2/max(np.abs(y2))*32767))


import pyaudio
import wave

chunk = 1024
wf = wave.open(plik_audio, 'rb')
p = pyaudio.PyAudio()

stream = p.open(
    format = p.get_format_from_width(wf.getsampwidth()),
    channels = wf.getnchannels(),
    rate = wf.getframerate(),
    output = True)
data = wf.readframes(chunk)

while data != '':
    stream.write(data)
    data = wf.readframes(chunk)

stream.close()
p.terminate()

os.remove(plik_audio)