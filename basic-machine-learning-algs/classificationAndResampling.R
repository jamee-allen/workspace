rm(list=ls())
require(ISLR)
require(class)
require(FNN)
require(MASS)
require(boot)
##################### 
#### QUESTION 1 #### 
#####################

## a ##
set.seed(5072)



## b ##
weekly <- data.frame(Weekly)
b.fit <- glm(Direction ~ Lag1+Lag2+Lag3+Lag4+Lag5+Volume, data=weekly, family=binomial)
summary(b.fit)
#Lag2 is statistically significant



## c ##
c.probs <- predict(b.fit, type="response")

c.pred <- rep("Down", 1089); c.pred[c.probs > 0.5] = "Up"
c.pred <- as.factor(c.pred)

c.table <- table(weekly$Direction, c.pred)
c.table



## d ##
## Fraction of correct predictions
mean(c.pred == weekly$Direction)

## Overall error rate
mean(c.pred != weekly$Direction)

## Type I error rates (false positive)
c.table[1,2] / sum(c.table[1,])

## Type II error rates (false negative)
c.table[2,1] / sum(c.table[2,])

## Power
1 - (c.table[2,1] / sum(c.table[2,]))

## Precision
c.table[2,2] / sum(c.table[,2])



## e ##
train.data <- subset(weekly, Year < 2009)
held.data <- subset(weekly, Year > 2008)

glm.fit <- glm(Direction ~ Lag2, data = train.data, family=binomial)



## f (GLM) ##
glm.pred <- rep("Down", nrow(held.data))
glm.pred[predict(object = glm.fit, newdata = held.data, type='response') > 0.5] = "Up"

glm.table <- table(held.data$Direction, glm.pred)
glm.table

## Fraction of correct predictions
mean(glm.pred == held.data$Direction)

## Overall error rate
mean(glm.pred != held.data$Direction)

## Type I error rates (false positive)
glm.table[1,2] / sum(glm.table[1,])

## Type II error rates (false negative)
glm.table[2,1] / sum(glm.table[2,])

## Power
1 - (glm.table[2,1] / sum(glm.table[2,]))

## Precision
glm.table[2,2] / sum(glm.table[,2])



## g (LDA) ##
lda.dir <- lda(Direction ~ Lag2, data = train.data, family=binomial)

lda.pred <- predict(lda.dir, held.data)$class

lda.table <- table(held.data$Direction, lda.pred)
lda.table

## Fraction of correct predictions
mean(lda.pred == held.data$Direction)

## Overall error rate
mean(lda.pred != held.data$Direction)

## Type I error rates (false positive)
lda.table[1,2] / sum(lda.table[1,])

## Type II error rates (false negative)
lda.table[2,1] / sum(lda.table[2,])

## Power
1 - (lda.table[2,1] / sum(lda.table[2,]))

## Precision
lda.table[2,2] / sum(lda.table[,2])



## h (QDA) ##
qda.dir <- qda(Direction ~ Lag2, data = train.data, family=binomial)

qda.pred <- predict(qda.dir, held.data)$class

qda.table <- table(held.data$Direction, qda.pred)
qda.table

## Fraction of correct predictions
mean(qda.pred == held.data$Direction)

## Overall error rate
mean(qda.pred != held.data$Direction)

## Type I error rates (false positive)
qda.table[1,2] / sum(qda.table[1,])

## Type II error rates (false negative)
qda.table[2,1] / sum(qda.table[2,])

## Power
1 - (qda.table[2,1] / sum(qda.table[2,]))

## Precision
qda.table[2,2] / sum(qda.table[,2])



## i (KNN=1) ##
knn1.pred <- knn(data.frame(train.data$Lag2), data.frame(held.data$Lag2), 
                train.data$Direction, k=1)
knn1.table <- table(held.data$Direction, knn1.pred)
knn1.table

## Fraction of correct predictions
mean(knn1.pred == held.data$Direction)

## Overall error rate
mean(knn1.pred != held.data$Direction)

## Type I error rates (false positive)
knn1.table[1,2] / sum(knn1.table[1,])

## Type II error rates (false negative)
knn1.table[2,1] / sum(knn1.table[2,])

## Power
1 - (knn1.table[2,1] / sum(knn1.table[2,]))

## Precision
knn1.table[2,2] / sum(knn1.table[,2])



## j (KNN=5) ##
knn5.pred <- knn(data.frame(train.data$Lag2), data.frame(held.data$Lag2), 
                 train.data$Direction, k=5)
