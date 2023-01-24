
library(tidyverse)
library(rstan)
library(parallel)

df.raw=read.csv("EP32_NC_VN.csv")
df = df.raw %>% gather(sub,ans_raw,NC01:VN50) %>%
  mutate(cls=substr(sub,1,2),
         end_l=L/80,
         end_r=R/80,
         ans=ans_raw/80,
         half_linelengh=(end_r-end_l)/2)
wholelist= as.list(unique(df$sub))


myRun<-function(subID){
  d1=df %>% subset(sub==subID)
  
  post_samples <- sampling(m,
                           refresh = 0, # suppresses intermediate output
                           data = list(N=nrow(d1),yr=d1$end_r,yl=d1$end_l),
                           iter=100000)
  
  post_lis=list()
  for (k in c("gamma_a", "gamma_b","sd_l", "sd_r")){
    post_lis[[k]]=summary(post_samples,pars=k)$summary
  }
  
  save(post_lis,file=paste("fit_/",subID,".Rda",sep=""))
}

m <- stan_model('models/line_infer_no_noise.stan')

t0=Sys.time()
mclapply(wholelist, myRun, mc.cores = 4)
Sys.time()-t0


df.fit.nons=data.frame(sub=unique(df$sub))%>%
  mutate(cls=substr(sub,1,2), gamma_a=NA,gamma_b=NA,sd_l=NA,sd_r=NA)

for (k in 1:nrow(df.fit.nons)){
  load(paste("fit_no_noise/",df.fit.nons$sub[k],".Rda",sep=""))
  
  df.fit.nons$gamma_a[k]=post_lis$gamma_a[[1]]
  df.fit.nons$gamma_b[k]=post_lis$gamma_b[[1]]
  df.fit.nons$sd_l[k]=post_lis$sd_l[[1]]
  df.fit.nons$sd_r[k]=post_lis$sd_r[[1]]
}
df.fit.nons$model = 'no_noise'

save(df.fit.nons,file="data/no_noise.Rda")



