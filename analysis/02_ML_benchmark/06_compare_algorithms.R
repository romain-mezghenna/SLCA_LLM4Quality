Regex = readRDS("analysis/02_ML_benchmark/data/03_Regex/Regex.rds")
NB = readRDS("analysis/02_ML_benchmark/data/04_NB/NB.rds")
LSTM = readRDS("analysis/02_ML_benchmark/data/05_LSTM/LSTM.rds")
GPT4_SLCA = readRDS("analysis/02_ML_benchmark/data/02_GPT4/GPT4_SLCA.rds")
GPT4_SCA = readRDS("analysis/02_ML_benchmark/data/02_GPT4/GPT4_SCA.rds")
GPT4_LCA = readRDS("analysis/02_ML_benchmark/data/02_GPT4/GPT4_LCA.rds")
GS = readRDS("analysis/02_ML_benchmark/data/01_Gold_standard/GS.rds")
Llama3_SLCA = readRDS("analysis/02_ML_benchmark/data/06_Llama3/Llama3_SLCA.rds")
Llama3_SCA = readRDS("analysis/02_ML_benchmark/data/06_Llama3/Llama3_SCA.rds")
Llama3_LCA = readRDS("analysis/02_ML_benchmark/data/06_Llama3/Llama3_LCA.rds")
# LLMs without Consistency Assessment
GPT4 = readRDS("analysis/02_ML_benchmark/data/02_GPT4/GPT4.rds")
Llama3 = readRDS("analysis/02_ML_benchmark/data/06_Llama3/Llama3.rds")



# ----------------- pr-curves computation for thresholded algorithms -----------------


# Define a sequence of threshold levels
thresholds = seq(0.01,1,length.out=70)

# precision and recall curve computation for NB
pr_nb = matrix(nrow=0,ncol=2, dimnames = list(logical(),c("precision","recall")))
for(i in thresholds){
  precision = length(which(NB[GS==1]>=i)) / length(which(NB>=i))
  if(i!= thresholds[1]) if(!is.na(precision)) if(precision < max(pr_nb[,"precision"]))precision =  max(pr_nb[,"precision"])
  recall = length(which(NB[GS==1]>=i)) / length(which(GS==1))
  pr_nb = rbind(pr_nb, c(precision,recall))
}
pr_nb = rbind(c(0,max(pr_nb[,"recall"])+0.0001),pr_nb,c(max(pr_nb[,"precision"]),0))
pr_nb[is.na(pr_nb)]=0

# precision and recall curve computation for LSTM
pr_lstm = matrix(nrow=0,ncol=2, dimnames = list(logical(),c("precision","recall")))
for(i in thresholds){
  precision = length(which(LSTM[GS==1]>=i)) / length(which(LSTM>=i))
  if(i!= thresholds[1]) if(!is.na(precision)) if(precision < max(pr_lstm[,"precision"]))precision =  max(pr_lstm[,"precision"])
  recall = length(which(LSTM[GS==1]>=i)) / length(which(GS==1))
  pr_lstm = rbind(pr_lstm, c(precision,recall))
}
pr_lstm[,"precision"][is.na(pr_lstm[,"precision"])] = max(pr_lstm[,"precision"], na.rm=T)
pr_lstm[,"recall"][is.na(pr_lstm[,"recall"])] = max(pr_lstm[,"recall"], na.rm=T)
pr_lstm = rbind(c(0,max(pr_lstm[,"recall"])+0.0001),pr_lstm,c(max(pr_lstm[,"precision"]),0))

# precision and recall curve computation for Regex
pr_regex = matrix(nrow=0,ncol=2, dimnames = list(logical(),c("precision","recall")))
for(i in thresholds){
  precision = length(which(Regex[GS==1]>=i)) / length(which(Regex>=i))
  if(i!= thresholds[1]) if(precision < max(pr_regex[,"precision"]))precision =  max(pr_regex[,"precision"])
  recall = length(which(Regex[GS==1]>=i)) / length(which(GS==1))
  pr_regex = rbind(pr_regex, c(precision,recall))
}
pr_regex = rbind(c(0,max(pr_regex[,"recall"])+0.0001),pr_regex,c(max(pr_regex[,"precision"]),0))



# ----------------- Print max( precision * recall ) to identify the best threshold possible without hypothesis valuating precision or recall, for thresholded algorithms. -----------------