knn5.table <- table(held.data$Direction, knn5.pred)
knn5.table

## Fraction of correct predictions
mean(knn5.pred == held.data$Direction)

## Overall error rate
mean(knn5.pred != held.data$Direction)

## Type I error rates (false positive)
knn5.table[1,2] / sum(knn5.table[1,])

## Type II error rates (false negative)
knn5.table[2,1] / sum(knn5.table[2,])

## Power
1 - (knn5.table[2,1] / sum(knn5.table[2,]))

## Precision
knn5.table[2,2] / sum(knn5.table[,2])



## k ##
# Logistic regression and LDA seem to have the best results.
# They have the same values -- highest "correct" percentage, high power, and high precision
# Additionally, they have a low type II error, which is preferred since it is the "worst" of the
# two errors



##################### 
#### QUESTION 2 #### 
#####################

## a ##
set.seed(5072)



## b ##
mpg01 <- c()
for (i in 1:nrow(Auto)) {
  if (Auto$mpg[i] > median(Auto$mpg)) {
    mpg01[i] <- 1
  }
  else mpg01[i] <- 0
}

auto <- data.frame(mpg01, Auto[-1])



## c ##
auto.train  <-  sample(nrow(auto), 0.8 * nrow(auto))
auto.test  <-  setdiff(1:nrow(auto), auto.train) 
auto.trainset <- auto[auto.train,]
auto.testset <- auto[auto.test,]

autotrain.x <- auto.trainset[,-1]
autotrain.y <- as.factor(auto.trainset$mpg01)
autotest.x <- auto.testset[,-1]
autotest.y <- as.factor(auto.testset$mpg01)


## d ##
auto.glm <- glm(mpg01 ~ cylinders + displacement + weight, data=auto.trainset, family=binomial)



## e GLM ##
auto.glm.pred <- rep(0, nrow(auto.testset))
auto.glm.pred[predict(object = auto.glm, newdata = auto.testset, type='response') > 0.5] = 1

auto.glm.table <- table(autotest.y, auto.glm.pred)
auto.glm.table

## Fraction of correct predictions
mean(auto.glm.pred == autotest.y)

## Overall error rate
mean(auto.glm.pred != autotest.y)

## Type I error rates (false positive)
auto.glm.table[1,2] / sum(auto.glm.table[1,])

## Type II error rates (false negative)
auto.glm.table[2,1] / sum(auto.glm.table[2,])

## Power
1 - (auto.glm.table[2,1] / sum(auto.glm.table[2,]))

## Precision
auto.glm.table[2,2] / sum(auto.glm.table[,2])



## f LDA ##
auto.lda <- lda(mpg01 ~ cylinders + displacement + weight, data=auto.trainset, family=binomial)

auto.lda.pred <- predict(auto.lda, auto.testset)$class

auto.lda.table <- table(autotest.y, auto.lda.pred)
auto.lda.table

## Fraction of correct predictions
mean(auto.lda.pred == autotest.y)

## Overall error rate
mean(auto.lda.pred != autotest.y)

## Type I error rates (false positive)
auto.lda.table[1,2] / sum(auto.lda.table[1,])

## Type II error rates (false negative)
auto.lda.table[2,1] / sum(auto.lda.table[2,])

## Power
1 - (auto.lda.table[2,1] / sum(auto.lda.table[2,]))

## Precision
auto.lda.table[2,2] / sum(auto.lda.table[,2])



## g QDA ##
auto.qda <- qda(mpg01 ~ cylinders + displacement + weight, data=auto.trainset, family=binomial)

auto.qda.pred <- predict(auto.qda, auto.testset)$class

auto.qda.table <- table(autotest.y, auto.qda.pred)
auto.qda.table

## Fraction of correct predictions
mean(auto.qda.pred == autotest.y)

## Overall error rate
mean(auto.qda.pred != autotest.y)

## Type I error rates (false positive)
auto.qda.table[1,2] / sum(auto.qda.table[1,])

## Type II error rates (false negative)
auto.qda.table[2,1] / sum(auto.qda.table[2,])

## Power
1 - (auto.qda.table[2,1] / sum(auto.qda.table[2,]))

## Precision
auto.qda.table[2,2] / sum(auto.qda.table[,2])



## h KNN=1 ##
autotrain.x <- data.frame(auto.trainset$cylinders,auto.trainset$displacement,auto.trainset$weight)
autotest.x <- data.frame(auto.testset$cylinders,auto.testset$displacement,auto.testset$weight)
autotrain.x <- scale(autotrain.x)
autotest.x <- scale(autotest.x)

