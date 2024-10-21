# This code explore reproducibility between independent agents. The results of this computation are presented in the discussion of the article.

# import data
GS = readRDS("analysis/01_Humans_GPT4_and_CA_performances/data/01_Gold_standard/GS.rds")
GPT4 = readRDS("analysis/01_Humans_GPT4_and_CA_performances/data/02_GPT4/GPT4.rds")
GPT4_SCA = readRDS("analysis/01_Humans_GPT4_and_CA_performances/data/02_GPT4/GPT4_SCA.rds")
GPT4_LCA = readRDS("analysis/01_Humans_GPT4_and_CA_performances/data/02_GPT4/GPT4_LCA.rds")
GPT4_SLCA = readRDS("analysis/01_Humans_GPT4_and_CA_performances/data/02_GPT4/GPT4_SLCA.rds")
humans = readRDS("analysis/01_Humans_GPT4_and_CA_performances/data/03_Humans/humans.rds")

# Store the possible agents
agent = c("1","2","3")

library(irr)


#Compute global Krippendorff alpha for humans
flatten_matrix = matrix(data=NA, nrow = length(index)* length(category)* length(tone), ncol = length(agent))
for(current_category in 1:length(category)){
  for(current_tone in 1:length(tone)){
    start = (current_category-1)*length(index)*length(tone) + (current_tone-1)*length(index) +1
    flatten_matrix[start : (start + length(index)-1 ),] = humans[,current_category,current_tone,]
  }
}
global_K_alpha = kripp.alpha(t(flatten_matrix))$value
print(paste("Global Krippendorf's alpha between humans :", global_K_alpha))


#Compute global Krippendorff alpha for GPT4s standalone
flatten_matrix = matrix(data=NA, nrow = length(index)* length(category)* length(tone), ncol = length(agent))
for(current_category in 1:length(category)){
  for(current_tone in 1:length(tone)){
    start = (current_category-1)*length(index)*length(tone) + (current_tone-1)*length(index) +1
    flatten_matrix[start : (start + length(index)-1 ),] = GPT4[,current_category,current_tone,]
  }
}
global_K_alpha = kripp.alpha(t(flatten_matrix))$value
print(paste("Global Krippendorf's alpha between GPT4s standalone :", global_K_alpha))


#Compute global Krippendorff alpha for GPT4+SCA
flatten_matrix = matrix(data=NA, nrow = length(index)* length(category)* length(tone), ncol = length(agent))
for(current_category in 1:length(category)){
  for(current_tone in 1:length(tone)){
    start = (current_category-1)*length(index)*length(tone) + (current_tone-1)*length(index) +1
    flatten_matrix[start : (start + length(index)-1 ),] = GPT4_SCA[,current_category,current_tone,]
  }
}
global_K_alpha = kripp.alpha(t(flatten_matrix))$value
print(paste("Global Krippendorf's alpha for GPT4+SCA :", round(global_K_alpha,2)))


#Compute global Krippendorff alpha for GPT4+LCA
flatten_matrix = matrix(data=NA, nrow = length(index)* length(category)* length(tone), ncol = length(agent))
for(current_category in 1:length(category)){
  for(current_tone in 1:length(tone)){
    start = (current_category-1)*length(index)*length(tone) + (current_tone-1)*length(index) +1
    flatten_matrix[start : (start + length(index)-1 ),] = GPT4_LCA[,current_category,current_tone,]
  }
}
global_K_alpha = kripp.alpha(t(flatten_matrix))$value
print(paste("Global Krippendorf's alpha for GPT4+LCA :", round(global_K_alpha,2)))

#Compute global Krippendorff alpha for GPT4+SLCA
flatten_matrix = matrix(data=NA, nrow = length(index)* length(category)* length(tone), ncol = length(agent))
for(current_category in 1:length(category)){
  for(current_tone in 1:length(tone)){
    start = (current_category-1)*length(index)*length(tone) + (current_tone-1)*length(index) +1
    flatten_matrix[start : (start + length(index)-1 ),] = GPT4_SLCA[,current_category,current_tone,]
  }
}
global_K_alpha = kripp.alpha(t(flatten_matrix))$value
print(paste("Global Krippendorf's alpha for GPT4+SLCA :", round(global_K_alpha,2)))

