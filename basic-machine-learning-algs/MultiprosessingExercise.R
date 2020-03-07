rm(list=ls())
##########################################################################################
### Functions
##########################################################################################
installIfAbsentAndLoad <- function(neededVector) {
  for(thepackage in neededVector) {
    if( ! require(thepackage, character.only = TRUE) )
    { install.packages(thepackage)}
    require(thepackage, character.only = TRUE)
  }
}
needed <- c('randomForest', 'doParallel', 'snow')      
installIfAbsentAndLoad(needed)
###Get the data
churndata<-read.table("churndata.csv",sep=",",header=T)
###Clean up, change area code to a factor
data <- na.omit(churndata)
data$area<-factor(data$area)
nTimes <- 5
##########################################################
## Part 1 
##########################################################
### Grow 1000-tree forest nTimes times WITHOUT 
### multiprocessing enabled, capturing timing information 
### about the process in a variable called 
### p.time.UP. Here's the code to grow one forest:

p.time.UP <- system.time({
  for ( i in 1:nTimes ){
    rf <- randomForest(formula=churn ~ .,
                       data=churndata,
                       ntree=1000, 
                       mtry=4,
                       importance=TRUE,
                       localImp=TRUE,
                       na.action=na.roughfix,
                       replace=FALSE)
  }
})

# user = 84.22;  system = 0.23;  elapsed = 85.05

##########################################################
## Part 2 
##########################################################
# Enable Parallel Processing
registerDoParallel(cores=detectCores())

##########################################################
## Part 3 
##########################################################
### Regrow the 1000-tree forest nTimes times, again capturing
### timing information about the process in a variable called
### p.time.tryMP.
p.time.tryMP <- system.time({
  for ( i in 1:nTimes ){
    rf <- randomForest(formula=churn ~ .,
                       data=churndata,
                       ntree=1000, 
                       mtry=4,
                       importance=TRUE,
                       localImp=TRUE,
                       na.action=na.roughfix,
                       replace=FALSE)
  }
})

#user = 78.95;  system = 0.31;  elapsed = 79.96

##########################################################
#Part 4 
########################################################## 
#Does the randomForest function use MP features when they
#are enabled? (Yes/No)
p.time.UP
p.time.tryMP

# No


##########################################################
#Part 5 
########################################################## 
# Use a foreach() loop with %dopar% to regrow the 1000-tree 
# forest nTimes times, again capturing timing information 
# about the process in a variable called p.time.useMP.
#
# IMPORTANT NOTE: R implements multiprocessing by creating 
# new instances of R in which to run each parallel precess. 
# Consequently, packages required within the %dopar% loop
# must be reloaded in each such instance. A vector of package
# names can be specified using the .packages= parameter of
# the foreach() function. Note the "dot" in .packages =

ncores<-detectCores()

registerDoParallel(cores = ncores)

p.time.useMP <- system.time({
  foreach(i=1:ncores, .packages = 'randomForest') %dopar% {
    for(j in 1:nTimes) {
      rf <- randomForest(formula=churn ~ .,
                         data=churndata,
                         ntree=1000, 
                         mtry=4,
                         importance=TRUE,
                         localImp=TRUE,
                         na.action=na.roughfix,
                         replace=FALSE)
    }
  }
})

#user = 0.44;  system = 0.56;  elapsed = 120.81

########################################################## 
#Part 6 
########################################################## 
# Display the time taken for this latest test. What was your
# (approximate) improvement factor?

p.time.UP
p.time.useMP

# There was a significant decrease in user time, but there was an
# increase in my system and elapsed time. Elapsed time went up 
# almost 150%.

########################################################## 
#Part 7 
########################################################## 
# Disable Parallel Processing
registerDoSEQ()
