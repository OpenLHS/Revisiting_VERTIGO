###############################################################################################################################################################

# PROJECT: VERTIGO and VERTIGO-CI implementation
# DOC:     Extracting nodes' data in .csv files
# BY:      MPD, JPM
# DATE:    June 2025
# UPDATE:  --  

# License: https://creativecommons.org/licenses/by-nc-sa/4.0/
# Copyright: GRIIS / Université de Sherbrooke

###############################################################################################################################################################

#==============================================================================================================================================================
# Data files creation
#==============================================================================================================================================================

rm(list=ls())

#-------------------------------------------------------------------------------
# Load libraries
#-------------------------------------------------------------------------------
library(aplore3)      # For the burn1000 dataset
library(tidyverse)    # For data manipulation

#-------------------------------------------------------------------------------
# Load and transform data
#-------------------------------------------------------------------------------
# Remove the "id" column
# Transform factors to numeric variables
df <- burn1000 %>% 
  select(-id) %>%
  mutate(death = case_when(death=="Alive"~0,
                           death=="Dead"~1)) %>% 
  mutate(gender = case_when(gender=="Male"~1,
                            gender=="Female"~0)) %>% 
  mutate(race = case_when(race=="White"~1,
                          race=="Non-White"~0)) %>% 
  mutate(inh_inj = case_when(inh_inj=="Yes"~1,
                             inh_inj=="No"~0)) %>% 
  mutate(flame = case_when(flame=="Yes"~1,
                           flame=="No"~0))

# Save the outcome by itself
# Note: It is expected that y_i \in {-1, 1}, not y_i \in {0, 1}.
y <- df %>% 
  select(death) %>% 
  mutate(y = 2*death-1) %>% 
  select(-death)

# Remove outcome from the dataset
df <- df %>% 
  select(-death) 

# Create data nodes
df_bin <- df %>% 
  select(gender, race, inh_inj, flame)
df_cont <- df %>% 
  select(facility, age, tbsa)

# Save to .csv
write.csv(df_bin, file = "Data_node_1.csv", row.names = FALSE)
write.csv(df_cont, file = "Data_node_2.csv", row.names = FALSE)
write.csv(y, file = "outcome_data.csv", row.names = FALSE)
