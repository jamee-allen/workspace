# -*- coding: utf-8 -*-
"""
Created on Mon Mar 12 11:58:54 2018

@author: Jamee
"""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Import Libraries Section
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
from sklearn import datasets
from sklearn import preprocessing
import numpy as np
from sklearn.model_selection import train_test_split
from sknn.mlp import Regressor, Layer
from sklearn.metrics import mean_squared_error
import time
import pandas as pd

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Load Data Section
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
wines =    pd.DataFrame.from_csv('C:\Users\Jamee\Google Drive\B School\Artificial Intelligence\Homework\Assignment 2\whitewines.csv', index_col=None)
wines =    wines.dropna()
x, y =     wines[wines.columns[0:11]],wines[wines.columns[11]]
#f = open('testfile.csv', 'w')

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Pretreat Data Section
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
x_MinMax = preprocessing.MinMaxScaler()
y_MinMax = preprocessing.MinMaxScaler()
y =        np.array(y).reshape((len(y),1))
x =        x_MinMax.fit_transform(x)
y =        y_MinMax.fit_transform(y)

np.random.seed(2018)
x_train, x_test, y_train, y_test = train_test_split(x,y,test_size=0.2)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Define Model Section
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
s_time =   time.time()

list1 =    ["Rectifier", "Sigmoid", "Tanh", "ExpLin"]

node1 =    [6, 11, 22, 30]

mse_list=  []
for activator in list1:
    for node in node1:
        winefit = Regressor(
                layers=[
                        Layer(activator, units=node),
                        #Layer(activator2, units=14),
                        Layer("Linear")], #output layer
                        learning_rate = 0.02,
                        random_state = 2018,
                        n_iter = 100)                    
        #print "\nfitting model now", activator, activator2
        winefit.fit(x_train, y_train)
        #pred3 =  winefit.predict(x_train)
        #mse_3 =  mean_squared_error(y_pred = pred3, y_true = y_train)
        #print "Train ERROR = " , mse_3
                    
        pred_test1 = winefit.predict(x_test)
        mse_test1 = mean_squared_error(pred_test1, y_test)
        #print "Test ERROR = ", mse_test1
        print activator, node, mse_test1
        mse_list.append([activator, node, mse_test1])

mse_list.sort(key=lambda x: x[2]); best_value = mse_list[0]
print "\nThe best model is", best_value

"""
mse_list2 = []
for node_1 in node1:
    for node_2 in node2:
        winefit2 = Regressor(
            layers=[
                    Layer(act1, units=node_1),
                    Layer(act2, units=node_2),
                    Layer("Linear")],
                    learning_rate = 0.02,
                    random_state = 2018,
                    n_iter = 100)
        winefit2.fit(x_train, y_train)
        #pred3 = winefit2.predict(x_train)
        #mse_3 = mean_squared_error(y_pred = pred3, y_true = y_train)
        pred_test2 = winefit2.predict(x_test)
        mse_test2 = mean_squared_error(pred_test2, y_test)
        print node_1, node_2, mse_test2
        mse_list2.append([act1, act2, node_1, node_2, mse_test2])
#Explin with 8 nodes and Rectifier with 8 nodes yields the best MSE of 0.01424
mse_list2.sort(key=lambda x: x[4]); best_value2 = mse_list[0]
print "\nThe best updated model is", best_value2

e_time = time.time()
print("Run time = ", e_time-s_time)
"""