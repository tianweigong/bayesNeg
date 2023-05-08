
library(tidyverse)

rob_data = read.csv('../EP32_NC_VN.csv')
ppt_data = rob_data %>%
  pivot_longer(NC01:VN50, names_to = 'sub', values_to = 'center')
  
task_data = rob_data %>%
  select(L, R) %>%
  unique() %>%
  mutate(task=seq(4))

ppt_extended = ppt_data %>%
  left_join(task_data, by=c('L', 'R')) %>%
  mutate(L=L/80, R=R/80, center=center/80, cls=substr(sub, 1, 2)) %>%
  select(sub, cls, task, L, R, center) %>%
  arrange(sub, task)

get_ms <- function(model_name, ref_df = ppt_extended) {
  # Add model data
  model_data = read.csv(paste0('data/preds/', model_name, '.csv')) %>%
    select(task, sub, mean) %>%
    mutate(model=model_name)
  ppt_model = ref_df %>%
    left_join(model_data, by=c('sub', 'task'))
  
  # Compute MSE
  ppt_model = ppt_model %>%
    mutate(error = mean-center) %>%
    mutate(sq_error = error^2) %>%
    group_by(sub) %>%
    summarise(mse=sum(sq_error)/n())

  ppt_model_grouped = ppt_model %>%
    mutate(cls=substr(sub, 1, 2)) %>%
    group_by(cls) %>%
    summarise(mse=sum(mse))
  
  return (list(model=model_name, mse=sum(ppt_model$mse), 
               mse_VN=ppt_model_grouped[ppt_model_grouped$cls=='VN','mse'][[1]], 
               mse_NC=ppt_model_grouped[ppt_model_grouped$cls=='NC','mse'][[1]]))
}

df.mse = data.frame(get_ms('full'))
for(mn in c('no_c', 'no_imb', 'no_lp')) {
  df.mse = rbind(df.mse,  data.frame(get_ms(mn)))
}
colnames(df.mse) <- c('model', 'all', 'VN', 'HC')
# write_csv(df.mse, file='mse.csv')

# Plot it
df.mse = read_csv(file='mse.csv')
df.mse %>%
  pivot_longer(-model, names_to = 'mse', values_to = 'value') %>%
  filter(mse != 'all') %>%
  mutate(Model=factor(model, levels=c('full','no_c', 'no_lp','no_imb'), labels=c('Full', 'No center expectation', 'No lateral difference', 'No line expectation'))) %>%
  mutate(mse=factor(mse,levels=c("HC","VN"),labels=c("Healthy \n Control","Patient")))%>%
  ggplot(aes(x=value, y=mse, fill=Model)) +
  geom_bar(stat='identity', position="dodge") +
  geom_text(aes(label=round(value, 2)), position=position_dodge(width=0.9), hjust=-0.05) +
  labs(x='MSE', y='') +
  theme_classic() +  
  theme(legend.position = c(0.8, 0.3), 
                           legend.text=element_text(size=12), 
                           legend.title=element_text(size=15),
        text = element_text(size = 15),
        axis.title.y = element_blank()
  ) +
  guides(fill = guide_legend(reverse = TRUE))+
  scale_fill_brewer(palette='RdGy')

# ggsave(file="f_mse.pdf",width = 7.8,height = 3)