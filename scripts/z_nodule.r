#set seed
set.seed(230530)

# libraries 
library(rethinking)
library(tidyverse)

# loading the data
db <- read.csv('input/sim.csv')
head(db)
