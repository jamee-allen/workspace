# -*- coding: utf-8 -*-
"""
Created on Tue Apr 10 11:32:17 2018

@author: Jamee
"""

from __future__ import print_function
import keras
from keras.models import Sequential
from keras.layers import Dense, Dropout, Flatten
from keras.layers import Conv2D, MaxPooling2D
from keras import backend as K
from keras.preprocessing.image import ImageDataGenerator
import matplotlib.pyplot as plt
import numpy as np
from sklearn.metrics import confusion_matrix
from keras.models import load_model
import time


"""Set preliminary metrics """
img_height, img_width = 150, 150
batch_size = 50
epochs = 20
train_dir = 'subsetData/train'
val_dir = 'subsetData/validate'



"""Build the model """
class catDog:
    @staticmethod
    def build(height, width, channels, classes):
        model = Sequential()
        if K.image_data_format() == 'channels_first':
            inputshape = (channels, height, width)
        else:
            inputshape = (height, width, channels)
        model.add(Conv2D(32, (3, 3), activation = 'relu', input_shape = inputshape))
        model.add(MaxPooling2D(pool_size = (2, 2)))
        
        model.add(Conv2D(32, (3, 3), activation = 'relu'))
        model.add(MaxPooling2D(pool_size = (2, 2)))
        model.add(Dropout(0.25))
        
        model.add(Conv2D(64, (3, 3), activation = 'relu'))
        model.add(MaxPooling2D(pool_size = (2, 2)))
        model.add(Flatten())
        
        model.add(Dense(128, activation = 'relu'))
        model.add(Dropout(0.5))
        model.add(Dense(classes, activation = 'softmax'))
        return model
model = catDog.build(150, 150, 3, 2)
model.summary()

model.compile(loss=keras.losses.categorical_crossentropy, optimizer = 'rmsprop', 
              metrics = ['categorical_accuracy'])



""" Read in the pictures """
train_datagen = ImageDataGenerator(
        rescale=1./255,
        shear_range=0.2,
        zoom_range=0.2,
        horizontal_flip=True)
val_datagen = ImageDataGenerator(rescale = 1./255)

train_gen = train_datagen.flow_from_directory(
        train_dir,
        target_size=(img_height, img_width),
        batch_size=batch_size,
        class_mode='categorical')

val_gen = val_datagen.flow_from_directory(
        val_dir,
        target_size=(img_height, img_width),
        batch_size=batch_size,
        class_mode='categorical')

train_samp_size = train_gen.n
test_samp_size = val_gen.n


""" Fit the model to the training data """
starttime = time.time()
m = model.fit_generator(
        train_gen,
        steps_per_epoch = train_samp_size // batch_size,
        epochs = epochs,
        validation_data = val_gen,
        validation_steps = test_samp_size // batch_size,
        verbose = 1, shuffle = False)
totaltime = time.time() - starttime
#model.save_weights('second_try.h5')
#model.save('second_try_keras.h5')
#values = m.history


""" Evaluate the model """
model = load_model('second_try_keras.h5')
score = model.evaluate_generator(val_gen, test_samp_size/batch_size, pickle_safe = False)
scores = model.predict_generator(val_gen, pickle_safe=False)
 
y_true = val_gen.classes[:]
y_pred = [0] * len(scores)
for i in range(len(y_pred)):
    if scores[i][1] > 0.5:
        y_pred[i] = 1

cmx = confusion_matrix(y_true, y_pred)
tn, fp, fn, tp = confusion_matrix(y_true, y_pred).ravel()



""" Plot the model """
plt.style.use("ggplot")
plt.figure()
N = epochs
plt.plot(np.arange(0, N), m.history["loss"], label="train_loss")
plt.plot(np.arange(0, N), m.history["val_loss"], label="val_loss")
plt.plot(np.arange(0, N), m.history["acc"], label="train_acc")
plt.plot(np.arange(0, N), m.history["val_acc"], label="val_acc")
plt.title("Model 2")
plt.xlabel("Epoch #")
plt.ylabel("Loss/Accuracy")
plt.legend(loc="lower left")
plt.savefig('Model2Plot.png', bbox_inches='tight')




"""
Sources used:
    https://github.com/bradleypallen/keras-dogs-vs-cats/blob/master/keras-dogs-vs-cats.ipynb
    https://blog.keras.io/building-powerful-image-classification-models-using-very-little-data.html
    https://www.pyimagesearch.com/2017/12/11/image-classification-with-keras-and-deep-learning/
    https://www.kaggle.com/c/dogs-vs-cats/discussion

Data source:
    https://www.kaggle.com/c/dogs-vs-cats/data
"""