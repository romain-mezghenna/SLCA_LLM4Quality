# This code evaluates hallucination rates for GPT4, GPT4+LCA, GPT4+SCA and GPT4+SLCA


# import data
GS = readRDS("analysis/01_Humans_GPT4_and_CA_performances/data/01_Gold_Standard/GS.rds")
GPT4_SCA = readRDS("analysis/01_Humans_GPT4_and_CA_performances/data/02_GPT4/GPT4_SCA.rds")
GPT4_LCA = readRDS("analysis/01_Humans_GPT4_and_CA_performances/data/02_GPT4/GPT4_LCA.rds")
GPT4_SLCA = readRDS("analysis/01_Humans_GPT4_and_CA_performances/data/02_GPT4/GPT4_SLCA.rds")
GPT4 = readRDS("analysis/01_Humans_GPT4_and_CA_performances/data/02_GPT4/GPT4.rds")

# Store the possible agents
agent = c("1","2","3")
# Create the array squeleton
GS2 = array(data=0, dim=c(
  length(index),
  length(category),
  length(tone),
  length(agent)
), 
dimnames = list(index,category,tone,agent))

GS2[,,,1] = GS
GS2[,,,2] = GS
GS2[,,,3] = GS

# Each error have to be checked by hand by an hospital quality of care expert to judge if it corresponds to an hallucination or not.
# Files can be produced from the output of the script "06_create GPT4_CA_errorlist.R" and a new column named "hallucination" have to be inserted, taking the value of 1 if there is an hallucination, 0 otherwise. 

#GPT 4 alone
library(xlsx)
hallucination_check = read.xlsx("analysis/01_Humans_GPT4_and_CA_performances/data/02_GPT4/GPT4_hallucinations_check_1.xlsx",sheetIndex = 1)

# establish which error has been made by which agent.
agent1 = vector()
agent2 = vector()
agent3 = vector()
current_id = 0
current_agent = 1
for(i in 1:dim(hallucination_check)[1]){
  if(is.na(hallucination_check$id[i]))next
  if(as.numeric(hallucination_check$id[i]) < current_id){
    current_agent = current_agent+1
  }
  current_id = as.numeric(hallucination_check$id[i])
  if(current_agent ==1)agent1 = append(agent1,i)
  if(current_agent ==2)agent2 = append(agent2,i)
  if(current_agent ==3)agent3 = append(agent3,i)
}


hallucination_rate.GPT41 = round(sum(hallucination_check$hallucination[agent1])/length(which(GPT4[,,,1]==1)),2)
hallucination_rate.GPT42 = round(sum(hallucination_check$hallucination[agent2])/length(which(GPT4[,,,2]==1)),2)
hallucination_rate.GPT43 = round(sum(hallucination_check$hallucination[agent3])/length(which(GPT4[,,,3]==1)),2)
results = paste("GPTs alone mean =",round(mean(c(hallucination_rate.GPT41,hallucination_rate.GPT42,hallucination_rate.GPT43)),2))



#GPT 4 + sCA
library(xlsx)
hallucination_check_1 = read.xlsx("analysis/01_Humans_GPT4_and_CA_performances/data/02_GPT4/GPT4_hallucinations_check_1.xlsx",sheetIndex = 1)
hallucination_check_2 = read.xlsx("analysis/01_Humans_GPT4_and_CA_performances/data/02_GPT4/GPT4_hallucinations_check_2.xlsx",sheetIndex = 1)


agent = 1:3
# establish which error has been made by which agent.
agent_id_1 = list(agent1 = vector(),agent2 = vector(),agent3 = vector()) # for hallucinations_check_1
current_id = 0
current_agent = 1
for(i in 1:dim(hallucination_check_1)[1]){
  if(is.na(hallucination_check_1$id[i]))next
  if(as.numeric(hallucination_check_1$id[i]) < current_id){
    current_agent = current_agent+1
    if(current_agent ==4) current_agent = 1 # Each agent is visited twice (the 1, then the 2, then the 3)
  }
  current_id = as.numeric(hallucination_check_1$id[i])
  agent_id_1[[current_agent]] = c(agent_id_1[[current_agent]], i)
}
agent_id_2 = list(agent1 = vector(),agent2 = vector(),agent3 = vector()) # for hallucinations_check_2
current_id = 0
current_agent = 1
for(i in 1:dim(hallucination_check_2)[1]){
  if(is.na(hallucination_check_2$id[i]))next
  if(as.numeric(hallucination_check_2$id[i]) < current_id){
    current_agent = current_agent+1
    if(current_agent ==4) current_agent = 1 # Each agent is visited twice (the 1, then the 2, then the 3)
  }
  current_id = as.numeric(hallucination_check_2$id[i])
  agent_id_2[[current_agent]] = c(agent_id_2[[current_agent]], i)
}

