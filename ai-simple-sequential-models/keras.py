from __future__ import print_function
import keras
from keras.datasets import mnist
from keras.models import Sequential
from keras.layers import Dense, Dropout, Flatten
from keras.layers import Conv2D, MaxPooling2D
from keras import backend as K

'''
This code uses Keras mnist and builds a sequential model. It first creates the batch size,
number of classes, and epochs that will be used in the model. It specifies the dimensions for
the images, which is 28 x 28. It then imports the mnist data.x_train and x_test will be 
imported as an array of grayscale image data in the shape of number_samples, 28, 28. 
y_train and y_test will be imported asan array of digits 0-9 in the shape of number_samples.
An if/else statement is used to determine whether the Keras backend data format convention is in
either channels_first or channels_last format; it is important to know this order because it will
be passed into the sequential model in the order that is specified. It creates the input shape 
that reflects whether the channel is before or after the rows/columns. 
x_train and x_test areconverted from unit8 arrays into float32 variables so we can do 
mathematical calculations on them. The calculation is to divide each value by 255 to standardize
the data to produce values of 1 and 0 since some of the values were 255. Print the shape of
x_test and x_train samples to check if the dimensions are right, and to see how many samples
are in each of the test and train sets.
Convert y_train and x_train class vectors to binary class matrices, in the shape of 
number_samples x num_classes. 
Create the sequential model and add the first 2D convolutional layer that will produce that
has a 32 dimensionality output and has the relu activation function and use the input shape
created earlier. Add another 2D convolutional layer, this time with a 64 dimensionality output
and that also uses the relu activation function. We don't need to put in the input shape here
because the model only needs it for the first layer. Use maxpooling operation for spatial data, 
halve the input (by placing 2,2) in both vertical and horizontal spatial dimensions. Apply a 
dropout rate of 0.25 to avoid overfitting. Flatten the input without affecting batch size with
the flatten() function. Add core layers of a regular densely-connected NN that has dimensionality
of output space of 128, and uses the relu activation function.
Apply a dropout rate of 0.5 that will drop 0.5 of the input values for the output layer. Add
a densely-connected output NN that has dimensionality of num_classes and uses the softmax
activation function which gives it a non-linear variant of multi-logistic regression.
Before training the model, the compile() function is used to configure the learning process. It 
receives three arguments: loss, optimizer, and metrics. The model will use the categorical
crossentropy loss. The model will use the Adadelta optimizer, a per-dimension learning rate
method for gradient descent. Accuracy was used for the metric because it is used for any
classification problem.
Lastly fit the model to the training data and produce a score that evaluates how well the
sequential model did at predicting the test variables. Print the loss and accuracy.
'''

'''
batch_size = The number of samples that will be propogated through the NN. Used in model fitting
    to batch by the specified number. In this case, each batch of of 128 samples will update
    the model once.
num_classes = Used to convert y variables into a n(rows) x 10 column matrix.
epochs = This is a cutoff set at 12, which is used to seperate training into phases, which is 
    useful for logging and evaluation of the training phase.
img_rows, img_cols = The image dimensions we would like to use for the data. 
x_train = Training data of type float32. Dimensions: 60000, 28, 28, 1 and contains integers
    0 and 1. Used to train the sequential model.
y_train = Training response variables of type float64. Dimensions: 60000, 10 matrix. Used to
    train the sequential model.
x_test = Testing data of type float32. Dimensions: 10000, 28, 28, 1 and contains integers 0 and 1.
    Used to test the sequential model's predictive ability.
y_test = Testing reponse variables of type float64. Dimensions: 10000, 10 matrix. Used to 
    test the sequential model's predictive ability.
input_shape = Reflects the channels_last convention, a tuple of 3 integers that will be passed into 
    the sequential model. Used in building the first convolutional layer of the sequential model.
model = Sequential model with two convolutional layers, both that are densely connected. The input
    is flattened and both horizontal and vertical spatial parameters are halved. Uses crossentropy
    for loss, Adadelta for optimizer, and accuracy for metric. This is used to predict test
    values.
score = A score that evaluates how well the sequential model did at predicting the test data
'''

#Create batch size of 128. Default is 32
batch_size = 50
#Create the number of classes
num_classes = 10
#Create number of epochs to train the data
epochs = 12