# Create pr_table skeleton to display the results :
pr_table = matrix(data = NA, nrow = 2, ncol=11)
rownames(pr_table) = c("precision","recall")
colnames(pr_table) = c("NB","LSTM","Regex", "Llama-3 alone","Llama-3+SCA","Llama-3+LCA","Llama-3+SLCA", "GPT-4 alone","GPT-4+SCA","GPT-4+LCA","GPT-4+SLCA")


#NB
max_value = 0
max_threshold = 0
for(i in 1:dim(pr_nb)[1]){
  current_value = pr_nb[i,1] * pr_nb[i,2]
  if(current_value>max_value) {
    max_value = current_value
    max_threshold = i
  }
}
if(max_threshold!=0){
  pr_table["precision","NB"] = round(pr_nb[max_threshold,1],2)
  pr_table["recall","NB"] = round(pr_nb[max_threshold,2],2)
}

# LSTM
max_value = 0
max_threshold = 0
for(i in 1:dim(pr_lstm)[1]){
  current_value = pr_lstm[i,1] * pr_lstm[i,2]
  if(current_value>max_value) {
    max_value = current_value
    max_threshold = i
  }
}
pr_table["precision","LSTM"] = round(pr_lstm[max_threshold,1],2)
pr_table["recall","LSTM"] = round(pr_lstm[max_threshold,2],2)


# Regex
max_value = 0
max_threshold = 0
for(i in 1:dim(pr_regex)[1]){
  current_value = pr_regex[i,1] * pr_regex[i,2]
  if(current_value>max_value) {
    max_value = current_value
    max_threshold = i
  }
}
pr_table["precision","Regex"] = round(pr_regex[max_threshold,1],2)
pr_table["recall","Regex"] = round(pr_regex[max_threshold,2],2)

# ------------- Compute precision and recall for non-thresholded algorithms -----------------------------------

# Llama-3 alone
pr_table["precision","Llama-3 alone"] = round(length(which(Llama3==1 & GS==1))/length(which(Llama3==1)),2)
pr_table["recall","Llama-3 alone"] = round(length(which(Llama3==1 & GS==1))/length(which(GS==1)),2)

# Llama-3 +SCA
pr_table["precision","Llama-3+SCA"] = round(length(which(Llama3_SCA==1 & GS==1))/length(which(Llama3_SCA==1)),2)
pr_table["recall","Llama-3+SCA"] = round(length(which(Llama3_SCA==1 & GS==1))/length(which(GS==1)),2)

# Llama-3 +LCA
pr_table["precision","Llama-3+LCA"] = round(length(which(Llama3_LCA==1 & GS==1))/length(which(Llama3_LCA==1)),2)
pr_table["recall","Llama-3+LCA"] = round(length(which(Llama3_LCA==1 & GS==1))/length(which(GS==1)),2)

# Llama-3 +SLCA
pr_table["precision","Llama-3+SLCA"] = round(length(which(Llama3_SLCA==1 & GS==1))/length(which(Llama3_SLCA==1)),2)
pr_table["recall","Llama-3+SLCA"] = round(length(which(Llama3_SLCA==1 & GS==1))/length(which(GS==1)),2)

# GPT-4 alone
pr_table["precision","GPT-4 alone"] = round(length(which(GPT4==1 & GS==1))/length(which(GPT4==1)),2)
pr_table["recall","GPT-4 alone"] = round(length(which(GPT4==1 & GS==1))/length(which(GS==1)),2)

# GPT-4 +SCA
pr_table["precision","GPT-4+SCA"] = round(length(which(GPT4_SCA==1 & GS==1))/length(which(GPT4_SCA==1)),2)
pr_table["recall","GPT-4+SCA"] = round(length(which(GPT4_SCA==1 & GS==1))/length(which(GS==1)),2)

# GPT-4 +LCA
pr_table["precision","GPT-4+LCA"] = round(length(which(GPT4_LCA==1 & GS==1))/length(which(GPT4_LCA==1)),2)
pr_table["recall","GPT-4+LCA"] = round(length(which(GPT4_LCA==1 & GS==1))/length(which(GS==1)),2)

# GPT-4 +SLCA
pr_table["precision","GPT-4+SLCA"] = round(length(which(GPT4_SLCA==1 & GS==1))/length(which(GPT4_SLCA==1)),2)
pr_table["recall","GPT-4+SLCA"] = round(length(which(GPT4_SLCA==1 & GS==1))/length(which(GS==1)),2)

