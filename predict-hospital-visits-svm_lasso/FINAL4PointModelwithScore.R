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

needed <- c('e1071', 'ROCR', 'ISLR', 'boot', 'MASS', 'splines', 'caret', 'eeptools', 'glmnet', 'tidyr')      
installIfAbsentAndLoad(needed)



########################
#### Data cleansing ####
########################


#### Read in data
mydata <- read.csv('WM_SMART.csv', header = T, na.strings = c("", " ", "NA"))
original<-mydata


#### Delete some useless columns
SMARTcols <- c('SCORE','SMART_ACB', 'SMART_SPECMEDS', 'SMART_POLYPHARM', 'ER_VISIT')
mydata <- mydata[ , which(colnames(mydata) %in% SMARTcols)]

#### Confusion matrix stats function
confusionMatrixStats <- function(cMatrix){
  correctPreds <- (cMatrix[1,1]+ cMatrix[2,2])/sum(cMatrix)
  errorRate <- (cMatrix[1,2]+ cMatrix[2,1])/sum(cMatrix)
  type1 <- cMatrix[1, 2] / sum(cMatrix[1, ])
  type2 <- cMatrix[2, 1] / sum(cMatrix[2, ])
  power <- cMatrix[2, 2] / sum(cMatrix[2, ])
  precision <- cMatrix["1", "1"] / sum(cMatrix[, "1"])
  return(cat("Correct: ", correctPreds,"\nErrors: ", errorRate, "\nType 1 Errors: ", type1, "\nType 2 Errors: ", type2, "\nPower: ", power, "\nPrecision: ", precision))
}

#### Look at correlations
aov(mydata$ER_VISIT ~ . , data = mydata)
#cor(mydata[,1:5])


#### Adjust Charlson score
mydata$SCORE[mydata$SCORE < 2] <- 0
mydata$SCORE[mydata$SCORE >= 2] <- 1

#### Create new total
mydata$total <- rowSums(mydata[,1:(ncol(mydata)-1)])


########################
#### Initial Model #####
########################

#### Look at percent correct on threshold of 2
mydata$binary<-mydata$total
mydata$binary[mydata$binary<=2]<-0
mydata$binary[mydata$binary>2]<-1

diff <- mydata$binary - mydata$ER_VISIT
correct<-sum(diff==0)

percCorrect<-correct/nrow(mydata)
percCorrect

mytable<-table(actual = original$ER_VISIT, pred=mydata$binary)
confusionMatrixStats(mytable)


#### Look at percent correct on threshold of 1
mydata$binary<-mydata$total
mydata$binary[mydata$binary<2]<-0
mydata$binary[mydata$binary>=2]<-1

diff <- mydata$binary - mydata$ER_VISIT
correct<-sum(diff==0)

percCorrect<-correct/nrow(mydata)
percCorrect

mytable<-table(actual = original$ER_VISIT, pred=mydata$binary)
confusionMatrixStats(mytable)



########################
######     GLM     #####
########################

#### Create GLM and print results
set.seed(5082)
train <- sample(1:nrow(mydata), .8*nrow(mydata))
Smart_data_2.train <- mydata[train,]
Smart_data_2.test <- mydata[-train,]

fit <- glm(ER_VISIT ~ SCORE +SMART_ACB + SMART_SPECMEDS + SMART_POLYPHARM, data = mydata, family ="binomial")
preds <- predict(fit, newdata = mydata, type = "response")

pred_4 <- rep(0, nrow(mydata))
pred_4[preds >= (mean(preds) - 0.02)] = 1
mean(pred_4 == mydata$ER_VISIT)

mytable2<-table(mydata$ER_VISIT, pred_4,dnn=c("Actual", "Predicted"))
confusionMatrixStats(mytable2)
coef(fit)
summary(fit)


#### Take out the zeros from $target and test GLM
set.seed(5082)
mydata2 <- mydata

mydata2 <- mydata2[!grepl(0, mydata2$total),]
train <- sample(1:nrow(mydata2), .8*nrow(mydata2))
Smart_data_2.train <- mydata2[train,]
Smart_data_2.test <- mydata2[-train,]

fit2 <- glm(ER_VISIT ~  SCORE +SMART_ACB + SMART_SPECMEDS + SMART_POLYPHARM, data = mydata2, family ="binomial")
cvfit2 <- cv.glm(mydata2, fit2, K=10)
preds2 <- predict(fit2, newdata = mydata2, type = "response")

pred_4 <- rep(0, nrow(mydata2))
pred_4[preds2 >= (mean(preds2) - .01)] = 1
mean(pred_4 == mydata2$ER_VISIT)

mytable2<-table(mydata2$ER_VISIT, pred_4,dnn=c("Actual", "Predicted"))
confusionMatrixStats(mytable2)
coef(fit2)
summary(fit2)
# perf1 <- performance(preds2,"tpr","fpr")
# plot(perf1)
