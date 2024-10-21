# This code list the errors of GPT4 and GPT4+SCA, LCA and DCA to evaluate each as an hallucination or not.  


# import data
GS = readRDS("analysis/01_Humans_GPT4_and_CA_performances/data/01_Gold_standard/GS.rds")
GPT4_SCA = readRDS("analysis/01_Humans_GPT4_and_CA_performances/data/02_GPT4/GPT4_SCA.rds")
GPT4_LCA = readRDS("analysis/01_Humans_GPT4_and_CA_performances/data/02_GPT4/GPT4_LCA.rds")
GPT4_SLCA = readRDS("analysis/01_Humans_GPT4_and_CA_performances/data/02_GPT4/GPT4_SLCA.rds")
GPT4 = readRDS("analysis/01_Humans_GPT4_and_CA_performances/data/02_GPT4/GPT4.rds")



#---------------------------------- GPT4 standalone & SCA ---------------------------

# Store the possible agents
agent = c("1","2","3")



for(folder in 1:2){ # We also need to store the errors of the second output to be able to measure the hallucination rate of GPT-4+SCA
  errors = data.frame(id=logical(),
                      category=logical(),
                      tone=logical(),
                      justification = logical())
  
  llm_standalone_folders = paste0("analysis/01_Humans_GPT4_and_CA_performances/data/02_GPT4/output_gpt4-",agent,"/llm_queries/output_",folder,"/")
  
  for(current_agent in 1:length(agent)){
    for(i in index){
      suppressWarnings({
        input = paste(trimws(readLines(paste(llm_standalone_folders[current_agent],"initial_classification_result_",i,".json", sep=""))))
      })
      current_category = ""
      
      output = FALSE
      
      # Read the input row by row
      for (row in 1:length(input)){
        
        if(grepl('"output": \\{', input[row])) output = TRUE
        if(output==FALSE)next
        #Consider only the output.
        
        #Check if a category is mentioned
        for(category_check in category){
          if(grepl(category_check, input[row])) current_category = category_check
        }
        if(current_category=="") next
        
        if(folder==1){ # GPT4 alone and first folder for GPT4_SCA
          # If there is a positive tone mentioned :
          if(grepl("positive", input[row])) if(GS[i,current_category,"positive"]==0 & GPT4[i,current_category,"positive", current_agent]==1 )
          {
            errors = rbind(errors,c(i, current_category,"+",substr(input[row],nchar('"positive": "')+1,nchar(input[row])-2) ))
          }
          # If there is a negative tone mentioned :
          if(grepl("negative", input[row]))if(GS[i,current_category,"negative"]==0 & GPT4[i,current_category,"negative", current_agent]==1 )
          {
            errors = rbind(errors,c(i, current_category,"-",substr(input[row],nchar('"negative": "')+1,nchar(input[row])-2)))
          }
        }
        if(folder==2){ # second folder for GPT4_SCA
          # If there is a positive tone mentioned :
          if(grepl("positive", input[row])) if(GS[i,current_category,"positive"]==0 & GPT4_SCA[i,current_category,"positive", current_agent]==1 )
          {
            errors = rbind(errors,c(i, current_category,"+",substr(input[row],nchar('"positive": "')+1,nchar(input[row])-2) ))
          }
          # If there is a negative tone mentioned :
          if(grepl("negative", input[row]))if(GS[i,current_category,"negative"]==0 & GPT4_SCA[i,current_category,"negative", current_agent]==1 )
          {
            errors = rbind(errors,c(i, current_category,"-",substr(input[row],nchar('"negative": "')+1,nchar(input[row])-2)))
          }
        }
        
        
      }
    }
  }
  colnames(errors) = c("id","category","tone","justification")
  
  library(xlsx)
  write.xlsx(errors,paste0("analysis/01_Humans_GPT4_and_CA_performances/data/02_GPT4/GPT4_output_",folder,"_errors.xlsx"), row.names=F)
}


#---------------------------------- GPT4 + LCA & SLCA ---------------------------
# As GPT4+LCA and GPT4+SLCA use the same generated output, it is only needed to evaluate it once.It also allows to do it partially blindly.
# However, there is two output to test for each agent

# Store the possible agents
agent = c("1","2","3")

# In this script we also count the number of uses for the implication "Qualité et rapidité de la régulation et réponse aux appels d’urgence (SAMU, services d’urgences)"
# As it has been described responsible of hallucinations generations 
regulation_implication_counter = 0

for(folder in 1:2){
  
  errors = data.frame(id=logical(),
                      category=logical(),
                      tone=logical(),
                      justification = logical())
  
  llm_standalone_folders = paste0("analysis/01_Humans_GPT4_and_CA_performances/data/02_GPT4/output_gpt4-",agent,"/llm_queries/output_",folder,"/")
  
  for(current_agent in 1:length(agent)){
    for(i in index){
      suppressWarnings({
        input = paste(trimws(readLines(paste0(llm_standalone_folders[current_agent],"few_shot_cot_classification_result_",i,".json"))))
      })
      current_category = ""
      
      output = FALSE
      
      # Read the input row by row
      for (row in 1:length(input)){
        
        if(grepl('"output": \\{', input[row])) output = TRUE
        if(output==FALSE)next
        #Consider only the output.
        
        # Count the number of times this implication is invoked. 
        if(grepl("Qualité et rapidité de la régulation et réponse aux appels d’urgence", input[row])) regulation_implication_counter = regulation_implication_counter+1
        
        #Check if a category is mentioned
        for(category_check in category){
          if(grepl(category_check, input[row])) current_category = category_check
        }
        if(current_category=="") next
        
        # If there is a positive tone mentioned :
        if(grepl("positive", input[row])) if(GS[i,current_category,"positive"]==0 & (
          GPT4_LCA[i,current_category,"positive",current_agent] ==1 |
          GPT4_SLCA[i,current_category,"positive",current_agent] ==1
          ))
        {
          errors = rbind(errors,c(i, current_category,"+",substr(input[row],nchar('"positive": "')+1,nchar(input[row])-2) ))
        }
        # If there is a negative tone mentioned :
        if(grepl("negative", input[row]))if(GS[i,current_category,"negative"]==0 & (
          GPT4_LCA[i,current_category,"negative",current_agent] ==1 |
          GPT4_SLCA[i,current_category,"negative",current_agent] ==1
        ))
        {
          errors = rbind(errors,c(i, current_category,"-",substr(input[row],nchar('"negative": "')+1,nchar(input[row])-2)))
        }
      }
    }
  }
  colnames(errors) = c("id","category","tone","justification")
  
  write.xlsx(errors,paste0("analysis/01_Humans_GPT4_and_CA_performances/data/02_GPT4/GPT4_LCA_SLCA_errors_",folder,".xlsx"), row.names=F)
}

print(paste("The emergency regulation implication responsible of several hallucinations going through LCA has been used",regulation_implication_counter,"times."))