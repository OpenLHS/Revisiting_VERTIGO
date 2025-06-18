# Objective 1a: Confidentiality issues associated with VERTIGO-CI

## Data

The folder data contains the data nodes and outcome data used to run this example. These `.csv` files were created using a publicly available dataset that was previously analyzed in the original VERTIGO-CI paper.

## Running the demonstration

1. Run the content of the `Run_VERTIGO-CI.R` file. This will create many new `.csv` files:
	- Some generic files related to the iteration process will be saved in the main folder.
	- If the parameter `SaveCC` is set to `TRUE`, all information available at the CC will be saved in `Outputs/Coord`.
	- If the parameter `SaveNodes` is set to `TRUE`, all information available at the node `k` will be saved in `Outputs/Nodek`.
	
2. There are two methods to recover the nodes original data.
	1. Run the content of `RecoverData_Method1.R`. In the console, you will see three instances of  the call `all.equal`, which correspond to testing if the data recovered by the CC is the same as the original data from node `k`. If `TRUE`, the CC was able to recover the original data.
	2. Run the content of `RecoverData_Method2.R`. In the console, you will see three instances of  the call `all.equal`, which correspond to testing if the data recovered by the CC is the same as the original data from node `k`. If `TRUE`, the CC was able to recover the original data.