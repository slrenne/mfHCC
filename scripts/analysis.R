#set seed
set.seed(230612)

# libraries 
library(rethinking)

# loading the data
db <- read.csv('input/pts.csv')

# let's start modeling the intrahepatic mets as function of EMT and VETC
dat <- list ( 
  A = standardize( db$A ), #do we want to scale variables?
#  B = standardize( db$B ), #4% missing [length(db$B[is.na(db$B)])/length(db$B)*100], at random? logistic (logit) regression?
  I = db$i,
#  k = db$k, 
#  j = db$j,
  E = standardize (db$E ), #now as score, not 01. 7.3% missing (maybe didn't have transcriptomics data, at random? logistic (logit) regression?)
  V = standardize (db$V)#, #now as annotation, not 01. 74.67% missing; annotated small selected dataset, MNAR.
#  jmax = db$jmax,
#  kmax = max(db$k), #137
#  p = which(db$j==1),
#  n_row = nrow(db)
)


m.i <- ulam(
  alist(
    I ~ dpois(lambda),
    log(lambda) <- alpha + beta * (E + V) + gamma * A,
    E ~ dnorm( nu_E , sigma_E ),
    V ~ dnorm( nu_V , sigma_V ),
    alpha ~ dnorm( 0 , 0.5 ),
    beta ~ dnorm( 0 , 0.2 ),
    gamma ~ dnorm( 0 , 0.2 ),
    nu_E ~ dnorm( 0 , 0.5 ), 
    nu_V ~ dnorm( 0 , 0.5 ),
    sigma_V ~ dexp( 1 ),
    sigma_E ~ dexp( 1 )
  ), data = dat, chains = 4 , cores = 4, iter = 1000, cmdstan = TRUE)



post.mi <- extract.samples(m.i)
par(mfrow = c(1,1))

pdf('output/coef_rec_IM.pdf')
plot(NULL, 
     xlim = c(-2.5, 0.5),
     ylim = c(0,3.2),
     xlab = 'value', 
     ylab = 'density',
     main = 'Coefficient fit, intrahepatic mets')
abline(v = 0, lty = 2)
for (i in 1:3) dens(post.mi[[i]], add = TRUE, lwd = 3, col = i)
legend('topleft', legend = c('intercept', 'EMT & VETC', 'age'), lwd = 3, col = 1:3)
dev.off()