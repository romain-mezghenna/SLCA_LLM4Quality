# This code create the three dimensional array to describe the human classifications from the multiple xlsx tables filled by each agent.

# Define the correspondence between the files
epl_folder  = "analysis/01_Humans_GPT4_and_CA_performances/data/03_Humans/01_Classification_EPL/"
sg_folder   = "analysis/01_Humans_GPT4_and_CA_performances/data/03_Humans/02_Classification_SG/"
xd_folder = "analysis/01_Humans_GPT4_and_CA_performances/data/03_Humans/03_Classification_XD/"

# Store the possible humans agents
agent = c("EPL","SG","XD")

#The data frame files_correspondence represent the correspondence between the files of the different classifications.
files_correspondence = data.frame(
  EPL  = vector(),
  SG   = vector(),
  XD = vector()
)

# Feed files_correspondence with the 100 verbatims from e-satis

for(i in 0:99){
  new_file = c(
    paste(epl_folder,i,"_output_tas_EPL.xlsx", sep=""),
    paste(sg_folder,i,"_output_tas_SG.xlsx", sep=""),
    paste(xd_folder,i,"_output_tas_XD.xlsx", sep="")
  )
  files_correspondence[nrow(files_correspondence)+1,] = new_file
}

# Create the matrix_GS that gather the classification of the 3 experts :

# Create the array skeleton
matrix_humans = array(data=NA, dim=c(
  length(index),
  length(category),
  length(tone),
  length(agent)
), 
dimnames = list(index,category,tone,agent))

# Feed the array for each verbatim
library(xlsx)


for(i in 1:length(index)){ # iterates through verbatims
  for(current_agent in agent){ # iterates through agents
    file_path = files_correspondence[
      i,which(colnames(files_correspondence)==current_agent)]
    
    #read the xlsx file corresponding to the current_agent and the verbatim i
    input = read.xlsx(file = file_path, sheetIndex = 2)
    current_tones = trimws(input[,5])
    
    #Humans select information only if they identify a category/tone
    # tone == "positive"
    current_positives = trimws(input[which(
      current_tones=="Positif" |
        current_tones=="positif"
    ),3])
    if(length(current_positives>0)) matrix_humans[i,which(category %in% current_positives),tone=="positive",agent=current_agent] = 1
    # tone == "negative"
    current_negatives = trimws(input[which(
      current_tones=="Négatif" |
        current_tones=="négatif" |
        current_tones=="Negatif" |
        current_tones=="negatif" 
    ),3])
    if(length(current_negatives>0)) matrix_humans[i,which(category %in% current_negatives),tone=="negative",agent=current_agent] = 1
  }
}
# Replace the NA with zeros
matrix_humans[is.na(matrix_humans)]=0

saveRDS(matrix_humans, "analysis/01_Humans_GPT4_and_CA_performances/data/03_Humans/humans.rds")
