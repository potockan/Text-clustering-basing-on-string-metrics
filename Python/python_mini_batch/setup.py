# -*- coding: utf-8 -*-
"""
Created on Thu Nov 12 10:03:11 2015

@author: natalia
"""

from distutils.core import setup
from Cython.Build import cythonize

setup(
  name = 'Kmeans functions',
  ext_modules = cythonize("kmeans_functions.py"),
)