###################################################################################################################################################

# PROJECT: VERTIGO and VERTIGO-CI implementation
# DOC:     Example illustrating the issue with binary covariates held at a single data node
# BY:      FCL, JPM
# DATE:    June 2025
# UPDATE:  --  

# License: https://creativecommons.org/licenses/by-nc-sa/4.0/
# Copyright: GRIIS / Université de Sherbrooke

####################################################################################################################################################

rm(list=ls())

#-------------------------------------------------------------------------------
# Useful functions
#-------------------------------------------------------------------------------
# Function to convert an integer to binary vector of length p, with MSB first
int_to_bin_msb_first <- function(x, p) {
  rev(as.integer(intToBits(x))[1:p])
}

# Function to generate the p x p binary matrix with MSB first
generate_binary_matrix_msb_first <- function(p) {
  X <- matrix(0, nrow = 2^p, ncol = p)
  for (i in 1:2^p) {
    X[i, ] <- int_to_bin_msb_first(i, p)
  }
  return(X)
}

#-------------------------------------------------------------------------------
# Load data
#-------------------------------------------------------------------------------
# CC has access to:
lambda <- read.csv("Outputs/Coord/lambda.csv")[,1]
y <- read.csv("Outputs/Coord/y.csv")
alpha_hat <- read.csv("Outputs/Coord/alpha_hat.csv")[,1]
beta_1_hat <- as.matrix(read.csv("Outputs/Coord/beta_node_1.csv"))
K1 <- as.matrix(read.csv("Outputs/Coord/K1.csv"))

# CC can know p_k the size of beta_k_hat
p1 <- length(beta_1_hat)

#-------------------------------------------------------------------------------
# Recovering X from data available at the CC after running VERTIGO
#-------------------------------------------------------------------------------
# Generate the set U(beta_1_hat): A matrix containing all possible combinations
# of 0s and 1s in X^(1)
Potential_rows <- generate_binary_matrix_msb_first(p1)   

# Compute all possible values of xi*beta_1_hat, where xi is an individual with
# binary features
U <- Potential_rows %*% t(beta_1_hat)

# verify if the cardinality of U = 2^p; if not, this technique won't necessarily 
# allow to recover X^(1)
if(!(length(unique(U)) == 2^p1)){
  print(paste0("The cardinality of U is smaller than 2^p. It it not guaranteed that we can recover X." )) 
}

# Compute the values of X_1*beta_1_hat, using formula 22 (and multiplying by X on the LHS)
XB <- 1/(lambda) * K1 %*% as.matrix((y*alpha_hat))

## rounding both U and XB for comparisons
Ur <- round(U,3)
XBr <- round(XB,3)

# Find which rows if U might be the true rows of X
matchindex <- (sapply(XBr,function(x){which(Ur==x)}))
is.na(matchindex) <- lengths(matchindex) == 0
index_identified <- unlist(matchindex)

# Recover X using the rows identified previously
X_recovered <- Potential_rows[index_identified,]

#-------------------------------------------------------------------------------
# Compare recovered data with true data
#-------------------------------------------------------------------------------
# Load true data
X1 <- as.matrix(read.csv("Outputs/Node1/X1.csv"))

# Compare matrices
all.equal(X_recovered, X1, check.attributes=FALSE)
