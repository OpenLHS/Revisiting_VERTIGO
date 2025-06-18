# Data

This folder data contains the data nodes and outcome data used to run this example. These `.csv` files were created using a publicly available dataset that was previously analyzed in the original VERTIGO-CI paper.

## Publicly available dataset

The dataset provided is taken from the R package [aplore3](https://cran.r-project.org/web/packages/aplore3/index.html) (Hosmer, D.W., Lemeshow, S. and Sturdivant, R.X. (2013) Applied Logistic Regression, 3rd ed., New York: Wiley). It is the burn1000 dataset.

## Data transformation

Categorical variables were recoded according to the original VERTIGO-CI paper.

## Spliting the data

The dataset was chosen to be splitted vertically into two data nodes:
- Node 1: gener, race, inh_inj, flame (which are all binary features)
- Node 2: facility, age, tbsa (of which none are binary features)

All variable names refer to the burn1000 dataset.
