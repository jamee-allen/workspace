rm(list=ls())
require(MASS)
par(mfrow=c(1,1))

##################### 
#### QUESTION 1 #### 
#####################

##### Moderate Noise #####
set.seed(5072)
x <- rnorm(100, mean=0, 1)
eps <- rnorm(100, mean=0, sd= sqrt(0.25))
y <- -1 + (0.5*x) + eps
length(y)

#B0 = -1, B1 = 0.5

plot(x,y,pch=1,col="tan")
#This looks like a positively correlated linear relationship with moderate variability

lm.fit <- lm(y ~ x)
coef(lm.fit)
#The predicted intercept coefficient values are fairly close to the actual, with the predicted B0 being closer than B1 to their real values.

plot(x, y, pch=1, col="tan", main='Moderate Noise')
abline(a=-1, b=0.5, lwd=2, col="red")
abline(lm.fit, lwd=2, col="black")
legend("topleft", legend=c("Observations", "Least Squares", "Population Regression"), 
       lty=c(NA,1,1), col=c("tan","black","red"), pch=c(1,NA,NA), cex=.8)

lm.squarefit <- lm(y ~ x + poly(x,2))
anova(lm.squarefit)
#There is no evidence that lm.fit2 lends more accurate Y predictions since the P-value is .57 (cannot reject the null hypothesis). The linear regression for just x is far superior.



##### Little Noise ####
epslittle <- rnorm(100, mean=0, sd = sqrt(0.1))
y <- -1 + (0.5*x) + epslittle

#B0 = -1, B1 = 0.5

plot(x,y,pch=1,col="tan",main='Little Noise')
#This looks like a positively correlated linear relationship with very little variability

lm.fit2 <- lm(y ~ x)
coef(lm.fit2)
#The predicted intercept and slope are almost identical to the actual

plot(x, y, pch=1, col="tan", main='Little Noise')
abline(a=-1, b=0.5, lwd=2, col="red")
abline(lm.fit2, lwd=2, col="black")
legend("topleft", legend=c("Observations", "Least Squares", "Population Regression"), 
       lty=c(NA,1,1), col=c("tan","black","red"), pch=c(1,NA,NA), cex=.8)



##### Lots of Noise #####
epslots <- rnorm(100, mean=0, sd = sqrt(0.5))
y <- -1 + (0.5*x) + epslots

#B0 = -1, B1 = 0.5
#This has a slightly positive correlation moderate-high variability

plot(x,y,pch=1,col="tan", main='Lots of Noise')

lm.fit3 <- lm(y ~ x)
coef(lm.fit3)
#The predicted intercept is close, but the predicted slope is now farther from the actual slope than before

plot(x, y, pch=1, col="tan", main='Lots of Noise')
abline(a=-1, b=0.5, lwd=2, col="red")
abline(lm.fit3, lwd=2, col="black")
legend("topleft", legend=c("Observations", "Least Squares", "Population Regression"), 
       lty=c(NA,1,1), col=c("tan","black","red"), pch=c(1,NA,NA), cex=.8)



#Contrast the linear fit models...
confint(lm.fit2, level=0.95) #95% confidence interval for little noise
confint(lm.fit, level=0.95) #95% confidence interval for moderate noise
confint(lm.fit3, level=0.95) #95% confidence interval for a lot of noise
#The widths of the confidence intervals increase with noise because the model's confidence in predicting the B0 and B1 values decreases. The less noise there is, the more confident the model is at predicting the actual observations, thus it will give more slender/fit confidence interval values.



##################### 
#### QUESTION 2 ##### 
#####################
set.seed (5072)
x1=runif (100)
x2 = 0.5 * x1 + rnorm (100) /10
y= 2 + 2*x1 + 0.3*x2 + rnorm (100)

#B0 = 2, B1 = 2, B3 = 0.3

cor(y, x1, method = "pearson")
cor(y, x2, method = "pearson")
cor(x1, x2)

pairs(~y + x1 + x2)
#The correlations between y and both x1 and x2 are pretty weak. The correlation between x1 and x2 is very strong which makes sense because x2 is a function of x1.

lm.fit.both <- lm(y ~ x1+x2)
coef(lm.fit.both)
#B0 and B1 are statistically significant because they closely resemble the actual coefficients in my data. B2 is a negative number and very far off from the actual number. I would reject the null hypothesis for B1 because the p-values are significant. I would assume the null hypothesis H0: B2=0 because there is very little correlation and the p-value is 0.64.

