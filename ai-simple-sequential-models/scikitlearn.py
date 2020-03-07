import numpy as np
from sklearn.datasets import load_iris
from sknn.mlp import Classifier, Layer
from sklearn import preprocessing
from sklearn.metrics import accuracy_score 
from sklearn.model_selection import train_test_split
from sklearn.model_selection import cross_val_score
from sklearn import model_selection
from sklearn import datasets

import warnings

'''
This code imports the iris dataset from scikit learn. The iris dataset is a multi-class
classification data that has 4 features, 3 classes, and 150 samples (50 per class). 
The code then splits the train and test data at an 80/20 split respectively and then scales 
and standardizes the predictor (x) variables. It implements the sklearn classifier and uses 
double hidden layers (Rectifier-Rectifier) each with 13 nodes to create a model.
After fitting the model to the data, it predicts y values for the test set data. A cross
validation score using 5 folds is stored and reported along with the accuracy score.
'''

'''
iris: A dataset from scikit learn. Dimensions: 150 x 4; Classes: 3. Uses sepal length, sepal
    width, petal length, and petal width to determine the type of iris.
X_train = 80% sample portion from iris' data. Dimensions: 120 x 4. Eventually 
    used to train the model.
X_test = 20% sample portion from iris' data. Dimensions: 30 x 4. Eventually used to 
    test the model.
y_train = 80% sample portion from iris' target. Dimension: array, 120. Used to train the model.
y_test = 20% sample portion from iris' target. Dimension: array, 30. Used to test the model.
X_trainn = X_train, except the values are scaled individually to the default unit form (pre.norm.) 
    and features are centered and standardized to unit variance individually (pre.scale).
    This variable is used directly to train the model.
X_testn = X_test, except the values are scaled individually to the default unit form (pre.norm.)
    and features are centered and standardized to unit variance individually (pre.scale).
    This variable is used directly to train the model.
clsfr = SGD classifier model that uses two hidden layers, each with 13 nodes, and uses softmax
    as the output layer (gives it a non-linear variant of multi-logistic regression). Used to
    predict y-values, both for train and test.
model1 = The fitted classifier model to the data.
y_hat = An array of the classifier's predicted values. Used to determine the accuracy of the
    classifier model by using the accuracy_score function.
scores = Cross-validation scores of the classifier. Dimensions: array, length = cv (5). Its
    average is used to determine the overall cross-validation accuracy score for the train data.
'''

#Ignore the deprecation warnings
warnings.simplefilter("ignore", category=DeprecationWarning)

#Import iris dataset from scikit learn, name the dataset 'iris'    
iris = datasets.load_iris()
#Split the data into 80/20 train and test sets with predictors and targets. Set random seed to 0
X_train, X_test, y_train, y_test = train_test_split(iris.data, iris.target, test_size=0.2, random_state=0)

#Scale the individual vectors in the training predictors to L2 norm
X_trainn = preprocessing.normalize(X_train, norm='l2')
#Scale the individual vectors in the test predictors to L2 norm
X_testn = preprocessing.normalize(X_test, norm='l2')

#Center and scale the training predictors to a standard distribution
X_trainn = preprocessing.scale(X_trainn)
#Center and scale the test predictors to a standard distribution
X_testn = preprocessing.scale(X_testn)

#Set the classifier equal to the variable name 'clsfr'
clsfr = Classifier(
    #Initiate input layer and begin specifying the following layers
	layers=[
    	#Create the first hidden layer using the Rectifier activation function and 13 nodes
        Layer("Rectifier", units=13),   
    	#Create the second hidden layer using the Rectifier activation function and 13 nodes
        Layer("Rectifier", units=13),   
    	#Create the output layer which uses softmax as its activation function; this gives it a non-linear variant of multi-logistic regression
        Layer("Softmax")],    	
        #Set learning rate to 0.001
        learning_rate=0.001, 
        #Use SGD solver
        learning_rule='sgd',
        #Set random seed to 201
        random_state=201,
	    #Tell the model to run the solver through 200 iterations
        n_iter=200)


#Fit the classifier model to the training data
model1=clsfr.fit(X_trainn, y_train)
#Create a variable the holds the classifier model's 30 predicted values
y_hat=clsfr.predict(X_testn)
#Store the training accuracy scores using 5-fold cross validation
scores = cross_val_score(clsfr, X_trainn, y_train, cv=5)
#Print the 5 scores
print scores
#Print the average of the 5 training scores
print 'train mean accuracy %s' % np.mean(scores)
#Print accuracy of test score
print 'vanilla sgd test %s' % accuracy_score(y_hat,y_test)