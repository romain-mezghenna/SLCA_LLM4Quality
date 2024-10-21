#this code converts Regex output xlsx file into a R object matrix.

# -------------------------------------------------------------------------------------------------------------
# Step one : read Regex file
# -------------------------------------------------------------------------------------------------------------
library(openxlsx)
data = read.xlsx("analysis/02_ML_benchmark/data/03_Regex/Classification_Regex_format_Sphinx.xlsx")


# -------------------------------------------------------------------------------------------------------------
# Step two : convert the adequate data in the matrix
# -------------------------------------------------------------------------------------------------------------

# Create the array skeleton for the classification
matrixRegex = array(data=0, dim=c(
  length(index),
  length(category),
  length(tone)
), 
dimnames = list(index,category,tone))

for(i in index){
  for(current_category in category){
    if(grepl(gsub("’","'",current_category),data$Positif_Themes[i])){
      matrixRegex[i,current_category,"positive"] = 1
    }
    if(grepl(gsub("’","'",current_category),data$Negatif_Themes[i])){
      matrixRegex[i,current_category,"negative"] = 1
    }
  }
}
saveRDS(matrixRegex,"analysis/02_ML_benchmark/data/03_Regex/Regex.rds")

