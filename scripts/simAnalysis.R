write.csv(db, 'input/sim.csv')


#set seed
set.seed(230425)

# libraries 
library(rethinking)

# loading the data
db <- read.csv('input/sim.csv')

# 