data {
  real yl; // The observed position of the left side of the line/left-point
  real yr; // The position of the right side of the line/right-point
  real<lower=0> gam_m;
  real<lower=0> gam_v;
  real<lower=0> sd_l;
  real<lower=0> sd_r;

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
 offset ~ gamma((gam_m^2)/gam_v, gam_m/gam_v);
 yl ~ normal(c-offset,sd_l);
 yr ~ normal(c+offset,sd_r);
}

