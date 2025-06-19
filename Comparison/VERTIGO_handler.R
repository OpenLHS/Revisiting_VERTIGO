###############################################################################################################################################################

# PROJECT: VERTIGO and VERTIGO-CI implementation
# DOC:     Example illustrating the quantities known at the CC and at the local data nodes whilst running VERTIGO-CI
# BY:      MPD, JPM
# DATE:    June 2025
# UPDATE:  --  

# License: https://creativecommons.org/licenses/by-nc-sa/4.0/
# Copyright: GRIIS / Université de Sherbrooke

###############################################################################################################################################################

VERTIGO_handler <- function(lambda = -1, epsilon = 1e-5){
  
  #==============================================================================================================================================================
  # Beginning of "Algorithm 3: VERTIGO Original"
  #==============================================================================================================================================================
  
  #-------------------------------------------------------------------------------
  # Manual parameters for R implementation
  #-------------------------------------------------------------------------------
  # Should we save all the following quantities in a .csv file?
  # - Nodes:
  #     |> partial gradient
  # - CC: 
  #     |> alpha_s 
  SaveAll <- FALSE
  
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
  
  # Note: Predictor values should be scaled since we are doing a ridge regression
  X1_scaled <- scale(node_data1)
  X2_scaled <- scale(node_data2)
  X3_scaled <- scale(node_data3)
  
  # Note: It is expected that the last data node will hold a column of 1s in order to estimate the intercept
  X3_scaled <- cbind(X3_scaled, rep(1, nrow(X3_scaled)))
  
  # Load shared response y
  # Note: It is expected that y_i \in {-1, 1}, not y_i \in {0, 1}.
  y <- read.csv("Data/outcome_data.csv")[,1]
  
  # Compute sample size
  n <- length(y)
  
  # Fix initial solution alpha_s, s=0
  alpha_s <- matrix(data = 0.5, nrow = length(y), ncol = 1)
  
  #Setting parameter lambda (penalty) for the algorithm 
  #Can be adjusted if needed, please refer to article to ensure adequate settings
  if(lambda==-1){
    if(n<=10000){
      lambda <- 0.0001
    }else{lambda <- 1/n}}
  
  if(lambda<=0){
    stop("The algorithm cannot run because the penalty parameter lambda was set lower or equal to 0.")
  }
  
  # Make sure the lambda we use for VERTIGO is equivalent to the one used in glmnet/RidgeLR-V
  lambda <- lambda*n
  
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
  # Initialize convergence boolean
  converged = FALSE
  nb_iter <- 0
  
  # Initialize list of alpha values
  alpha_list = alpha_s
  
  # Initialize list of partial gradients
  e_1_list <- matrix(0, nrow = length(alpha_s), ncol = 1)
  e_2_list <- matrix(0, nrow = length(alpha_s), ncol = 1)
  e_3_list <- matrix(0, nrow = length(alpha_s), ncol = 1)
  
  while(!converged){
    #-----------------------------------------------------------------------------
    # a. Nodes: Compute e^(k)(alpha_s) and send it to CC
    #-----------------------------------------------------------------------------
    e_1 <- 1/lambda *  diag(y) %*% X1_scaled %*% t(X1_scaled) %*% diag(y) %*% alpha_s
    e_2 <- 1/lambda *  diag(y) %*% X2_scaled %*% t(X2_scaled) %*% diag(y) %*% alpha_s
    e_3 <- 1/lambda *  diag(y) %*% X3_scaled %*% t(X3_scaled) %*% diag(y) %*% alpha_s
    
    e_1_list <- cbind(e_1_list, e_1)
    e_2_list <- cbind(e_2_list, e_2)
    e_3_list <- cbind(e_3_list, e_3)
    
    #-----------------------------------------------------------------------------
    # b. CC: Calculate e_s = sum e^(k)(alpha_s) and the gradient of J^lambda(alpha_s)
    #-----------------------------------------------------------------------------
    # Compute the sum of e^(k)(alpha_s)
    e_s <- e_1 + e_2 + e_3
    
    # Compute the gradient of J^lambda(alpha_s)
    gradient_J <- e_s + log( alpha_s/(1-alpha_s) )
    
    #-----------------------------------------------------------------------------
    # c. CC: Compute the hessian matrix H(alpha_s) 
    #-----------------------------------------------------------------------------
    Hessian <- 1/lambda * diag(y) %*% K_all %*% diag(y) + diag( 1/(alpha_s[,1]*(1-alpha_s[,1])) )
    
    #-----------------------------------------------------------------------------
    # d. CC: Update alpha_s and send update to nodes
    #-----------------------------------------------------------------------------
    # Update parameters alpha through NR step
    alpha_new <- alpha_s - solve(Hessian, gradient_J)
    
    # Note: As alpha_i \in (0, 1), we need to make sure that no values are out of bounds
    alpha_new[which(alpha_new<0)] <- 0.000000001
    alpha_new[which(alpha_new>1)] <- 0.999999999
    
    # Compare new alpha to current one. Did we converge?
    if(norm(alpha_new - alpha_s, type = "2")<epsilon){
      converged = TRUE
    }
    
    # Update alpha and counter
    alpha_s <- alpha_new
    nb_iter <- nb_iter + 1
    
    # Update list of alpha
    alpha_list <- cbind(alpha_list, alpha_new)
  }
  
  # Change colnames for better readability (partial gradients lists)
  colnames(e_1_list) <- paste0("Iter_", 0:(ncol(alpha_list)-1))
  colnames(e_2_list) <- paste0("Iter_", 0:(ncol(alpha_list)-1))
  colnames(e_3_list) <- paste0("Iter_", 0:(ncol(alpha_list)-1))
  
  # Change colnames for better readability (alpha_s list)
  colnames(alpha_list) <- paste0("Iter_", 0:(ncol(alpha_list)-1))
  
  if(SaveAll){
    # Save all values of partial gradients for all recorded iterations
    write.csv(e_1_list, file = "List_e_1_s.csv", row.names = FALSE)
    write.csv(e_2_list, file = "List_e_2_s.csv", row.names = FALSE)
    write.csv(e_3_list, file = "List_e_3_s.csv", row.names = FALSE)
  }
  
  if(SaveNodes){
    # Node 1
    write.csv(e_1_list, file = "Outputs/Node1/List_e_1_s.csv", row.names = FALSE)
    
    # Node 2
    write.csv(e_2_list, file = "Outputs/Node2/List_e_2_s.csv", row.names = FALSE)
    
    # Node 3
    write.csv(e_3_list, file = "Outputs/Node3/List_e_3_s.csv", row.names = FALSE)
  }
  
  if(SaveCC){
    # CC
    write.csv(e_1_list, file = "Outputs/Coord/List_e_1_s.csv", row.names = FALSE)
    write.csv(e_2_list, file = "Outputs/Coord/List_e_2_s.csv", row.names = FALSE)
    write.csv(e_3_list, file = "Outputs/Coord/List_e_3_s.csv", row.names = FALSE)
  }
  
  #-------------------------------------------------------------------------------
  # 4. CC: Save optimal values alpha_hat
  #-------------------------------------------------------------------------------
  alpha_hat <- alpha_s
  
  if(SaveAll){
    # Save values of alpha_s for all recorded iterations
    write.csv(alpha_list, file = "List_alpha_s.csv", row.names = FALSE)
  }
  
  #==============================================================================================================================================================
  # End of "Algorithm 3: VERTIGO Original"
  # We follow with the rest of "Algorithm 4: VERTIGO-CI Original"
  #==============================================================================================================================================================
  #-------------------------------------------------------------------------------
  # 5. CC: Send alpha_hat to nodes
  #-------------------------------------------------------------------------------
  
  if(SaveNodes){
    # Node 1
    write.csv(alpha_hat, file = "Outputs/Node1/alpha_hat.csv", row.names = FALSE)
    
    # Node 2
    write.csv(alpha_hat, file = "Outputs/Node2/alpha_hat.csv", row.names = FALSE)
    
    # Node 3
    write.csv(alpha_hat, file = "Outputs/Node3/alpha_hat.csv", row.names = FALSE)
  }
  
  if(SaveCC){
    # CC
    write.csv(alpha_hat, file = "Outputs/Coord/alpha_hat.csv", row.names = FALSE)
  }
  
  #-------------------------------------------------------------------------------
  # 6. Nodes (all but last): Calculate beta_hat^(k) and send it to CC
  #-------------------------------------------------------------------------------
  beta_node_1 <- 1/lambda * t(alpha_hat) %*% diag(y) %*% X1_scaled 
  beta_node_2 <- 1/lambda * t(alpha_hat) %*% diag(y) %*% X2_scaled 
  
  if(SaveNodes){
    # Node 1
    write.csv(beta_node_1, file = "Outputs/Node1/beta_node_1.csv", row.names = FALSE)
    
    # Node 2
    write.csv(beta_node_2, file = "Outputs/Node2/beta_node_2.csv", row.names = FALSE)
  }
  
  if(SaveCC){
    # CC
    write.csv(beta_node_1, file = "Outputs/Coord/beta_node_1.csv", row.names = FALSE)
    write.csv(beta_node_2, file = "Outputs/Coord/beta_node_2.csv", row.names = FALSE)
  }
  
  #-------------------------------------------------------------------------------
  # 7. Last node: Calculate beta_0_hat and beta_hat^(K) and send them to CC.
  #-------------------------------------------------------------------------------
  beta_node_3 <- 1/lambda * t(alpha_hat) %*% diag(y) %*% X3_scaled 
  beta_0 <- 1/lambda * sum(alpha_hat*y)
  
  if(SaveNodes){
    # Node 3
    write.csv(beta_node_3, file = "Outputs/Node3/beta_node_3.csv", row.names = FALSE)
    write.csv(beta_0, file = "Outputs/Node3/beta_0.csv", row.names = FALSE)
  }
  
  if(SaveCC){
    # CC
    write.csv(beta_node_3, file = "Outputs/Coord/beta_node_3.csv", row.names = FALSE)
    write.csv(beta_0, file = "Outputs/Coord/beta_0.csv", row.names = FALSE)
  }
  
  # Format and save output
  beta <- c(beta_0, beta_node_1, beta_node_2, beta_node_3[-length(beta_node_3)])
  output <- cbind(beta)
  rownames(output) <- c("intercept", colnames(node_data1), colnames(node_data2), colnames(node_data3))
  write.csv(output, file = "VERTIGO_output.csv", row.names = TRUE)
  
}