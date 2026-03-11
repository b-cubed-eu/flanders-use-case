# -*- coding: utf-8 -*-
"""
Created on Mon Feb  9 09:51:36 2026

@author: jasmijn_hillaert
"""

from b3alien import b3cube
from b3alien import simulation
from b3alien import griis

import pandas as pd
import geopandas as gpd

import folium
from folium import Choropleth
from IPython.display import display

import matplotlib.pyplot as plt

from b3alien import utils
import os

print(os.getcwd())

utils.to_geoparquet("C:/Users/jasmijn_hillaert/Documents/GitHub/Flanders_use_case/_preprocessing/data/raw/data_IAS_target6.csv", 
                    "C:/Users/jasmijn_hillaert/Documents/GitHub/Flanders_use_case/_preprocessing/data/raw/EQDGC-Level-2.gpkg",
                    leftID='eqdcellcode',
                    rightID='cellCode', 
                    exportPath='C:/Users/jasmijn_hillaert/Documents/GitHub/Flanders_use_case/_preprocessing/data/interim/export.parquet')

