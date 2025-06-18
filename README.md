# Revisiting_VERTIGO

This repository is additionnal material for the article *Revisiting VERTIGO and VERTIGO-CI:  Identifying confidentiality breaches and introducing a statistically sound, efficient alternative* by Domingue et al.

## Objective1_ConfidentialityIssues
We numerically demonstrate how vector-matrix operations can be used by the CC to reconstruct data from other nodes using shared quantities after running the VERTIGO or VERTIGO-CI method.

## Objective2-3_RidgeLR-V_method
This folder contains an implementation of an alternative approach (RidgeLR-V) that is more communication efficient and which excludes the intercept from the penalty in the ridge regression logistic regression.

## Comparison
This folder can be used to quickly compared the results of the following methods:
- glmnet
- RidgeLR-V
- VERTIGO