print(pr_table)



# ----------------------- plot pr-table ------------------------------

library(ggplot2)

# Assume pr_table is already defined
# Transpose the pr_table and convert it to a data frame
pr_dataframe <- as.data.frame(t(pr_table))

# Add model names as a column
pr_dataframe$model <- rownames(pr_dataframe)

# Define custom colors for each model
custom_colors <- c(
  "NB" = "#555",
  "LSTM" = "#555",
  "Regex" = "#555",
  "Llama-3 alone" = "#000",
  "Llama-3+SCA" = "#00bb00",
  "Llama-3+LCA" = "#ee0000",
  "Llama-3+SLCA" = "purple",
  "GPT-4 alone" = "#000",
  "GPT-4+SCA" = "#00bb00",
  "GPT-4+LCA" = "#ee0000",
  "GPT-4+SLCA" = "purple"
)

# Plot the precision-recall points with custom colors
plot <- ggplot(pr_dataframe, aes(x = recall, y = precision, color = model)) +
  geom_point(shape = 4, size = 4) +  # Use crosses instead of dots
  geom_text(aes(label = model), vjust = 0, hjust = -0.25, size = 3.5) +  # Add model names above crosses
  labs(
    title = "",
    x = "Recall",
    y = "Precision"
  ) +
  scale_x_continuous(limits = c(-0.001, 1.1), breaks = seq(0, 1, by = 0.1)) +  # Set x-axis limits and breaks
  scale_y_continuous(limits = c(-0.001, 1.001), breaks = seq(0, 1, by = 0.1)) +  # Set y-axis limits and breaks
  scale_color_manual(values = custom_colors) +  # Apply custom colors
  theme(
    panel.grid.major = element_blank(),  # Remove major grid lines
    panel.grid.minor = element_blank(),  # Remove minor grid lines
    axis.line = element_line(color = "black"),  # Add axis lines
    panel.background = element_rect(fill = "white", color = NA),  # Set panel background to white
    plot.background = element_rect(fill = "white", color = NA),  # Set plot background to white
    legend.position = "none"  # Remove the legend
  )

# Print the plot
print(plot)


# ----------------- Benchmark Sub groups analysis -----------------


library(MLmetrics)

