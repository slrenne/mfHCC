data{
  int kmax;
  int n_row; 
  array[n_row] int jmax;  
  array[n_row] int I;  
  array[kmax] int p;
  array[n_row] real B;
  array[n_row] real A;
  array[n_row] real E;
  array[n_row] real V;
}

parameters{
    real alpha_j;
    real beta_j;
    real gamma_j;
    real alpha_i;
    real beta_i;
    real gamma_i;
    real delta_i;
}
model{
    array[n_row] real lambda_j;
    gamma_j ~ normal( 0 , 0.1 );
    beta_j ~ normal( 0 , 0.1 );
    alpha_j ~ normal( 3 , 0.5 );
    for ( i in 1:n_row ) {
        lambda_j[i] = alpha_j + beta_j * B[i] + gamma_j * A[i];
        lambda_j[i] = exp(lambda_j[i]);
    }
    for ( n in 1:kmax){
    jmax[p[n]] ~ poisson( lambda_j[p[n]] ) T[1,]; //truncate the poisson
    }
    
    array[n_row] real lambda_i;
    delta_i ~ normal( 0 , 0.2 );
    gamma_i ~ normal( 0 , 0.2 );
    beta_i ~ normal( 0 , 0.2 );
    alpha_i ~ normal( 0 , 0.5 );
    
     for ( i in 1:n_row ) {
        lambda_i[i] = alpha_i + beta_i * E[i] + gamma_i * V[i] + delta_i * A[i];
        lambda_i[i] = exp(lambda_i[i]);
        I[i] ~ poisson( lambda_i[i] ); 
    }
}
// generated quantities {
//     array[n_row] int sim_I;
//     array[n_row] real lambda_i; 
//     for ( i in 1:n_row ) {
//         lambda_i[i] = alpha_i + beta_i * E[i] + gamma_i * V[i] + delta_i * A[i];
//         lambda_i[i] = exp(lambda_i[i]);
//         sim_I[i] = poisson_rng( lambda_i[i] ); 
//     }
//     
// }
