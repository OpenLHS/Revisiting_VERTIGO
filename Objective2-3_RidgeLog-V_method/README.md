# Objective 2-3: RidgeLog-V method

This folder contains an implementation of an alternative approach (RidgeLog-V) that is more communication efficient and which excludes the intercept from the penalty in the ridge regression logistic regression.

## Data

The folder data contains the data nodes and outcome data used to run this example. These `.csv` files were created using a publicly available dataset that was previously analyzed in the original VERTIGO-CI paper.

## Running the example

1. Run the content of the `Run_RidgeLog-V.R` file. The coefficient estimates will be printed in the console. This will also create many new `.csv` files:
	- Some generic files related to the iteration process will be saved in the main folder.
	- If the parameter `SaveCC` is set to `TRUE`, all information available at the CC will be saved in `Outputs/Coord`.
	- If the parameter `SaveNodes` is set to `TRUE`, all information available at the node `k` will be saved in `Outputs/Nodek`.
	