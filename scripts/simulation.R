# set seed
set.seed(230412) 

# set the patient number that correspond to the patient's ID
N <- 1e4
k <- 1:N

# let's start from the number of new clones j for each patient
# let's also assume that j is a function of the background liver disease (B)
# and the time the patient has it (Tj); the latter is itself a function of 
# the patient's age.

# so starting from the age (A) it can be simulated as a normal distribution

A <- rnorm( n = N, mean = 0, sd = 1 ) 

# this values can also be used as priors if the age is standardized (see ?scale )
# next we can simulate the Tj that in the model will be a latent variable

Tj <- rnorm( n = N , mean = A, sd = 1)

# background liver disease 
# looking at the DB I had some difficulty to find something clear
# therefore for the time being I used a normal distribution
# fibrosis 0-4
# inflammation 0-3
# about 10% missing data.

## TO DISCUSS ##

B <- rnorm( n = N, mean = 0, sd = 1 )

# now we can simulate the number of new clones for each patient
# the number of nodules can be simulated with a zero truncated Poisson 
# distribution and as a link a exponential function 

# the coefficients value can be changed but are chosen to provide
# here we select some value trough prior predictive simulation
# see the graphical check
alpha_j <-  rnorm( n = N, mean = 0.2, sd = 0.2 )
beta_j <- rnorm( n = N, mean = 0.3, sd = 0.1 )
gamma_j <- rnorm( n = N, mean = 0, sd = 0.1 )
lm <- alpha_j + beta_j * B + gamma_j * Tj
lambda <- exp( lm )
j <- actuar::rztpois(n = N, lambda = lambda)

# a quick graphical check 
d_j <- density(j)
plot(d_j)

# so up to now we simulated the number of new clones for each patient
# however the total number of nodules depends also from the intra-hepatic 
# metastases of each clone j of each patient k

# to estimate the metastatic potential of each clone j of each patient k 
# let's prepare a matrix both for the EMT and the VETC

col.max <- max(j) # the columns needs to be the max of j

# we will store the EMT of each clone in the matrix Ekj
# let's suppose that the EMT will be present in a 20% of clones
# FOR GINA to CHECK #

Ekj <- matrix( data = NA, nrow = N, ncol = col.max)
for ( i in k ) {
  for( ii in 1 : j[ i ] ){
    Ekj[ i, ii ] <-  rbinom( n = 1, size = 1 , prob = 0.2 ) 
  }
}

# now let's do the same for VETC
# let's suppose that the VETC will be present in a 30% of clones

Vkj <- matrix( data = NA, nrow = N, ncol = col.max)
for ( i in k ) {
  for( ii in 1 : j[ i ] ){
    Vkj[ i, ii ] <-  rbinom( n = 1, size = 1 , prob = 0.3 ) 
  }
}


# then there will be a time for each clone to metastasize 
# and it will be a function of the patient's age

Ti_kj <- matrix( data = NA, nrow = N, ncol = col.max)
for ( i in k ) {
  for( ii in 1 : j[ i ] ){
    Ti_kj[ i, ii ] <-  rnorm( n = 1 , mean = A[i], sd = 1) 
  }
}

# now let simulate the number of intrahepatic mets for each clone
# we will use a Poisson distribution 
# keeping the simulation 
alpha_ji <- 0.1
beta_ji <- 0.05
gamma_ji <- 0.05


i_kj <- matrix( data = NA, nrow = N, ncol = col.max)
for ( i in k ) {
  for( ii in 1 : j[ i ] ){
    lm <- alpha_ji +  
      beta_ji * (Ekj [i,ii] + Vkj [i, ii]) +
      gamma_j * Ti_kj[ i, ii ]
    lambda <- exp( lm )
    i_kj[ i, ii ] <-  rpois( n = 1, lambda = lambda) 
  }
}

#summarising

db <-   data.frame(
        k, # Patient's Id
        A, # Patient's age
        B, # Patient's background liver disease
        jmax = j, # number of (new) clones for each patient
        E = Ekj, # presence of EMT in each patient (row) and clone (col)
        V = Vkj, # presence of VETC in each patient (row) and clone (col)
        i = i_kj  # number of new clonally related nodules in each patient (row) and clone (col)
      )

db <- db %>% 
     pivot_longer(cols=-(1:4), # ignores id, age, bld, and the new clones
     names_pattern = "(.)\\.(.*)$",  # separate the names using the '.' try head(db) before running this 
     names_to = c("cloneChar", "j"))  %>%  
  drop_na(value) %>%  # removes the NA that are here because of the matrix structure
  mutate(j = as.integer(j)) %>% 
  pivot_wider(names_from = cloneChar, values_from = value)

write.csv(db, 'input/sim.csv')
