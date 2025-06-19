# Method comparisons

This folder can be used to quickly compared the results of the following methods:
- glmnet
- RidgeLog-V
- VERTIGO

## Data

The folder data contains the data nodes and outcome data used to run this example. These `.csv` files were created using a publicly available dataset that was previously analyzed in the original VERTIGO-CI paper.

## Running the comparison

0. If needed, change the value of the parameter `manual_lambda` in the `Run_Comparison.R` file. Each method will use the same value of `manual_lambda`.

1. Run the content of the `Run_Comparison.R` file. The coefficient estimates from each method will be printed in the console. A `.csv` containing the output of a method will also be saved for each method ran.