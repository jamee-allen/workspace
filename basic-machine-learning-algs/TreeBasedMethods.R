## Section 2-11
## Daniel Kuzjal, Killian McKee, Jamee Allen, Jiafan Deng

rm(list = ls())
installIfAbsentAndLoad <- function(neededVector) {
  for(thispackage in neededVector) {
    if( ! require(thispackage, character.only = TRUE) )
    { install.packages(thispackage)}
    require(thispackage, character.only = TRUE)
  }
}
needed = c("pROC", "ada", "randomForest", "pROC", "verification", "rpart", "rattle", 'MASS')
installIfAbsentAndLoad(needed)

ratesmatrix <- function(table){
  FP.type1 <- table[1,2]/(table[1,1]+table[1,2])
  FN.type2 <- table[2,1]/(table[2,1]+table[2,2])
  TP <- table[2,2]/sum(table[2,])
  TN <- table[1,1]/sum(table[1,])
  errorrate <-(table[1,2]+table[2,1])/sum(table)
  accuracy <- 1-errorrate
  matrix <- cbind(FP.type1,FN.type2,TP,TN,errorrate,accuracy)
  colnames(matrix) <- c('FP.type1 error','FN.type2 error', 'True Pos', 'True Neg', 'overall error', 'accuracy')
  return (matrix)
}

# read the data file
data <- read.csv('Assignment2TrainingData.csv', header = T)

# Clean our data
TeleData <- na.omit(data)

# Assign tenure to different level
tenurelevel <- function(tenure){
  if (tenure >= 0 && tenure <= 12){
    return('0-12 Month')
  }else if(tenure > 12 && tenure <= 24){
    return('12-24 Month')
  }else if (tenure > 24 && tenure <= 36){
    return('24-36 Month')
  }else if (tenure > 36 && tenure <= 48){
    return('36-48 Month')
  }else if (tenure > 48 && tenure <= 60){
    return('48-60 Month')
  }else if (tenure > 60 && tenure <= 72){
    return('60-72 Month')
  }
}

# Add a new column to our data
TeleData$tenure_level <- sapply(TeleData$tenure, tenurelevel)
TeleData$tenure_level <- as.factor(TeleData$tenure_level)
TeleData <- subset(TeleData, select = -c(customerID, tenure))

# Split to test and train
set.seed(5072)
n = nrow(TeleData)
train <- sample(n, 0.7*n)
test <- setdiff(1:n, train)

# 100 iterations boosting model
set.seed(5072)
bm2 <- ada(formula=Churn ~ .,data=TeleData[train,],iter=100,bag.frac=0.5,
           control=rpart.control(maxdepth=30,cp=0.01,minsplit=20,xval=10))
preds <- predict(bm2, newdata=TeleData[test,])
test_table <- table(TeleData[test,]$Churn, preds, dnn=c("Actual", "Predicted"))
ratesmatrix(test_table)

# test with test data
predicted <-predict(bm2, newdata=TeleData[test,], type='prob')
actuals <- as.numeric(TeleData[test,]$Churn)-1
cutoff <- seq(0,1,.01)
df <- data.frame(c())

for (i in cutoff) {
  preds <- rep(0, length(actuals))
  preds[predicted[,2] > i] = 1
  FP <- sum(preds == '1' & actuals == '0') / (sum(actuals == "0" & preds == '0') + sum(preds == '1' & actuals == '0'))
  FN <- sum(preds == '0' & actuals == '1') / (sum(actuals == "1" & preds == '1') + sum(preds == '0' & actuals == '1'))
  TP <- sum(preds == '1' & actuals == '1') / sum(actuals == "1")
  TN <- sum(preds == '0' & actuals == '0') / sum(actuals == '0')
  OE <- (sum(preds == '1' & actuals == '0') + sum(preds == '0' & actuals == '1')) / length(actuals)
  df <- rbind(df, c(i,FP,FN,TP,TN,OE))
}
colnames(df) = c('Cut Off', 'False Pos', 'False Neg', 'True Pos', 'True Neg', 'Overall Error')
write.csv(df, file = "Assignment2Results.csv")
