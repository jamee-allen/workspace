rm(list=ls())

installIfAbsentAndLoad  <-  function(neededVector) {
  if(length(neededVector) > 0) {
    for(thispackage in neededVector) {
      if(! require(thispackage, character.only = T)) {
        install.packages(thispackage)}
      require(thispackage, character.only = T)
    }
  }
}

needed <- c('e1071', 'ISLR', 'boot', 'MASS', 'splines')      
installIfAbsentAndLoad(needed)


#####################
#### Section I ######
#####################

#### Part a #########
set.seed(5082)
n = dim(OJ)[1]
train_inds = sample(1:n,800)
test_inds = (1:n)[-train_inds]


#### Part b #########
svmfit <- svm(OJ$Purchase[train_inds] ~ ., data= OJ[train_inds,], kernel="linear", 
          cost=0.01, scale=TRUE)
summary(svmfit)
# The results here are telling me that there are 446 support vectors, 223 in each class.
# Additionally, this summary shows that we used a linear kernel and a cost of 0.01.


#### Part c #########
trainpred <- predict(svmfit, OJ[train_inds,])
testpred <- predict(svmfit, OJ[test_inds,])
cat("The training error rate is ", mean(trainpred != OJ$Purchase[train_inds]))
cat("The test error rate is ", mean(testpred != OJ$Purchase[test_inds]))


#### Part d #########
tune.out <- tune(svm, as.factor(Purchase) ~ ., data = OJ[train_inds,], kernel="linear", 
            ranges=list(cost=c(0.01, 0.1, 1,5, 10)))
bestmod <- tune.out$best.model


#### Part e #########
best.trainpred <- predict(bestmod, OJ[train_inds,])
best.testpred <- predict(bestmod, OJ[test_inds,])
cat("The best model training error rate is ", mean(best.trainpred != OJ$Purchase[train_inds]), "using a cost of", bestmod$cost)
cat("The best model test error rate is ", mean(best.testpred != OJ$Purchase[test_inds]),  "using a cost of", bestmod$cost)


#### Part f #########
svmfit <- svm(as.factor(OJ$Purchase[train_inds]) ~ ., data= OJ[train_inds,], 
          kernel="radial", cost=0.01, scale=TRUE)
summary(svmfit)
# This summary statistic displays that there are 613 support vectors, 308 in the "CH" 
# class and 305 in the "MM" class which is more than when the kernel was linear. It also 
# shows that we are using a radial kernel with a cost of 0.01.

trainpred <- predict(svmfit, OJ[train_inds,])
testpred <- predict(svmfit, OJ[test_inds,])
cat("The training error rate is ", mean(trainpred != OJ$Purchase[train_inds]))
cat("The test error rate is ", mean(testpred != OJ$Purchase[test_inds]))

tune.out <- tune(svm, as.factor(Purchase) ~ ., data=OJ[train_inds,], kernel="radial", 
            ranges=list(cost=c(0.01, 0.1, 1,5, 10)))
bestmod <- tune.out$best.model

best.trainpred <- predict(bestmod, OJ[train_inds,])
best.testpred <- predict(bestmod, OJ[test_inds,])
cat("The best model training error rate is ", mean(best.trainpred != OJ$Purchase[train_inds]),  "using a cost of", bestmod$cost)
cat("The best model test error rate is ", mean(best.testpred != OJ$Purchase[test_inds]),  "using a cost of", bestmod$cost)


#### Part g #########
svmfit <- svm(OJ$Purchase[train_inds] ~ ., data= OJ[train_inds,], 
          kernel="polynomial", degree=2, cost=0.01, scale=TRUE)
summary(svmfit)
# This summary statistic displays that there are 614 support vectors, 309 in "CH" class
# and 305 in the "MM" class. It also shows that a cost of 0.01 was used, and a polynomial
# kernel with a degree of 2 was used to fit the training data.

trainpred <- predict(svmfit, OJ[train_inds,])
testpred <- predict(svmfit, OJ[test_inds,])
cat("The training error rate is ", mean(trainpred != OJ$Purchase[train_inds]))
cat("The test error rate is ", mean(testpred != OJ$Purchase[test_inds]))

tune.out <- tune(svm, as.factor(Purchase) ~ ., data=OJ[train_inds,], kernel="polynomial", 
            degree=2, ranges=list(cost=c(0.01, 0.1, 1,5, 10)))
bestmod <- tune.out$best.model

best.trainpred <- predict(bestmod, OJ[train_inds,])
best.testpred <- predict(bestmod, OJ[test_inds,])
cat("The best model training error rate is ", mean(best.trainpred != OJ$Purchase[train_inds]),  "using a cost of", bestmod$cost)
cat("The best model test error rate is ", mean(best.testpred != OJ$Purchase[test_inds]),  "using a cost of", bestmod$cost)


#### Part h #########
# Overall, the SVM model using a radial kernel gave the best results (post-tuning).
# The radial model is advantageous primarily because it gives the best error parameters.
# Additionally, it is more advantageous in comparison to the other two models since its 
# optimal cost is 1. I think this is a cost that is perfectly balanced between bias and
# variance, so it won't be as prone to following noise (cost of .01) nor will it be
# greatly influenced by bias (cost of 10).



#####################
#### Section II #####
#####################

#### Part b #########
set.seed(5082)
errors <- rep(NA, 10)
for (i in 1:10) {
  glmfit <- glm(wage ~ poly(age,i), data = Wage)
  errors[i] <- cv.glm(Wage, glmfit, K = 10)$delta[1]
}
bestdegree <- which.min(errors)