knn1.auto.pred <- knn(autotrain.x, autotest.x, autotrain.y, k=1)
knn1.auto.table <- table(autotest.y, knn1.auto.pred)
knn1.auto.table

## Fraction of correct predictions
mean(knn1.auto.pred == autotest.y)

## Overall error rate
mean(knn1.auto.pred != autotest.y)

## Type I error rates (false positive)
knn1.auto.table[1,2] / sum(knn1.auto.table[1,])

## Type II error rates (false negative)
knn1.auto.table[2,1] / sum(knn1.auto.table[2,])

## Power
1 - (knn1.auto.table[2,1] / sum(knn1.auto.table[2,]))

## Precision
knn1.auto.table[2,2] / sum(knn1.auto.table[,2])



## i Best KNN ##
autotrain.x <- data.frame(auto.trainset$cylinders,auto.trainset$displacement,auto.trainset$weight)
autotest.x <- data.frame(auto.testset$cylinders,auto.testset$displacement,auto.testset$weight)

auto.test.errors <- c()

for(i in 1:20) {
  auto.knn.pred <- knn(autotrain.x, autotest.x, autotrain.y, k = i)
  auto.test.errors[i] <- mean(autotest.y != auto.knn.pred)
}

bestk <- which.min(auto.test.errors)
cat("Best Boston k =", bestk)

knnbest.auto.pred <- knn(autotrain.x, autotest.x, autotrain.y, k=bestk)
knnbest.auto.table <- table(autotest.y, knnbest.auto.pred)
knnbest.auto.table

## Fraction of correct predictions
mean(knnbest.auto.pred == autotest.y)

## Overall error rate
mean(knnbest.auto.pred != autotest.y)

## Type I error rates (false positive)
knnbest.auto.table[1,2] / sum(knnbest.auto.table[1,])

## Type II error rates (false negative)
knnbest.auto.table[2,1] / sum(knnbest.auto.table[2,])

## Power
1 - (knnbest.auto.table[2,1] / sum(knnbest.auto.table[2,]))

## Precision
knnbest.auto.table[2,2] / sum(knnbest.auto.table[,2])



## j ##
#My best K value of 3 and QDA both gave the best results for this data (with different confusion
#matrices)



##################### 
#### QUESTION 3 #### 
#####################
set.seed(5072)

## New Boston Column ##
crim01 <- c()
for (i in 1:nrow(Boston)) {
  if (Boston$crim[i] > median(Boston$crim)) {
    crim01[i] <- 1
  }
  else crim01[i] <- 0
}

Boston <- data.frame(crim01, Boston[-1])



## Split Data ##
bos.train  <-  sample(nrow(Boston), 0.8 * nrow(Boston))
bos.test  <-  setdiff(1:nrow(Boston), bos.train) 
bos.trainset <- Boston[bos.train,]
bos.testset <- Boston[bos.test,]

bostrain.x <- bos.trainset[,-1]
bostrain.y <- as.factor(bos.trainset$crim01)

bostest.x <- bos.testset[,-1]
bostest.y <- as.factor(bos.testset$crim01)


## GLM ##
bos.glm <- glm(crim01 ~ nox + rad + dis, data=bos.trainset, family=binomial)

bos.glm.pred <- rep(0, nrow(bos.testset))
bos.glm.pred[predict(object = bos.glm, newdata = bos.testset, type='response') > 0.5] = 1

bos.glm.table <- table(bostest.y, bos.glm.pred)
bos.glm.table

## Fraction of correct predictions
mean(bos.glm.pred == bostest.y)

## Overall error rate
mean(bos.glm.pred != bostest.y)

## Type I error rates (false positive)
bos.glm.table[1,2] / sum(bos.glm.table[1,])

## Type II error rates (false negative)
bos.glm.table[2,1] / sum(bos.glm.table[2,])

## Power
1 - (bos.glm.table[2,1] / sum(bos.glm.table[2,]))

## Precision
bos.glm.table[2,2] / sum(bos.glm.table[,2])



## LDA ##
bos.lda <- lda(crim01 ~ nox + rad + dis, data=bos.trainset, family=binomial)

bos.lda.pred <- predict(bos.lda, bos.testset)$class

bos.lda.table <- table(bostest.y, bos.lda.pred)
bos.lda.table

