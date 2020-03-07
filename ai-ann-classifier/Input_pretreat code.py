
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Import Libraries Section
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
import numpy as np
from sklearn import datasets, linear_model
import pandas as pd
from pandas import DataFrame, Series
import random
from sklearn import preprocessing
import time
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Load Data Section
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#"https://archive.ics.uci.edu/ml/machine-learning-databases/wine-quality/winequality-white.csv"
data = pd.read_csv("C:\Users\Jamee\Google Drive\B School\Artificial Intelligence\Homework\Assignment 2\whitewines.csv",
                                      names = ['f_acidity', 'v_acidity', 'citric Acid', 'r_sugar', 'chlorides', 'free_so2',
                          'total_so2', 'density', 'pH', 'sulphates', 'alcohol', 'quality'])
print(data.shape)
data = data.dropna()
print (data.head())
x_vars = ['f_acidity', 'v_acidity', 'citric Acid', 'r_sugar', 'chlorides', 'free_so2',
                            'total_so2', 'density', 'pH', 'sulphates', 'alcohol']
y_vars = ['quality']
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Pretreat Data Section
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
x_data = data[x_vars]
y_data = data[y_vars]

np.random.seed(2016)

print (len(x_data))
print (len(y_data))

x_data_MinMax = preprocessing.MinMaxScaler()
#y_data_MinMax = preprocessing.MinMaxScaler()

x_data.as_matrix(x_data)
x_data = np.array(x_data).reshape((len(x_data), 11))

y_data.as_matrix(y_data)
y_data = np.array(y_data).reshape((len(y_data), 1))

x_data = x_data_MinMax.fit_transform(x_data)
#y_data = y_data_MinMax.fit_transform(y_data)

x_train, x_test, y_train, y_test = train_test_split(x_data, y_data, test_size=0.33, random_state=2016)

x_test.mean(axis=0)
y_test.mean(axis=0)
x_train.mean(axis=0)
y_train.mean(axis=0)
#print (y_train)