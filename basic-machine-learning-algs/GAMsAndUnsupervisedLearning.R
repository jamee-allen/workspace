rm(list = ls())
installIfAbsentAndLoad <- function(neededVector) {
  for(thispackage in neededVector) {
    if( ! require(thispackage, character.only = TRUE) )
    { install.packages(thispackage)}
    require(thispackage, character.only = TRUE)
  }
}
needed = c('corrplot', 'ggfortify') 
installIfAbsentAndLoad(needed)

##################### 
#### Question 1 #####
#####################

set.seed(5072)

#  Center and scale the data
myUSArrests <- as.matrix(USArrests)
n <- nrow(myUSArrests)
i <- rep(1,n)
myUSArrests <- myUSArrests - i%*% t(i) %*% myUSArrests*(1/n)
myUSArrests <- scale(myUSArrests)


#  Calculate PVE using prcomp and sdev  
pr.out<- prcomp(myUSArrests)
pr.var <- pr.out$sdev ^ 2
pve1 <- pr.var / sum(pr.var)

#  Calculate PVE manually
loadings <- pr.out$rotation
sumvar <- sum(as.matrix(myUSArrests)^2)
pve2 <- apply((as.matrix(myUSArrests) %*% loadings)^2, 2, sum) / sumvar

cat("\n\nPVE using prcomp() function:\n", pve1, "\n\nPVE using loadings:\n", pve2)



##################### 
#### Question 2 #####     Come back to this one!
#####################

set.seed(5072)

#  Calculate euclidean distance and correlation-based distance
my.data <- t(USArrests)
my.data <- scale(my.data)
corr <- as.matrix(1 - cor(my.data))
my.data <- t(my.data)
euc <- as.matrix(dist(my.data))
plot(corr, (euc)^2, xlab="Correlation-Based Distance", ylab="Euclidean Distance",
    main = "Proportionality Between Correlation-Based and Euclidean Distances")

# This graph proves the proportionality between correlation-based distance and
# Euclidean distance because there is a direct, positive linear relationship 
# between their values.



##################### 
#### Question 3 #####
#####################

set.seed(5072)

### a ###
#  Generate simulated data
n <- 20
p <- 50
x1 <- matrix(rnorm(n*p), nrow=n, ncol=p)
x2 <- matrix(rnorm(n*p), nrow=n, ncol=p)
x3 <- matrix(rnorm(n*p), nrow=n, ncol=p)
for(i in 1:n){
  x1[i,] <- x1[i,] + rep(1, p)
  x2[i,] <- x2[i,] + rep(-1, p)
  x3[i,] <- x3[i,] + c(rep(+1, p / 2), rep(-1, p / 2))
}
x.values <- rbind(x1, x2, x3)


### b ###
#  Create vector "y.values"
y.values <- c(rep(1,n), rep(2,n), rep(3,n))


### c ###
Labels <- paste("Class", as.character(y.values), sep = " ")
mydata <- cbind(x.values, Labels)
pr.out2 <- prcomp(x.values)

autoplot(pr.out2, data = mydata, colour = "Labels", loadings = T, label=T, shape=F)


### d ###
km.out = kmeans(x.values,3)
# table(REAL=rev(y.values),CLUSTER=km.out$cluster)

# The k-3 cluster perfectly clustered the true class labels. 


### e ###
km.out2 = kmeans(x.values, 2)
# table(REAL=rev(y.values),CLUSTER=km.out2$cluster)

# The k-2 cluster correctly classified classes 1 and 2, and clustered class 3
# with class 1.


### f ###
km.out4 = kmeans(x.values, 4)
# table(REAL = rev(y.values), CLUSTER=km.out4$cluster)

# The k-4 cluster rightly grouped all class 3 variables into cluster 4 and
# class 2 variables into cluster 1. It had the hardest time classifying class 1 
# labels, and divided them among clusters 2 and 3.


### g ###
km.out.pca <- kmeans(pr.out2$x[,1:2], 3)
# table(REAL = rev(y.values), CLUSTER= km.out.pca$cluster)

# As with Q3 d, the k-3 cluster using the first two principal component score 
# vectors perfectly clustered the true class labels.

set.seed(5072)
### h ###
x.values.scale <- scale(x.values, center=F)
km.out.scale <- kmeans(x.values.scale, 3)
# table(REAL = rev(y.values), CLUSTER=km.out.scale$cluster)

# The k-3 cluster using the scaled values did the same as in part c. 
# It perfectly classified all three class levels into their own clusters.
