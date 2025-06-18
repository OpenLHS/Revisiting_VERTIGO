###############################################################################################################################################################

# PROJECT: VERTIGO and VERTIGO-CI implementation
# DOC:     Example illustrating the quantities known at the CC and at the local data nodes whilst running VERTIGO
# BY:      MPD, JPM
# DATE:    June 2025
# UPDATE:  --  

# License: https://creativecommons.org/licenses/by-nc-sa/4.0/
# Copyright: GRIIS / Université de Sherbrooke

###############################################################################################################################################################

RidgeLR_V_handler <- function(lambda = -1){
  
  #==============================================================================================================================================================
  # Beginning of "Algorithm 2: RIDGE-V: RIDGE logistic regression from Vertically partitioned data with no penalty on the intercept"
  #==============================================================================================================================================================
  #-------------------------------------------------------------------------------
  # Load required libraries
  #-------------------------------------------------------------------------------
  library(CVXR)
  
  #-------------------------------------------------------------------------------
  # Manual parameters for R implementation
  #-------------------------------------------------------------------------------
  # Should we save all quantities available at the local nodes?
  # If set to "TRUE", everything will be saved in "Outputs/Nodeek/"
  SaveNodes <- FALSE
  
  # Should we save all quantities available at the CC?
  # If set to "TRUE", everything will be saved in "Outputs/Coord/"
  SaveCC <- FALSE
  
  #-------------------------------------------------------------------------------
  # Inputs
  #-------------------------------------------------------------------------------
  
  # Load each node x^(k), k=1,..., K
  node_data1 <- read.csv("Data/Data_node_1.csv")
  node_data2 <- read.csv("Data/Data_node_2.csv")
  node_data3 <- read.csv("Data/Data_node_3.csv")
  
  # Scale data
  X1_scaled <- scale(as.matrix(node_data1))
  X2_scaled <- scale(as.matrix(node_data2))
  X3_scaled <- scale(as.matrix(node_data3))
  
  # Load shared response y
  # Note: It is expected that y_i \in {-1, 1}, not y_i \in {0, 1}.
  y <- read.csv("Data/outcome_data.csv")[,1]
  
  # Compute sample size
  n <- length(y)
  
  #Setting parameter lambda (penalty) for the algorithm 
  #Can be adjusted if needed, please refer to article to ensure adequate settings
  if(lambda==-1){
    if(n<=10000){
      lambda <- 0.0001
    }else{lambda <- 1/n}}
  
  if(lambda<=0){
    stop("The algorithm cannot run because the penalty parameter lambda was set lower or equal to 0.")
  }
  
  if(SaveNodes){
    # Node 1
    write.csv(X1_scaled, file = "Outputs/Node1/X1_scaled.csv", row.names = FALSE)
    write.csv(y, file = "Outputs/Node1/y.csv", row.names = FALSE)
    write.csv(lambda, file = "Outputs/Node1/lambda.csv", row.names = FALSE)
    
    # Node 2
    write.csv(X2_scaled, file = "Outputs/Node2/X2_scaled.csv", row.names = FALSE)
    write.csv(y, file = "Outputs/Node2/y.csv", row.names = FALSE)
    write.csv(lambda, file = "Outputs/Node2/lambda.csv", row.names = FALSE)
    
    # Node 3
    write.csv(X3_scaled, file = "Outputs/Node3/X3_scaled.csv", row.names = FALSE)
    write.csv(y, file = "Outputs/Node3/y.csv", row.names = FALSE)
    write.csv(lambda, file = "Outputs/Node3/lambda.csv", row.names = FALSE)
    
  }
  
  if(SaveCC){
    # CC
    write.csv(y, file = "Outputs/Coord/y.csv", row.names = FALSE)
    write.csv(lambda, file = "Outputs/Coord/lambda.csv", row.names = FALSE)
  }
  
  #-------------------------------------------------------------------------------
  # 1. Nodes: Compute the local matrix K^(k) and send to CC
  #-------------------------------------------------------------------------------
  K1 <- X1_scaled %*% t(X1_scaled)
  K2 <- X2_scaled %*% t(X2_scaled)
  K3 <- X3_scaled %*% t(X3_scaled)
  
  if(SaveNodes){
    # Node 1
    write.csv(K1, file = "Outputs/Node1/K1.csv", row.names = FALSE)
    
    # Node 2
    write.csv(K2, file = "Outputs/Node2/K2.csv", row.names = FALSE)
    
    # Node 3
    write.csv(K3, file = "Outputs/Node3/K3.csv", row.names = FALSE)
    
  }
  
  if(SaveCC){
    # CC
    write.csv(K1, file = "Outputs/Coord/K1.csv", row.names = FALSE)
    write.csv(K2, file = "Outputs/Coord/K2.csv", row.names = FALSE)
    write.csv(K3, file = "Outputs/Coord/K3.csv", row.names = FALSE)
  }
  
  #-------------------------------------------------------------------------------
  # 2. CC: Compute the global matrix K
  #-------------------------------------------------------------------------------
  K_all <- K1 + K2 + K3
  
  if(SaveCC){
    # CC
    write.csv(K_all, file = "Outputs/Coord/K_all.csv", row.names = FALSE)
  }
  
  #-------------------------------------------------------------------------------
  # 3. Do:
  #-------------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  # a. CC: Solve problem (15) using an algorithm adapted for equality constrained optimization
  #-----------------------------------------------------------------------------
  # Compute sample size
  n <- length(y)
  
  # State the optimization problem
  alpha <- Variable(n)
  Q <- 1/(2*lambda*n) * diag(y) %*% K_all %*% diag(y)
  
  objective <- Minimize(
    quad_form(alpha, Q) 
    - sum(entr(1-alpha) + entr(alpha))
  )
  
  constraint1 <- alpha >= 0
  constraint2 <- alpha <= 1
  constraint3 <- sum(y * alpha) == 0
  
  problem <- Problem(objective, constraints=list(constraint1, constraint2, constraint3))
  
  # Solve the optimization problem
  solution <- solve(problem)
  alpha_hat <- solution$getValue(alpha)[,1]
  
  #-------------------------------------------------------------------------------
  # 4. CC: Save optimal values alpha_hat
  #-------------------------------------------------------------------------------
  
  if(SaveCC){
    # CC
    write.csv(alpha_hat, file = "Outputs/Coord/alpha_hat.csv", row.names = FALSE)
  }
  
  #==============================================================================================================================================================
  # End of "Algorithm 2: RIDGE-V: RIDGE logistic regression from Vertically partitioned data with no penalty on the intercept"
  # For comparison purpose, we follow with some other steps in order to compute and share beta_hat
  #==============================================================================================================================================================
  #-------------------------------------------------------------------------------
  # 5. CC: Compute and send beta_0_hat to nodes. 
  #-------------------------------------------------------------------------------
  # Compute beta_0_hat  
  beta0_hat <- 1/y[1] * (log(1/alpha_hat[1] - 1) - y[1] * 1/(lambda*n) * (K_all %*% diag(alpha_hat) %*% y)[1])
  beta0_hat <- as.matrix(beta0_hat)
  rownames(beta0_hat) <- "(intercept)"
  
  if(SaveCC){
    # CC
    write.csv(beta0_hat, file = "Outputs/Coord/beta0_hat.csv", row.names = FALSE)
  }
  
  if(SaveNodes){
    # Node 1
    write.csv(beta0_hat, file = "Outputs/Node1/beta0_hat.csv", row.names = FALSE)
    
    # Node 2
    write.csv(beta0_hat, file = "Outputs/Node2/beta0_hat.csv", row.names = FALSE)
    
    # Node 3
    write.csv(beta0_hat, file = "Outputs/Node3/beta0_hat.csv", row.names = FALSE)
  }
  
  #-------------------------------------------------------------------------------
  # 6. CC: Send alpha_hat to nodes
  #-------------------------------------------------------------------------------
  if(SaveNodes){
    # Node 1
    write.csv(alpha_hat, file = "Outputs/Node1/alpha_hat.csv", row.names = FALSE)
    
    # Node 2
    write.csv(alpha_hat, file = "Outputs/Node2/alpha_hat.csv", row.names = FALSE)
    
    # Node 3
    write.csv(alpha_hat, file = "Outputs/Node3/alpha_hat.csv", row.names = FALSE)
  }
  
  #-------------------------------------------------------------------------------
  # 7. Nodes: Calculate beta_hat^(k) and send it to CC
  #-------------------------------------------------------------------------------
  beta_node_1 <- 1/(lambda*n) * t(X1_scaled) %*% diag(alpha_hat) %*% y
  beta_node_2 <- 1/(lambda*n) * t(X2_scaled) %*% diag(alpha_hat) %*% y
  beta_node_3 <- 1/(lambda*n) * t(X3_scaled) %*% diag(alpha_hat) %*% y
  
  if(SaveCC){
    # CC
    write.csv(beta_node_1, file = "Outputs/Coord/beta_node_1.csv", row.names = FALSE)
    write.csv(beta_node_2, file = "Outputs/Coord/beta_node_2.csv", row.names = FALSE)
    write.csv(beta_node_3, file = "Outputs/Coord/beta_node_3.csv", row.names = FALSE)
  }
  
  if(SaveNodes){
    # Node 1
    write.csv(beta_node_1, file = "Outputs/Node1/beta_node_1.csv", row.names = FALSE)
    
    # Node 2
    write.csv(beta_node_2, file = "Outputs/Node2/beta_node_2.csv", row.names = FALSE)
    
    # Node 3
    write.csv(beta_node_3, file = "Outputs/Node3/beta_node_3.csv", row.names = FALSE)
  }
  
  # Format and save output
  write.csv(rbind(beta0_hat, beta_node_1, beta_node_2, beta_node_3), file = "RidgeLR-V_output.csv", row.names = FALSE)
}