hallucinations_count = 0
for(i in 1:dim(GPT4_SCA)[1]){
  for(current_category in category){
    for(current_tone in 1:2){
      for(current_slice in (1:3)){
        if(GPT4_SCA[i,current_category,current_tone,current_slice]==1 & GS[i,current_category,current_tone]==0){
          current_agent_id_1 =agent_id_1[[current_slice]]
          current_agent_id_2 =agent_id_2[[current_slice]]
          current_dataset_1= hallucination_check_1[current_agent_id_1,]
          current_dataset_2= hallucination_check_2[current_agent_id_2,]
          current_hallucinations_1 = current_dataset_1$hallucination[which(current_dataset_1$id == i & current_dataset_1$category == current_category & current_dataset_1$tone ==c("+","-")[current_tone])]
          current_hallucinations_2 = current_dataset_2$hallucination[which(current_dataset_2$id == i & current_dataset_2$category == current_category & current_dataset_2$tone ==c("+","-")[current_tone])]
          if(current_hallucinations_1[1]+current_hallucinations_2[1]==2)hallucinations_count = 1 + hallucinations_count
        }
      }
    }
  }
}
results = c(results, paste("GPT4+SCA mean =",round(hallucinations_count/length(which(GPT4_SCA==1)),2)))






# GPT4+ LCA & SLCA
hallucination_check_1 = read.xlsx("analysis/01_Humans_GPT4_and_CA_performances/data/02_GPT4/GPT4_LCA_SLCA_hallucination_check_1.xlsx",sheetIndex = 1)
hallucination_check_2 = read.xlsx("analysis/01_Humans_GPT4_and_CA_performances/data/02_GPT4/GPT4_LCA_SLCA_hallucination_check_2.xlsx",sheetIndex = 1)

# establish which error has been made by which agent.
agent_id_1 = list(agent1 = vector(),agent2 = vector(),agent3 = vector()) # for hallucinations_check_1
current_id = 0
current_agent = 1
for(i in 1:dim(hallucination_check_1)[1]){
  if(is.na(hallucination_check_1$id[i]))next
  if(as.numeric(hallucination_check_1$id[i]) < current_id){
    current_agent = current_agent+1
    if(current_agent ==4) current_agent = 1 # Each agent is visited twice (the 1, then the 2, then the 3)
  }
  current_id = as.numeric(hallucination_check_1$id[i])
  agent_id_1[[current_agent]] = c(agent_id_1[[current_agent]], i)
}
agent_id_2 = list(agent1 = vector(),agent2 = vector(),agent3 = vector()) # for hallucinations_check_2
current_id = 0
current_agent = 1
for(i in 1:dim(hallucination_check_2)[1]){
  if(is.na(hallucination_check_2$id[i]))next
  if(as.numeric(hallucination_check_2$id[i]) < current_id){
    current_agent = current_agent+1
    if(current_agent ==4) current_agent = 1 # Each agent is visited twice (the 1, then the 2, then the 3)
  }
  current_id = as.numeric(hallucination_check_2$id[i])
  agent_id_2[[current_agent]] = c(agent_id_2[[current_agent]], i)
}


# GPT4_LCA

hallucinations_count = 0
for(i in 1:dim(GPT4_LCA)[1]){
  for(current_category in category){
    for(current_tone in 1:2){
      for(current_slice in (1:3)){
        if(GPT4_LCA[i,current_category,current_tone,current_slice]==1 & GS[i,current_category,current_tone]==0){
          current_agent_id_1 =agent_id_1[[current_slice]]
          current_dataset_1= hallucination_check_1[current_agent_id_1,]
          current_hallucinations_1 = current_dataset_1$hallucination[which(current_dataset_1$id == i & current_dataset_1$category == current_category & current_dataset_1$tone ==c("+","-")[current_tone])]
          if(current_hallucinations_1[1]==1){
            hallucinations_count = 1 + hallucinations_count
          }
        }
      }
    }
  }
}
results = c(results, paste("GPT4+LCA mean =",round(hallucinations_count/length(which(GPT4_LCA==1)),2)))

# GPT4_SLCA

hallucinations_count = 0
for(i in 1:dim(GPT4_SLCA)[1]){
  for(current_category in category){
    for(current_tone in 1:2){
      for(current_slice in (1:3)){
        if(GPT4_SLCA[i,current_category,current_tone,current_slice]==1 & GS[i,current_category,current_tone]==0){
          current_agent_id_1 =agent_id_1[[current_slice]]
          current_agent_id_2 =agent_id_2[[current_slice]]
          current_dataset_1= hallucination_check_1[current_agent_id_1,]
          current_dataset_2= hallucination_check_2[current_agent_id_2,]
          current_hallucinations_1 = current_dataset_1$hallucination[which(current_dataset_1$id == i & current_dataset_1$category == current_category & current_dataset_1$tone ==c("+","-")[current_tone])]
          current_hallucinations_2 = current_dataset_2$hallucination[which(current_dataset_2$id == i & current_dataset_2$category == current_category & current_dataset_2$tone ==c("+","-")[current_tone])]
          if(current_hallucinations_1[1]+current_hallucinations_2[1]==2)hallucinations_count = 1 + hallucinations_count
        }
      }
    }
  }
}
results = c(results, paste("GPT4+SLCA mean =",round(hallucinations_count/length(which(GPT4_SLCA==1)),2)))


print(results)

