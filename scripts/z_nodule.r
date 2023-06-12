#set seed
set.seed(230530)

# libraries 
library(rethinking)
library(tidyverse)

# loading the data
dbs <- read.csv('input/simshort.csv')
dbl <- read.csv('input/sim.csv')
head(dbl)

maxjmax <- max(dbs$jmax) # number of 'i' cols

dat <- list ( 
  A = db$A,
  B = db$B,
  I = db$i,
  k = db$k,
  j = db$j,
  E = db$E,
  V = db$V,
  jmax = db$jmax,
  kmax = max(db$k),
  p = which(db$j==1),
  n_row = nrow(db)
)


m <- cstan( file = 'scripts/N_model.stan', data = dat, chains = 1, cores = 1, iter = 500 )

post <- extract.samples(m)
saveRDS(post, file = "output/post.rds")