#Set image dimensions to 28 x 28
img_rows, img_cols = 28, 28

#Import train and test data from mnist
(x_train, y_train), (x_test, y_test) = mnist.load_data()

#Set up an if statement that asks if the backend data format convention is in channels_first format
if K.image_data_format() == 'channels_first':
    #If format convention is channels_first, add the channel before rows and columns in x_train
    x_train = x_train.reshape(x_train.shape[0], 1, img_rows, img_cols)
    #If format convention is channels_first, add the channel before rows and columns in x_test
    x_test = x_test.reshape(x_test.shape[0], 1, img_rows, img_cols)
    #Create the input_shape variable that reflects the channels_first convention, a tuple that will be passed into the sequential model
    input_shape = (1, img_rows, img_cols)
#Otherwise the backend data format convention is in cannels_last format
else:
    #If format convention is channels_last, add the channel after rows and columns in x_train
    x_train = x_train.reshape(x_train.shape[0], img_rows, img_cols, 1)
    #If format convention is channels_last, add the channel after rows and columns in x_test
    x_test = x_test.reshape(x_test.shape[0], img_rows, img_cols, 1)
    #Create the input_shape variable that reflects the channels_last convention, a tuple that will be passed into the sequential model
    input_shape = (img_rows, img_cols, 1)

#Convert x_train from a unit8 array to float32 type
x_train = x_train.astype('float32')
#Convert x_test from a unit8 array to float32 type
x_test = x_test.astype('float32')
#Standardize the data
x_train /= 255
#Standardize the data
x_test /= 255
#Print the shape of x_train
print('x_train shape:', x_train.shape)
#Print the shape of x_train samples
print(x_train.shape[0], 'train samples')
#Print the shape of x_test samples
print(x_test.shape[0], 'test samples')

#Convert y_train class vectors to binary class matrices, shaped number_samples, num_classes
y_train = keras.utils.to_categorical(y_train, num_classes)
#Convert y_test class vectors to binary class matrices, shaped number_samples, num_classes
y_test = keras.utils.to_categorical(y_test, num_classes)

#Create the sequential model
model = Sequential()
#Add 2d convolutional layer with dimensionality of 32, using kernel size 3x3
model.add(Conv2D(32, kernel_size=(3, 3),
                 #Set activation function to relu
                 activation='relu',
                 #Specify to the first layer of the sequential model which input_shape will be used
                 input_shape=input_shape))
#Add 2d convolutional layer with dimensionality of 64 for output space, kernel size of 3x3, and uses the relu activation function
model.add(Conv2D(64, (3, 3), activation='relu'))
#Use maxpooling operation for spatial data, halve the input in both vertical and horizontal spatial dimensions
model.add(MaxPooling2D(pool_size=(2, 2)))
#Apply dropout rate that drops 0.25 of the input units
model.add(Dropout(0.25))
#Flatten the input
model.add(Flatten())
#Add core layers of a regular densely-connected NN that has dimensionality of output space of 128, and uses the relu activation function
model.add(Dense(128, activation='relu'))
#Apply dropout rate that drops 0.5 of the input units
model.add(Dropout(0.5))
#Add a densely-connected output NN with dimensionality of num_classes and uses softmax for the activation funcation
model.add(Dense(num_classes, activation='softmax'))

#Configure the learning process by using the compile() function
#The first pass into the compile function is the loss function, which uses categorical crossentropy
model.compile(loss=keras.losses.categorical_crossentropy,
              #Establish the Adadelta optimizer, using all default values
              optimizer=keras.optimizers.Adadelta(),
              #Set the metric to be assessed - accuracy is used because this is a classification problem
              metrics=['accuracy'])

#Fit the model to the training data using the established batch size and outputs number of epochs
model.fit(x_train, y_train, batch_size=batch_size, epochs=epochs,
          #Verbose is used to produce detailed logging information, validation data is the test data
          verbose=1, validation_data=(x_test, y_test))
#Produce a score that evaluates how well the sequential model did at predicting the test data
score = model.evaluate(x_test, y_test, verbose=0)
#Print the test loss
print('Test loss:', score[0])
#Print the test accuracy
print('Test accuracy:', score[1])