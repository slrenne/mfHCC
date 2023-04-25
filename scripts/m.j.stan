data{
  array[18206] int jmax;  
  array[10000] int p;
  array[18206] real B;
  array[18206] real A;
 
}
parameters{
    real alpha;
    real beta;
    real gamma;
}
model{
    array[18206] real lambda;
    gamma ~ normal( 0 , 0.1 );
    beta ~ normal( 0 , 0.1 );
    alpha ~ normal( 3 , 0.5 );
    for ( i in 1:18206 ) {
        lambda[i] = alpha + beta * B[i] + gamma * A[i];
        lambda[i] = exp(lambda[i]);
    }
    for ( n in 1:10000){
    jmax[p[n]] ~ poisson( lambda[p[n]] ) T[1,]; //truncate the poisson
    }
}