# ----- Print F1 scores per tone --
for(current_tone in tone){
  
  Regex = readRDS("analysis/02_ML_benchmark/data/03_Regex/Regex.rds")
  NB = readRDS("analysis/02_ML_benchmark/data/04_NB/NB.rds")
  LSTM = readRDS("analysis/02_ML_benchmark/data/05_LSTM/LSTM.rds")
  GPT4_SLCA = readRDS("analysis/02_ML_benchmark/data/02_GPT4/GPT4_SLCA.rds")
  GPT4_SCA = readRDS("analysis/02_ML_benchmark/data/02_GPT4/GPT4_SCA.rds")
  GPT4_LCA = readRDS("analysis/02_ML_benchmark/data/02_GPT4/GPT4_LCA.rds")
  GS = readRDS("analysis/02_ML_benchmark/data/01_Gold_standard/GS.rds")
  Llama3_SLCA = readRDS("analysis/02_ML_benchmark/data/06_Llama3/Llama3_SLCA.rds")
  Llama3_SCA = readRDS("analysis/02_ML_benchmark/data/06_Llama3/Llama3_SCA.rds")
  Llama3_LCA = readRDS("analysis/02_ML_benchmark/data/06_Llama3/Llama3_LCA.rds")
  # LLMs without Consistency Assessment
  GPT4 = readRDS("analysis/02_ML_benchmark/data/02_GPT4/GPT4.rds")
  Llama3 = readRDS("analysis/02_ML_benchmark/data/06_Llama3/Llama3.rds")
  
  Regex = Regex[,,tone==current_tone]
  NB = NB[,,tone==current_tone]
  LSTM = LSTM[,,tone==current_tone]
  GPT4 = GPT4[,,tone==current_tone]
  GPT4_SCA = GPT4_SCA[,,tone==current_tone]
  GPT4_LCA = GPT4_LCA[,,tone==current_tone]
  GPT4_SLCA = GPT4_SLCA[,,tone==current_tone]
  GS = GS[,,tone==current_tone]
  Llama3 = Llama3[,,tone==current_tone]
  Llama3_SCA = Llama3_SCA[,,tone==current_tone]
  Llama3_LCA = Llama3_LCA[,,tone==current_tone]
  Llama3_SLCA = Llama3_SLCA[,,tone==current_tone]
  
  
  results = matrix(data=current_tone, nrow=1,ncol=1)
  
  # Print F1 scores
  NB[NB>0.5]=1
  NB[NB!=1]=0
  results = rbind(results, paste("F1 NB          -",round(F1_Score(y_true=GS, y_pred=NB),4)))
  results = rbind(results, paste("F1 Regex       -",round(F1_Score(y_true=GS, y_pred=Regex),4)))
  LSTM[LSTM>0.5]=1
  LSTM[LSTM!=1]=0
  results = rbind(results, paste("F1 LSTM        -",round(F1_Score(y_true=GS, y_pred=LSTM),4)))
  results = rbind(results, paste("F1 Regex       -",round(F1_Score(y_true=GS, y_pred=Regex),4)))
  results = rbind(results, paste("F1 GPT4        -",round(F1_Score(y_true=GS, y_pred=GPT4),4)))
  results = rbind(results, paste("F1 GPT4_SCA    -",round(F1_Score(y_true=GS, y_pred=GPT4_SCA),4)))
  results = rbind(results, paste("F1 GPT4_LCA    -",round(F1_Score(y_true=GS, y_pred=GPT4_LCA),4)))
  results = rbind(results, paste("F1 GPT4_SLCA   -",round(F1_Score(y_true=GS, y_pred=GPT4_SLCA),4)))
  results = rbind(results, paste("F1 Llama3      -",round(F1_Score(y_true=GS, y_pred=Llama3),4)))
  results = rbind(results, paste("F1 Llama3_SCA  -",round(F1_Score(y_true=GS, y_pred=Llama3_SCA),4)))
  results = rbind(results, paste("F1 Llama3_LCA  -",round(F1_Score(y_true=GS, y_pred=Llama3_LCA),4)))
  results = rbind(results, paste("F1 Llama3_SLCA -",round(F1_Score(y_true=GS, y_pred=Llama3_SLCA),4)))
  print(results)
}




# -------- Print F1 score per category-tone --
# Main result file skeleton 
F1s = data.frame(
  Categorie_tone = vector(),
  F1_regex = vector(),
  F1_nb = vector(),
  F1_lstm = vector(),
  
  F1_Llama3 = vector(),
  F1_Llama3_SCA = vector(),
  F1_Llama3_LCA = vector(),
  F1_Llama3_SLCA = vector(),
  
  F1_gpt4= vector(),
  F1_gpt4_SCA = vector(),
  F1_gpt4_LCA = vector(),
  F1_gpt4_SLCA = vector()
)

library(MLmetrics)

