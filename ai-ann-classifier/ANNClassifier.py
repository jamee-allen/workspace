# -*- coding: utf-8 -*-
"""
Created on Wed Mar 14 11:49:00 2018

@author: Jamee
"""

import matplotlib.pyplot as plt
from sklearn.neural_network import MLPClassifier
import time
from sklearn.metrics import confusion_matrix as cmx
from sklearn import preprocessing
from sklearn.model_selection import train_test_split
import pandas as pd
import numpy as np
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Load Data Section
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
wines =    pd.DataFrame.from_csv('C:\Users\Jamee\Google Drive\B School\Artificial Intelligence\Homework\Assignment 2\whitewines.csv', index_col=None)
wines =    wines.dropna()
x, y =     wines[wines.columns[0:11]], pd.cut(wines[wines.columns[11]], 3, labels = False)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Pretreat Data Section
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
x_MinMax = preprocessing.MinMaxScaler()
x =        x_MinMax.fit_transform(x)

x = np.array(x).reshape((len(x), 11))
y = np.array(y).reshape((len(y), 1))

x_train, x_test, y_train, y_test = train_test_split(x,y,test_size=0.2, random_state=2016)

x_test.mean(axis=0)
y_test.mean(axis=0)
x_train.mean(axis=0)
y_train.mean(axis=0)

#shuffle_index = np.random.permutation(60000)
#x_train, y_train = x_train[shuffle_index], y_train[shuffle_index]
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Define Model Section
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
solv = ("adam", "lbfgs")
hl = (10, 20, 30, 50)
activator = ['identity', 'logistic', 'tanh', 'relu']

test_scores = []
for i in solv:
    for j in hl:
        for k in activator:
#            for l in hl:
            mlp = MLPClassifier(hidden_layer_sizes=(j,), max_iter=100, activation = k,
                            solver= i, verbose=False, random_state=1,
                            learning_rate_init=.9)
            mlp.fit(x_train, y_train)
            print "\nTest set score: %f" % mlp.score(x_test, y_test), i, j, k
            test_scores.append([mlp.score(x_test, y_test), i, j, k])
test_scores.sort(reverse=True)
print "\nMy best classifier model is:", test_scores[0]
# default solver is adam; verbose gives error rates and can be 0 but you won't see errors; 
# tolerance looks at error from iteration to iteration -- if our error decreases less than 
# tolerance, then the algorithm stops). Otherwise it goes to the max_iter and stops.
#start_time = time.time()
"""
[[0.5469387755102041, 'lbfgs', 30, 15, 10],
 [0.5448979591836735, 'lbfgs', 30, 30, 30],
 [0.5418367346938775, 'lbfgs', 30, 10, 10],
 """

"""
best so far is:
(hidden_layer_sizes=(j,), max_iter=700,
                            solver= i, verbose=False, tol= 1e-4, random_state=1,
                            learning_rate_init=.1)
lbfgs .552041
    
"""    
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Show output Section
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#print "Training set score: %f" % mlp.score(x_train, y_train)
print "Test set score: %f" % mlp.score(x_test, y_test)
y_pred = mlp.predict(x_test)
print cmx(y_test, y_pred)
#print "Elapsed time = ", time.time()-start_time



"""
fig, axes = plt.subplots(4, 4)
vmin, vmax = mlp.coefs_[0].min(), mlp.coefs_[0].max() #List of coefficients
for coef, ax in zip(mlp.coefs_[0].T, axes.ravel()):
    ax.matshow(coef.reshape(1, 11), cmap=plt.cm.gray, vmin=.5*vmin, vmax=.5*vmax)
    ax.set_xticks(())
    ax.set_yticks(())
    
plt.show
"""