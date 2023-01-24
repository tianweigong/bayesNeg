data {
  int N;
  real yl[N]; // The real position of the left side of the line/left-point
  real yr[N]; // The position of the right side of the line/right-point
  real c[N];
}

transformed data {
}

// The parameters accepted by the model.
parameters {
   // alpha is shape, beta is rate. (10,10) implies an expectation that offset is very close to 1. (1,1) is exponential(1)
  real<lower=0> gamma_a;
  real<lower=0> gamma_b;
  real<lower=0> sd_a;
  real<lower=0> sd_center;
  real<lower=0> offset[N];
}

transformed parameters {
}

// The model to be estimated.
model {
  for (i in 1:N) {
    offset[i] ~ gamma(gamma_a,gamma_b);
    c[i] ~ normal(0, sd_center);
    yl[i] ~ normal(c[i]-offset[i],sd_a);
    yr[i] ~ normal(c[i]+offset[i],sd_a);
  }
}