for(current_category in 1:length(category)){
  for(current_tone in tone){
    
    # Load matrices
    Regex = readRDS("analysis/02_ML_benchmark/data/03_Regex/Regex.rds")
    NB = readRDS("analysis/02_ML_benchmark/data/04_NB/NB.rds")
    NB[NB>0.5] = 1 # Threshold the NB
    NB[NB!=1] = 0
    LSTM = readRDS("analysis/02_ML_benchmark/data/05_LSTM/LSTM.rds")
    LSTM[LSTM>0.5] = 1 # Threshold the LSTM
    LSTM[LSTM!=1] = 0
    
    Llama3 = readRDS("analysis/02_ML_benchmark/data/06_Llama3/Llama3.rds")
    Llama3_SCA = readRDS("analysis/02_ML_benchmark/data/06_Llama3/Llama3_SCA.rds")
    Llama3_LCA = readRDS("analysis/02_ML_benchmark/data/06_Llama3/Llama3_LCA.rds")
    Llama3_SLCA = readRDS("analysis/02_ML_benchmark/data/06_Llama3/Llama3_SLCA.rds")
    
    GPT4 = readRDS("analysis/02_ML_benchmark/data/02_GPT4/GPT4.rds")
    GPT4_SCA = readRDS("analysis/02_ML_benchmark/data/02_GPT4/GPT4_SCA.rds")
    GPT4_LCA = readRDS("analysis/02_ML_benchmark/data/02_GPT4/GPT4_LCA.rds")
    GPT4_SLCA = readRDS("analysis/02_ML_benchmark/data/02_GPT4/GPT4_SLCA.rds")
    
    GS = readRDS("analysis/02_ML_benchmark/data/01_Gold_standard/GS.rds")
    
    #Subgroup the matrices
    Regex = Regex[,current_category,current_tone]
    NB = NB[,current_category,current_tone]
    LSTM = LSTM[,current_category,current_tone]
    
    Llama3 = Llama3[,current_category,current_tone]
    Llama3_SCA = Llama3_SCA[,current_category,current_tone]
    Llama3_LCA = Llama3_LCA[,current_category,current_tone]
    Llama3_SLCA = Llama3_SLCA[,current_category,current_tone]
    
    GPT4 = GPT4[,current_category,current_tone]
    GPT4_SCA = GPT4_SCA[,current_category,current_tone]
    GPT4_LCA = GPT4_LCA[,current_category,current_tone]
    GPT4_SLCA = GPT4_SLCA[,current_category,current_tone]
    
    GS = GS[,current_category,current_tone]
    
    # Compute F1 scores 
    F1_regex = round(F1_Score(y_true=GS, y_pred=Regex),2)
    F1_nb = round(F1_Score(y_true=GS, y_pred=NB),2)
    F1_lstm = round(F1_Score(y_true=GS, y_pred=LSTM),2)
    
    F1_Llama3 = round(F1_Score(y_true=GS, y_pred=Llama3),2)
    F1_Llama3_SCA = round(F1_Score(y_true=GS, y_pred=Llama3_SCA),2)
    F1_Llama3_LCA = round(F1_Score(y_true=GS, y_pred=Llama3_LCA),2)
    F1_Llama3_SLCA = round(F1_Score(y_true=GS, y_pred=Llama3_SLCA),2)
    
    F1_gpt4= round(F1_Score(y_true=GS, y_pred=GPT4),2)
    F1_gpt4_SCA = round(F1_Score(y_true=GS, y_pred=GPT4_SCA),2)
    F1_gpt4_LCA = round(F1_Score(y_true=GS, y_pred=GPT4_LCA),2)
    F1_gpt4_SLCA = round(F1_Score(y_true=GS, y_pred=GPT4_SLCA),2)
    
    
    # Append the main file
    current_F1 = data.frame(
      Categorie_tone = paste0(category.en[current_category]," - " ,ifelse(current_tone=="positive","favorable","unfavorable")),
      F1_regex = F1_regex,
      F1_nb = F1_nb,
      F1_lstm = F1_lstm,
      
      F1_Llama3 = F1_Llama3,
      F1_Llama3_SCA = F1_Llama3_SCA,
      F1_Llama3_LCA = F1_Llama3_LCA,
      F1_Llama3_SLCA = F1_Llama3_SLCA,
      
      F1_gpt4= F1_gpt4,
      F1_gpt4_SCA = F1_gpt4_SCA,
      F1_gpt4_LCA = F1_gpt4_LCA,
      F1_gpt4_SLCA = F1_gpt4_SLCA
    )
    F1s = rbind(F1s, current_F1)
    
  }
}

# Rename the columns
colnames(F1s) = c(
  "Category-tone",
  "Regex F1",
  "Naive Bayes F1",
  "LSTM F1",
  
  "Llama-3 F1",
  "Llama-3+SCA F1",
  "Llama-3+LCA F1",
  "Llama-3+SLCA F1",
  
  "GPT-4 F1",
  "GPT-4+SCA F1",
  "GPT-4+LCA F1",
  "GPT-4+SLCA F1"
)

library(formattable)

# Create a formattable object with custom formatting

# Define a custom formatter function
color_cells <- formatter("span",
                         style = x ~ ifelse(x <= 0.95,
                                            "background-color:pink; color:black;",
                                            "background-color:white; color:black;")
)

pretty_table <- formattable(F1s, list(
  `Regex F1` = color_cells,
  `Naive Bayes F1` = color_cells,
  `LSTM F1` = color_cells,
  
  `Llama-3 F1` = color_cells,
  `Llama-3+SCA F1` = color_cells,
  `Llama-3+LCA F1` = color_cells,
  `Llama-3+SLCA F1` = color_cells,
  
  `GPT-4 F1` = color_cells,
  `GPT-4+SCA F1` = color_cells,
  `GPT-4+LCA F1` = color_cells,
  `GPT-4+SLCA F1` = color_cells
))

# Print the table
pretty_table