#### Part c #########
plot(1:10, errors, xlab = "Degree", ylab = "Error", type = "l")
points(which.min(errors), errors[which.min(errors)], col = "red", cex = 2, pch = 16)
#A polynomial of 9 was chosen


#### Part d #########
agelims=range(Wage$age)
age.grid=seq(from=agelims[1],to=agelims[2], length.out = 100)
fit = glm(wage ~ poly(age, bestdegree), data = Wage)
preds=predict(fit,newdata=list(age=age.grid),se=TRUE)

plot(Wage$age,Wage$wage,xlim=agelims,cex=.5,col="black")
title("Polynomial Fit with Degree 9 Chosen by C.V.",outer=T)
lines(age.grid,preds$fit,lwd=2,col="red")


#### Part e #########
set.seed(5082)

cv.error <- rep(NA, 11)
for (i in 2:12) {
  Wage$age.cut <- cut(Wage$age, i) 
  glmfit <- glm(wage ~ age.cut, data = Wage)
  cv.error[i] <- cv.glm(Wage, glmfit, K = 10)$delta[1]
}
minimum.cuts <- which.min(cv.error)


#### Part f #########
plot(2:12, cv.error[-1], xlab = "Number of Intervals", ylab = "Error", type = "l")
points(which.min(cv.error), cv.error[which.min(cv.error)], col = "red", cex = 2, pch = 16)
# The optimum number of cuts is 7, which would be 8 intervals


#### Part f #########
agelims=range(Wage$age)
age.grid=seq(from=agelims[1],to=agelims[2])
fit <- glm(wage ~ cut(age, minimum.cuts), data = Wage)
preds <- predict(fit, list(age = age.grid))
plot(wage ~ age, data = Wage, col = "black")
title("Step Function Using Number of Cuts (7) Chosen with C.V.")
lines(age.grid, preds, col = "red", lwd = 2)



#####################
#### Section III ####
#####################

#### Part a #########
disrange <- range( Boston$dis ) 
dissamples <- seq(from=disrange[1], to=disrange[2], length.out=100)


#### Part b #########
errors <- matrix(ncol = 2, dimnames = list(NULL, c('Polynomial', 'Training Error')))
plot(nox ~ dis, data = Boston, col = "black"); title("Polynomial Fit with Various Degrees of Freedom")
for (i in 1:10) {
  glmfit <- glm(nox ~ poly(dis,i), data = Boston)
  cv.error <- cv.glm(Boston, glmfit, K = 10)$delta[1]
  errors <- rbind(errors, c(i, cv.error))
  preds <- predict(glmfit, list(dis = dissamples))
  lines(dissamples, preds, col = i)
}
legend("topright", legend = c("Degree 1", "Degree 2", "Degree 3", "Degree 4", 
                              "Degree 5", "Degree 6", "Degree 7", "Degree 8", 
                              "Degree 9", "Degree 10"), lty = 1, col = 1:10)
errors = errors[-1,]

bestdegree <- which.min(errors[,2])
glmfit <- glm(nox ~ poly(dis, bestdegree), data = Boston)
plot(nox ~ dis, data = Boston); title("Polynomial Fit with min CV  Error at Polynomial 3")
preds <- predict(glmfit, list(dis = dissamples))
lines(dissamples, preds, col = "red", lwd=2)


#### Part c ########
spline.fit = lm(nox ~ bs(dis, df = 4), data = Boston)
summary(spline.fit)
# i. It chooses knots by evenly distributing them across the data.

attr(bs(Boston$dis, df=4), 'knots')
# ii. It chose to place one knot at 3.207 which corresponds to the 50th percentile of dis.

spline.pred = predict(spline.fit, list(dis = dissamples))
plot(nox ~ dis, data = Boston); title("Regression Spline with df=4")
lines(dissamples, spline.pred, col = "red", lwd=2)


#### Part d ########
spline.errors <- matrix(ncol = 2, dimnames = list(NULL, c('Degree of Freedom', 'Training Error')))
plot(nox ~ dis, data = Boston, col = "black"); title("Regression Splines with Various Degrees of Freedom")
for (i in 3:10) {
  spline.fit <- glm(nox ~ bs(dis, df=i), data = Boston)
  cv.error <- cv.glm(Boston, spline.fit, K = 10)$delta[1]
  spline.errors <- rbind(spline.errors, c(i, cv.error))
  preds <- predict(spline.fit, list(dis = dissamples))
  lines(dissamples, preds, col = i)
}
legend("topright", legend = c("Df 3", "Df 4", "Df 5", "Df 6", "Df 7", 
                              "Df 8", "Df 9", "Df 10"), lty = 1, col = 3:10)
spline.errors = spline.errors[-1,]


#### Part e ########
set.seed(5082)
cv.errors <- c()
for (i in 3:10) {
  spline.fit <- glm(nox ~ bs(dis, df=i), data = Boston)
  cv.errors[i] <- cv.glm(Boston, spline.fit, K = 10)$delta[1]
}
bestdf = which.min(cv.errors)
spline.fit <- glm(nox ~ bs(dis, df=bestdf), data = Boston)
plot(nox ~ dis, data = Boston); title("Regression Spline with Best d.f. (10) Chosen with C.V.")
preds <- predict(spline.fit, list(dis = dissamples))
lines(dissamples, preds, col = "red", lwd=2)


#### Part f ########
fit = smooth.spline(jitter(Boston$dis), Boston$nox, cv=TRUE) 
fit$lambda
plot(nox ~ dis, data = Boston); title("Smoothing Spline with Best Lambda (6.9e-05 chosen with CV")
lines(fit, col = "red", lwd=2)