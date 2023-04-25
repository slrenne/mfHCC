#set seed
set.seed(230425)

# libraries 
library(rethinking)

# loading the data
db <- read.csv('input/sim.csv')

# let's start modeling the intrahepatic mets as function of EMT and VETC
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
  p = which(db$j==1)
  )

m.i <- ulam(
  alist(
    I ~ dpois(lambda),
    log(lambda) <- alpha + beta * (E + V) + gamma * A,
    alpha ~ dnorm( 0 , 0.5 ),
    beta ~ dnorm( 0 , 0.2 ),
    gamma ~ dnorm( 0 , 0.2 )
  ), data = dat, chains = 4 , cores = 4, cmdstan = TRUE)
dashboard(m.i)
plot(precis(m.i))

post.mi <- extract.samples(m.i)
par(mfrow = c(1,1))

pdf('output/coef_rec_IM.pdf')
plot(NULL, 
     xlim = c(-0.01, 0.15),
     ylim = c(0,60),
     xlab = 'value', 
     ylab = 'density',
     main = 'Coefficient recovery, intrahepatic mets')
abline(v = c(0.1, 0.05, 0.05), col = 1:3, lty = c(2,1,2))
for (i in 1:3) dens(post.mi[[i]], add = TRUE, lwd = 3, col = i)
legend('topright', legend = c('intercept', 'EMT & VETC', 'age'), lwd = 3, col = 1:3)
dev.off()

m.j <- cstan( file = 'scripts/m.j.stan', data = dat, chains = 4, cores = 4 )

dashboard(m.j)
plot(precis(m.j))

post <- extract.samples(m.j)

pdf('output/coef_rec_MO.pdf')
plot(NULL, 
     xlim = c(-0.04, 0.40),
     ylim = c(0,50),
     xlab = 'value', 
     ylab = 'density',
     main = 'Coefficient recovery, multifocal occurrence')
abline(v = c(0.2, 0.3, 0.0), col = 1:3, lty = c(2,1,2))
for (i in 1:3) dens(post[[i]], add = TRUE, lwd = 3, col = i)
legend('top', legend = c('intercept', 'BLD', 'age'), lwd = 3, col = 1:3)
dev.off()
