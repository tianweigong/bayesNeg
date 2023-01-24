data {
  real yl; // The observed position of the left side of the line/left-point
  real yr; // The position of the right side of the line/right-point
  real gamma_a;
  real gamma_b;
  real<lower=0> sd_a;
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
 offset ~ gamma(gamma_a,gamma_b);
 yl ~ normal(c-offset,sd_a);
 yr ~ normal(c+offset,sd_a);
}
