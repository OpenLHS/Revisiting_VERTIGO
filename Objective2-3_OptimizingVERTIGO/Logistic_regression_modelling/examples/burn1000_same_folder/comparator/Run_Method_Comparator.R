############### VERTICALLY DISTRIBUTED LOGISTIC REGRESSION ####################

## License: https://creativecommons.org/licenses/by-nc-sa/4.0/
## Copyright: GRIIS / Université de Sherbrooke

# Libraries
library(this.path)

# Run VERTIGO-CI 
setwd(this.dir())
setwd("../../../../../Objective1_ConfidentialityIssues/Objective1a_VERTIGO-CI/")
source("Run_VERTIGO-CI.R")

# Run RIDGE_V
setwd(this.dir())
setwd("../distributed/")
source("Run_Example.R")


# Load VERTIGO-CI output
setwd(this.dir())
setwd("../../../../../Objective1_ConfidentialityIssues/Objective1a_VERTIGO-CI/")
VERTIGO_CI_output <- read.csv("VERTIGO_CI_output.csv")
VERTIGO_CI_output <- VERTIGO_CI_output[,-3]

# Load and combine RIDGE-V outputs
setwd(this.dir())
setwd("../distributed/")
RidgeV_CC_output <- read.csv("Coord_node_results_distributed_log_regV.csv")
RidgeV_Node1_output <- read.csv("Data_node_1_results.csv")
RidgeV_Node2_output <- read.csv("Data_node_2_results.csv")
RidgeV_Node3_output <- read.csv("Data_node_3_results.csv")

#RidgeV_combined_output <- as.data.frame(c("intercept")) %>% 
#  mutate(betak_hat = RidgeV_CC_output[1,2])

RidgeV_combined_output <- rbind(c("intercept", RidgeV_CC_output[1,2]), RidgeV_Node1_output, RidgeV_Node2_output, RidgeV_Node3_output) # attention type de données ici
VERTIGO_CI_output

# Run glmnet
setwd(this.dir())
setwd("../pooled/")
source("Run_Pooled_Example.R")
