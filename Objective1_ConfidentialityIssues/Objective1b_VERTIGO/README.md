# Objective 1b: Possible data breach when using binary features

## Data

The folder data contains the data nodes and outcome data used to run this example. These `.csv` files were created using a publicly available dataset that was previously analyzed in the original VERTIGO-CI paper.

## Running the demonstration

1. Run the content of the `Run_VERTIGO.R` file. This will create many new `.csv` files:
	- Some generic files related to the iteration process will be saved in the main folder.
	- If the parameter `SaveCC` is set to `TRUE`, all information available at the CC will be saved in `Outputs/Coord`.
	- If the parameter `SaveNodes` is set to `TRUE`, all information available at the node `k` will be saved in `Outputs/Nodek`.
	
2. Run the content of the `RecoverData_Binary.R` file. In the console, you will see once instance of  the call `all.equal`, which correspond to testing if the data recovered by the CC is the same as the binary data from node `1`. If `TRUE`, the CC was able to recover the original data.
