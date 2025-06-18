###############################################################################################################################################################

# PROJECT: VERTIGO and VERTIGO-CI implementation
# DOC:     Example illustrating the quantities known at the CC and at the local data nodes whilst running VERTIGO-CI
# BY:      MPD, JPM
# DATE:    June 2025
# UPDATE:  --  

# License: https://creativecommons.org/licenses/by-nc-sa/4.0/
# Copyright: GRIIS / Université de Sherbrooke

###############################################################################################################################################################

#-------------------------------------------------------------------------------
# Parameters
#-------------------------------------------------------------------------------
# Setting parameter lambda (penalty) for the algorithm 
manual_lambda = 0.3

#-------------------------------------------------------------------------------
# Source methods
#-------------------------------------------------------------------------------
source("glmnet_handler.R")
source("RidgeLR-V_handler.R")
source("VERTIGO_handler.R")

#-------------------------------------------------------------------------------
# Run each method
#-------------------------------------------------------------------------------
glmnet_handler(lambda = manual_lambda)
RidgeLR_V_handler(lambda = manual_lambda)
VERTIGO_handler(lambda = manual_lambda)

#-------------------------------------------------------------------------------
# Read and format all outputs
#-------------------------------------------------------------------------------
# Load output from each method
results.glmnet <- read.csv("glmnet_output.csv")
results.RidgeLR_V <- read.csv("RidgeLR-V_output.csv")
results.VERTIGO <- read.csv("VERTIGO_output.csv")

# Combine outputs in a single object
output <- cbind(results.glmnet, results.RidgeLR_V, results.VERTIGO$beta)
colnames(output) <- c("glmnet", "RidgeLR-V", "VERTIGO")
rownames(output) <- results.VERTIGO$X

# Show results in console
print(output)
