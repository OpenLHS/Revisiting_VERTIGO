###############################################################################################################################################################

# PROJECT: VERTIGO and VERTIGO-CI implementation
# DOC:     Example illustrating the quantities known at the CC and at the local data nodes whilst running VERTIGO
# BY:      MPD, JPM
# DATE:    June 2025
# UPDATE:  --  

# License: https://creativecommons.org/licenses/by-nc-sa/4.0/
# Copyright: GRIIS / Université de Sherbrooke

###############################################################################################################################################################

glmnet_handler <- function(lambda = -1){
  
  #-------------------------------------------------------------------------------
  # Load required libraries
  #-------------------------------------------------------------------------------
  library(glmnet)
  
  #-------------------------------------------------------------------------------
  # Inputs
  #-------------------------------------------------------------------------------
  # Load each node x^(k), k=1,..., K
  node_data1 <- read.csv("Data/Data_node_1.csv")
  node_data2 <- read.csv("Data/Data_node_2.csv")
  node_data3 <- read.csv("Data/Data_node_3.csv")
  
  # Load shared response y
  # Note: It is expected that y_i \in {-1, 1}, not y_i \in {0, 1}.
  y <- read.csv("Data/outcome_data.csv")[,1]
  n <- length(y)
  
  # Note: Predictor values should be scaled since we are doing a ridge regression
  X1_scaled <- scale(node_data1)
  X2_scaled <- scale(node_data2)
  X3_scaled <- scale(node_data3)
  
  # Create disturbed intercept so glmnet doesn't automatically drop this variable
  intercept <- rep(1,n)+rnorm(n, sd = 1e-7)
  
  # Pool data together
  pooled_data <- cbind(X1_scaled, X2_scaled, X3_scaled)
  
  #Setting parameter lambda (penalty) for the algorithm 
  #Can be adjusted if needed, please refer to article to ensure adequate settings
  if(lambda==-1){
    if(n<=10000){
      lambda <- 0.0001
    }else{lambda <- 1/n}}
  
  if(lambda<=0){
    stop("The algorithm cannot run because the penalty parameter lambda was set lower or equal to 0.")
  }
  
  #-------------------------------------------------------------------------------
  # Model and outputs
  #-------------------------------------------------------------------------------
  # Pooled model
  glmnet_model <- glmnet(pooled_data, (y+1)/2, family=binomial, lambda=lambda, alpha=0, standardize=FALSE)

  # Format and save output
  write.csv(coef(glmnet_model)[,1], file = "glmnet_output.csv", row.names = FALSE)
}
