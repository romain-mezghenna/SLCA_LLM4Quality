# This code create the three dimensional array to describe the gold standard from the two xlsx tables filled by the fourth quality of care expert.

library(xlsx)
negative_table = read.xlsx("analysis/01_Humans_GPT4_and_CA_performances/data/01_Gold_standard/negative_table.xlsx", sheetIndex = 1)
positive_table = read.xlsx("analysis/01_Humans_GPT4_and_CA_performances/data/01_Gold_standard/positive_table.xlsx", sheetIndex = 1)

# Create the array skeleton
matrix_GS = array(data=NA, dim=c(
  length(index),
  length(category),
  length(tone)
),dimnames = list(index,category,tone))

matrix_GS[,,"negative"] = as.matrix(negative_table[,-1])
matrix_GS[,,"positive"] = as.matrix(positive_table[,-1])


dimnames(matrix_GS) = list(index,category,tone)


saveRDS(matrix_GS, "analysis/01_Humans_GPT4_and_CA_performances/data/01_Gold_standard/GS.rds")
