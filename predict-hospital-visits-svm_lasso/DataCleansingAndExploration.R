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

needed <- c('e1071', 'ISLR', 'boot', 'MASS', 'splines', 'caret', 'eeptools', 'glmnet', 'tidyr')      
installIfAbsentAndLoad(needed)

########################
#### Data cleansing ####
########################


#### Read in data
mydata <- read.csv('WM_SMART.csv', header = T, na.strings = c("", " ", "NA"))


#### Check for na's
sum(is.na(mydata))
sort(colSums(is.na(mydata)))


#### Delete some useless columns
deletecols <- c('PID_SALT', 'SMART_AGE', 'SMART_COMORB', 'SMART_BEHAV', 'SMART_SPECMEDS',
                'SMART_POLYPHARM', 'SMART_ACB', 'SMART_TOTAL', 'BMI_DATE', 'INSURANCE_PRIM')
mydata <- mydata[ , -which(colnames(mydata) %in% deletecols)]



#### Change secondary insurance to binary
colsNames <- c('INSURANCE_SEC')
mydata[colsNames] <- sapply(mydata[colsNames], as.character)
mydata[colsNames][is.na(mydata[colsNames])] <- 0
mydata[colsNames][which(mydata[colsNames] != "0"),] <- 1
mydata[colsNames] <- as.integer(mydata$INSURANCE_SEC)
mydata$BMI_VALUE[is.na(mydata$BMI_VALUE)] <- mean(mydata$BMI_VALUE, na.rm=T)
# mydata[colsNames][is.na(mydata[colsNames])] <- "None"
# mydata[colsNames] <- lapply(mydata[colsNames], as.factor)


#### Delete dash in Zip codes
mydata <- separate(mydata,ZIP,into="" ,sep="-" )
colnames(mydata)[34] <- "ZIP"
mydata$ZIP <- as.factor(mydata$ZIP)


#### Change dates to dates, calculate ages
mydata$DATEOFBIRTH <- as.Date(mydata$DATEOFBIRTH, "%m/%d/%Y")
mydata$pxage <- age_calc(mydata$DATEOFBIRTH, units = 'years')
mydata$DATEOFBIRTH <- NULL
mydata$pxage <- floor(mydata$pxage) - 1


#### Omit 47 rows containing NA in ZIP, then check for na's
mydata <- na.omit(mydata)
sum(is.na(mydata))


#### Split into train and test
training <- createDataPartition(y = mydata$ER_VISIT, p= 0.8, list=F)
train <- mydata[training,]; test <- mydata[-training,]

train.new <- sample(nrow(train), 0.1*nrow(train), replace = F)
train.s <- train[train.new,]
test.new <- sample(nrow(test), .01*nrow(test), replace=F)
test.s <- test[test.new,]


##########################
#### Data Exploration ####
##########################

#### Check ANOVA to see correlations between response variable and observations
atable <- aov(mydata$ER_VISIT[1:1000] ~ ., data = mydata[1:1000,])
summary(atable)


#### Split the data into patients who have had hospital visit vs. not
er <- mydata[which(mydata$ER_VISIT == 1),]      #11,461 ER visits
no_er <- mydata[which(mydata$ER_VISIT == 0),]   #106,505 non-ER visits


#### Look at age
par(mfrow=c(1,2))
hist(er$pxage, main = 'ER age', breaks=10, col='lightcoral')
hist(no_er$pxage, main = 'Non-ER age', breaks=10, col = 'lightseagreen')
# They are literally the same distriution
sort(table(mydata$pxage), decreasing=T)[1:15]   #Most ages are in the 50's and 60's

agetable <- as.matrix(sort(table(mydata$pxage), decreasing=T)[1:15])
as.matrix(table(er$pxage))[as.integer(rownames(agetable))] / agetable
1-as.matrix(table(er$pxage))[as.integer(rownames(agetable))] / agetable

#### Look at number of meds
mean(er$NUM_MEDS); range(er$NUM_MEDS)
mean(no_er$NUM_MEDS); range(no_er$NUM_MEDS)
hist(er$NUM_MEDS, main = 'ER Number of Meds', col='lightcoral')
hist(no_er$NUM_MEDS, main = 'Non-ER Number of Meds', col='lightseagreen')
par(mfrow=c(1,1))




########################
#### Model Building ####
########################

#### Conduct Lasso to select only important predictors
train_sparse <- sparse.model.matrix(~.,train[ ,!(colnames(train) == "ER_VISIT")])
test_sparse <- sparse.model.matrix(~.,test[ ,!(colnames(test) == 'ER_VISIT')])

myLasso <- glmnet(train_sparse,train[, 'ER_VISIT'], alpha=1)
cv <- cv.glmnet(train_sparse,train[, 'ER_VISIT'], nfolds=10)
l.pred <- predict(myLasso, test_sparse, type="response", s=cv$lambda.min)

lasso_coef = predict(myLasso, type = "coefficients", s = cv$lambda.min)[1:length(myLasso$beta@Dimnames[[1]]),]
coefs <- lasso_coef[which(lasso_coef != 0)]; length(coefs)
sort(coefs, decreasing = T)[1:20]


preds <- rep(0,nrow(test))
preds[l.pred >= 0.09] = 1
mean(preds == test$ER_VISIT)
table("actual" = test$ER_VISIT, "predicted" = preds)
actuals = test$ER_VISIT

FP <- sum(preds == '1' & actuals == '0') / (sum(actuals == "0" & preds == '0') + sum(preds == '1' & actuals == '0'))
FN <- sum(preds == '0' & actuals == '1') / (sum(actuals == "1" & preds == '1') + sum(preds == '0' & actuals == '1'))
TP <- sum(preds == '1' & actuals == '1') / sum(actuals == "1")
TN <- sum(preds == '0' & actuals == '0') / sum(actuals == '0')
OE <- (sum(preds == '1' & actuals == '0') + sum(preds == '0' & actuals == '1')) / length(actuals)


#### Conduct SVM
svmfit <- tune(svm, (ER_VISIT) ~ ., data= train.s, 
               ranges=list(cost = 2^(-2:7)), scale=F, probability = T)
#save(svmfit, file = "svmfit2.rda")
#load("svmfit2.rda")

bestlm <- svmfit$best.model

lm.testpred <- predict(bestlm, newdata=test, probability = T)


preds <- rep(0,nrow(test))
#preds[attr(lm.testpred, "probabilities")[,2] >= 0.09] = 1
preds[lm.testpred >= 0.098] <- 1
mean(preds == test$ER_VISIT)

actuals <- test$ER_VISIT

mytable <- table("actual" = test$ER_VISIT, "predicted" = preds)
mytable

FP <- sum(preds == '1' & actuals == '0') / (sum(actuals == "0" & preds == '0') + sum(preds == '1' & actuals == '0'))
FN <- sum(preds == '0' & actuals == '1') / (sum(actuals == "1" & preds == '1') + sum(preds == '0' & actuals == '1'))
TP <- sum(preds == '1' & actuals == '1') / sum(actuals == "1")
TN <- sum(preds == '0' & actuals == '0') / sum(actuals == '0')
OE <- (sum(preds == '1' & actuals == '0') + sum(preds == '0' & actuals == '1')) / length(actuals)
df <- rbind(df, c(i,FP,FN,TP,TN,OE))


