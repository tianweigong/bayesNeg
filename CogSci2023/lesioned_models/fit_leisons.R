
library(tidyverse)
library(rstan)
library(parallel)

df.raw=read.csv("../EP32_NC_VN.csv")
df = df.raw %>% gather(sub,ans_raw,NC01:VN50) %>%
  mutate(cls=substr(sub,1,2),
         end_l=L/80,
         end_r=R/80,
         ans=ans_raw/80,
         half_linelengh=(end_r-end_l)/2,
         l_center=(end_l+end_r)/2)
wholelist= as.list(unique(df$sub))

myRun<-function(subID){
  d1=df %>% subset(sub==subID)
  
  post_samples <- sampling(m,
                           refresh = 0, # suppresses intermediate output
                           data = list(N=nrow(d1),yl=d1$end_l,yr=d1$end_r,c=d1$ans),
                           #control=list(stepsize=1E-99),
                           iter=100000
                           )
  
  post_lis=list()
  for (k in c("gam_m","gam_v", "sd_l", "sd_r")){
    post_lis[[k]]=summary(post_samples,pars=k)$summary
  }
  
  save(post_lis,file=paste("fits/no_c/",subID,".Rda",sep=""))
}

m <- stan_model('models/line_infer_no_c.stan')

t0=Sys.time()
mclapply(wholelist, myRun, mc.cores = 4)
Sys.time()-t0


df.fit.nons=data.frame(sub=unique(df$sub))%>%
  mutate(cls=substr(sub,1,2), gamma_m=NA,gamma_v=NA,sd_l=NA,sd_r=NA,sdc=NA)

for (k in 1:nrow(df.fit.nons)){
  load(paste("fits/no_c/",df.fit.nons$sub[k],".Rda",sep=""))
  
  df.fit.nons$gamma_m[k]=post_lis$gam_m[[1]]
  df.fit.nons$gamma_v[k]=post_lis$gam_v[[1]]
  df.fit.nons$sd_l[k]=post_lis$sd_l[[1]]
  df.fit.nons$sd_r[k]=post_lis$sd_r[[1]]
}
df.fit.nons$model = 'no_c'

save(df.fit.nons,file="data/inference/no_c.Rdata")