lm.fit.justx1 <- lm(y ~ x1)
anova(lm.fit.justx1)$'Pr(>F)'[1]
#I would reject the null hypothesis H0: x1=0 because it is strongly correlated with the real data given a p-value of 5.89e-08 and a relatively high t-value.

lm.fit.justx2 <- lm(y ~ x2)
anova(lm.fit.justx2)$'Pr(>F)'[1]
#Surprisingly enough, x2 is actually a close representation of the real data. Although the value for the predicted B2 isn't close to that of the actual B2, it is a good predictor given its p-value of 2.41e-05

#Yes, the answers in j-m contradict the answers obtained in f-i. In f-i, x2 was not a great predictor of the actual results, therefore I assumed the null hypothesis. In j-m, I found that when x2 is the only element used to predict y, it was in fact accurate.


x1=c(x1 , 0.1)
x2=c(x2 , 0.8)
y=c(y,6)
par(mfrow=c(2,2))

lm.fit.both.new <- lm(y ~ x1+x2)
anova(lm.fit.both.new)$'Pr(>F)'
#This model makes both x1 and x2 better predictors of y since their p-values are a lot less than they were when point 101 was excluded
plot(lm.fit.both.new)
#This new observation (point 101) gives a high leverage point and is also an outlier. I would assume it is a high leverage point because both x1 and x2 are more accurate predictors of y, and it is an outlier because it sits above all the other points.

lm.fit.justx1.new <- lm(y ~ x1)
anova(lm.fit.justx1.new)
#Point 101 wasn't beneficial for the "just x1" model, but it also wasn't detrimental. Although the p-value increased ever so slightly, it is still an accurate predictor of y
plot(lm.fit.justx1.new)
#For just x1, the 101st point was only an outlier. It didn't have high leverage because it wasn't beneficial in facilitating x into a better predictor of y

lm.fit.justx2.new <- lm(y ~ x2)
anova(lm.fit.justx2.new)
#The p-value for 100 points vs 101 points didn't change the p-value of just x2, so it didn't have much of an affect on this variable.
plot(lm.fit.justx2.new)
#The 101st point in x2 served as a leverage rather than an outlier. 

par(mfrow=c(1,1))



##################### 
#### QUESTION 3 ##### 
#####################
set.seed(5072)

#Create table
crime.table <- matrix(ncol = 4, dimnames = list(NULL, c("variable", "beta", "fstat", "pval")))
for (i in 2:ncol(Boston)) {
  lm.fit <- lm(Boston$crim ~ Boston[,i])
  lm.fstat <- summary(lm.fit)$fstatistic['value']
  lm.pval <- anova(lm.fit)$'Pr(>F)'
  lm.beta <- coef(lm.fit)["Boston[, i]"]
  crime.table <- rbind.data.frame(crime.table, c(colnames(Boston[i]), lm.beta, lm.fstat, lm.pval))
}
crime.table[-1,]
#It looks like all the variables except for chas (Charles River dummy variable) are significant predictors of crime rate


#Create 12 linear plots
par(mfrow=c(3,4))
for (i in 2:ncol(Boston)) {
  if (i != 4) {
    plot(Boston[,i], Boston$crim, main=colnames(Boston[i]), xlab='x')
    abline(lm(Boston$crim ~ Boston[,i]), lwd=2, col='red')
  }
}
par(mfrow=c(1,1))


#Multiple regression significant predictors
lm.fit.all <- lm(crim ~ ., data=Boston)
for (i in 2:14) {
  if (summary(lm.fit.all)$coefficients[i,4] < 0.05) {
    print(colnames(Boston[i]))
  }
}

#Plot comparison for simple and multiple regression models
plot(crime.table$beta[-1], lm.fit.all$coefficients[-1], xlab='Simple', ylab='Multiple', main='Comparing Simple and Multiple Linear Regression Coeffi')
#Clumping around zero, which means they both agree for the most part.


poly.table <- matrix(ncol = 3, dimnames = list(NULL, c("predictor", "fstat", "pvalueofFstat")))
for (i in 2:ncol(Boston)) {
  if (i != 4) {
  lm.fit <- lm(Boston$crim ~ Boston[,i] + poly(Boston[,i],3, raw=TRUE))
  lm.fstat <- (anova(lm.fit))$'F value'[2]
  lm.pval <- anova(lm.fit)$'Pr(>F)'[2]
  poly.table <- rbind.data.frame(poly.table, c(colnames(Boston[i]), lm.fstat, lm.pval))
  }
}
poly.table$pvalueofFstat <- as.numeric(poly.table$pvalueofFstat)
poly.table <- poly.table[order(poly.table$pvalueofFstat),]
poly.table[-13,]