## Fraction of correct predictions
mean(bos.lda.pred == bostest.y)

## Overall error rate
mean(bos.lda.pred != bostest.y)

## Type I error rates (false positive)
bos.lda.table[1,2] / sum(bos.lda.table[1,])

## Type II error rates (false negative)
bos.lda.table[2,1] / sum(bos.lda.table[2,])

## Power
1 - (bos.lda.table[2,1] / sum(bos.lda.table[2,]))

## Precision
bos.lda.table[2,2] / sum(bos.lda.table[,2])



## KNN=1 ##
bostrain.x <- data.frame(bos.trainset$nox,bos.trainset$rad,bos.trainset$dis)
bostest.x <- data.frame(bos.testset$nox,bos.testset$rad,bos.testset$dis)
autotrain.x <- scale(bostrain.x)
autotest.x <- scale(bostest.x)

knn1.bos.pred <- knn(bostrain.x, bostest.x, bostrain.y, k=1)
knn1.bos.table <- table(bostest.y, knn1.bos.pred)
knn1.bos.table

## Fraction of correct predictions
mean(knn1.bos.pred == bostest.y)

## Overall error rate
mean(knn1.bos.pred != bostest.y)

## Type I error rates (false positive)
knn1.bos.table[1,2] / sum(knn1.bos.table[1,])

## Type II error rates (false negative)
knn1.bos.table[2,1] / sum(knn1.bos.table[2,])

## Power
1 - (knn1.bos.table[2,1] / sum(knn1.bos.table[2,]))

## Precision
knn1.bos.table[2,2] / sum(knn1.bos.table[,2])



## Best KNN ##
bos.test.errors <- c()
for(i in 1:20) {
  bos.knn.pred <- knn(bostrain.x, bostest.x, bostrain.y, k = i)
  bos.test.errors[i] <- mean(bostest.y != bos.knn.pred)
}

bosbestk <- which.min(bos.test.errors)
cat("Best Boston k =", bosbestk)

knnbest.bos.pred <- knn(bostrain.x, bostest.x, bostrain.y, k=bosbestk)
knnbest.bos.table <- table(bostest.y, knnbest.bos.pred)
knnbest.bos.table

## Fraction of correct predictions
mean(knnbest.bos.pred == bostest.y)

## Overall error rate
mean(knnbest.bos.pred != bostest.y)

## Type I error rates (false positive)
knnbest.bos.table[1,2] / sum(knnbest.bos.table[1,])

## Type II error rates (false negative)
knnbest.bos.table[2,1] / sum(knnbest.bos.table[2,])

## Power
1 - (knnbest.bos.table[2,1] / sum(knnbest.bos.table[2,]))

## Precision
knnbest.bos.table[2,2] / sum(knnbest.bos.table[,2])


## Best Model ##
#The model that best represents the Boston data is K=1, which is also my best K value.



##################### 
#### QUESTION 4 #### 
#####################

## a ##
set.seed(5072)
x = rnorm(100)
y = x - 2 * x^2 + rnorm(100)



## b ##
my.df <- data.frame(x, y)
plot(my.df)

## d ##
set.seed(123)


cv.error <- c()
for (j in 1:4){
  glm.fit <- glm(y ~ poly(x, j), data=my.df)
  cv.error[j] <- cv.glm(my.df, glm.fit)$delta[1]
}
#cv.error
#summary(glm.fit)$coef[,"Pr(>|t|)",drop=F]


## e ##
set.seed(456)

cv.error2 <- c()
for (j in 1:4){
  glm.fit2 <- glm(y ~ poly(x, j), data=my.df)
  cv.error2[j] <- cv.glm(my.df, glm.fit2)$delta[1]
}
#cv.error2
#summary(glm.fit2)$coef[,"Pr(>|t|)",drop=F]

#The results are the same using different seeds because there is no randomness in the 
#training and test sets. Since LOOCV loops so many times, it will always result in the same MSE.


## f ##
#The model with the smallest LOOCV error was the polynomial 2. I would not have expected this
#because I would think the error rates would continue decreasing as the polynomials increased.
#This is likely be because the variance increases more than bias decreases so the error rate
#begins to rise as the polynomials rise.



## g ##
#summary(glm.fit)$coef[,"Pr(>|t|)",drop=F]
#summary(glm.fit2)$coef[,"Pr(>|t|)",drop=F]

#Yes, the p-values agree with the cv results. The smallest p-value occurs in the 2nd polynomial.



