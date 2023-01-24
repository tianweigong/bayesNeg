data {
  real yl; // The observed position of the left side of the line/left-point
  real yr; // The position of the right side of the line/right-point
  real gamma_a;
  real gamma_b;
  real<lower=0> sd_l;
  real<lower=0> sd_r;
  real<lower=0> sd_center;

}

transformed data {
}

// The parameters accepted by the model.
parameters {
  real c;
  real<lower = 0> offset;
}

transformed parameters {
}

// The model to be estimated.
model {
 c ~ normal(0, sd_center);
 // alpha is shape, beta is rate. (10,10) implies an expectation that offset is very close to 1. (1,1) is exponential(1)
 offset ~ gamma(gamma_a,gamma_b);
 yl ~ normal(c-offset,sd_l);
 yr ~ normal(c+offset,sd_r);
}
