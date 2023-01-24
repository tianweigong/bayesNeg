data {
  real yl; // The observed position of the left side of the line/left-point
  real yr; // The position of the right side of the line/right-point
  real offset;
  real<lower=0> sd_l;
  real<lower=0> sd_r;
  real<lower=0> sd_center;

}

transformed data {
}

// The parameters accepted by the model.
parameters {
  real c;
}

transformed parameters {
}

// The model to be estimated.
model {
 c ~ normal(0, sd_center);
 yl ~ normal(c-offset,sd_l);
 yr ~ normal(c+offset,sd_r);
}
