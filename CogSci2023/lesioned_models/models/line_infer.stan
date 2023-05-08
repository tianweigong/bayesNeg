
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
  real<lower=0> gam_m;
  real<lower=0> gam_v;
  real<lower=0> sd_l;
  real<lower=0> sd_r;
  real<lower=0> sd_center;
  real<lower=0> offset[N];
}

transformed parameters {
}

// The model to be estimated.
model {
  for (i in 1:N) {
    offset[i] ~ gamma((gam_m^2)/gam_v, gam_m/gam_v);
    c[i] ~ normal(0, sd_center);
    yl[i] ~ normal(c[i]-offset[i],sd_l);
    yr[i] ~ normal(c[i]+offset[i],sd_r);
  }
}
