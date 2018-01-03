#!/usr/bin/env Rscript

# reformat all_score.txt

library(dplyr)
library(tidyr)
d <- read.table('raw/all_score.txt',sep="\t") %>%
#100_y1_run1	1	164	389	TRUE	FALSE	ASNue	1	
 `names<-`(c('file','trial','xdat','lat','cor','ecor','type','count','dropreason') )%>%
 separate(file,c('subj','year','run')) %>%
 mutate(subj = sapply(subj %>% as.numeric,FUN=sprintf,fmt="%03d")) %>%
 arrange(subj)

write.table(d,'all_score.csv',sep=",",row.names=F,quote=T)
# subj,year,run,trial,xdat,lat,cor,ecor,type,count,dropreason
# 002,y2,run1,1,164,473,TRUE,FALSE,ASNue,1,

