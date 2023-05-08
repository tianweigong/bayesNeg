
library(dplyr)
library(rstan)
rstan_options(auto_write = TRUE)

#### Load model and data ####
load('data/inference/no_c.Rdata')

m <- stan_model('preds/line_centers_nosdc.stan')

rob_data = read.csv(file='../EP32_NC_VN.csv') 
task = rob_data %>%
  select(L, R) %>%
  unique() %>% 
  mutate(L_normed=L/80, R_normed=R/80)
  
ppt_list = colnames(rob_data)[3:length(colnames(rob_data))]
df.pred = data.frame(sub=ppt_list)

#### Get predictions ####

for (ppt in ppt_list) {
  params = df.fit.nons %>% filter(sub==ppt) %>% as.list()
  
  for (ti in 1:nrow(task)) {
    task_data = as.list(task[ti,])
    m_data = list(yl=task_data[['L_normed']], yr=task_data[['R_normed']],
                  gam_m=params[['gamma_m']], gam_v=params[['gamma_v']],
                  sd_l=params[['sd_l']], sd_r=params[['sd_r']])
    post_samples = sampling(m, refresh=0, data=m_data, iter=200000)
    
    df = data.frame(summary(post_samples,pars=c("c"))$summary)
    df$task=ti
    
    if (ti == 1) {
      df_result = df
    } else {
      df_result = rbind(df_result, df)
    }
  }
  
  df_result$sub = ppt
  
  if (ppt=='NC01') {
    df_return = df_result
  } else {
    df_return = rbind(df_return, df_result)
  }
  write.csv(df_return, file='preds/no_c.csv')
}






