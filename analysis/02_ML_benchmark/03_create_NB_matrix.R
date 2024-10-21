#This code trains and evaluates Naive Bayes in a 10 fold cross validation.

# -------------------------------------------------------------------------------------------------------------
# Step 0 : set up
# -------------------------------------------------------------------------------------------------------------

# Create the array skeleton for the classification
matrixNB = array(data=NA, dim=c(
  length(index),
  length(category),
  length(tone)
), 
dimnames = list(index,category,tone))


# Create a document term matrix  from all verbatims (same step for LSTM, we will do it only once, here)

library(tm)
library(e1071)

verbatims = openxlsx::read.xlsx("analysis/02_ML_benchmark/data/00_sample/verbatims.xlsx")$verbatim

# Read text files into a Corpus
corpus <- Corpus(VectorSource(verbatims))

# Preprocess the text
corpus <- tm_map(corpus, content_transformer(tolower))
corpus <- tm_map(corpus, removePunctuation)
corpus <- tm_map(corpus, removeNumbers)
corpus <- tm_map(corpus, removeWords, stopwords("fr"))  # Remove French stopwords
corpus <- tm_map(corpus, stripWhitespace)

# Create a Document-Term Matrix (DTM)
dtm <- DocumentTermMatrix(corpus)

# Convert as data-frame and assign appropriate column names
dtm_df <- as.data.frame(as.matrix(dtm))
colnames(dtm_df) <- make.names(colnames(dtm_df))
# Re-order the dtm_df (they are ordered by alphabetic order, not by indice)
rownames(dtm_df) = index

# Reduce the dimensions of the document term matrix with the NMF algorithm 

# Reduce the dimensions of the document term matrix

library(text)
# # NMF library Requires the external installation of Biobase (If not already installed) :
# if (!requireNamespace("BiocManager", quietly = TRUE))
#   install.packages("BiocManager")
# BiocManager::install("Biobase")
library(Biobase)
library(NMF)

k = 40  # Set the number of topics (factors) you want to extract

# /!\ Beware that the NMF and Naive Bayes cannot work under a certain volume of data. Toy examples are not numerous enough to allow it.

# # To avoid this very expensive calculus multiple times, it has been saved it in nmf_result.RDS. Run again only if you want to check the reproducibility of the results.
nmf_result <- NMF::nmf(dtm_df, rank = k, method = "snmf/r", nrun = 5)
saveRDS(nmf_result, "analysis/02_ML_benchmark/data/04_NB/NMF_result/nmf_result.RDS")
# nmf_result = readRDS("analysis/02_ML_benchmark/data/04_NB/NMF_result/nmf_result.RDS")
# Access the factorized matrices
W <- basis(nmf_result)  # Document-topic matrix, will be our training data
H <- coef(nmf_result)   # Term-topic matrix


# -------------------------------------------------------------------------------------------------------------
# Step 1 : Define the folds (same folds as LSTM)
# -------------------------------------------------------------------------------------------------------------

set.seed(123)

fold_size = trunc(length(index)/10)+1
folds = matrix(data=NA, ncol = 10, nrow = fold_size )

verbatims_left = index
for(i in 1:ncol(folds)){
  if(length(verbatims_left)<= fold_size){
    current_fold = verbatims_left 
  }else{
    current_fold = sample(x = verbatims_left, size = fold_size, replace = F)
    verbatims_left = verbatims_left[-which(verbatims_left %in% current_fold)]
  }
  folds[1:length(current_fold),i] = current_fold
  
}


# -------------------------------------------------------------------------------------------------------------
# Step 2 : train and predict NB in 10-fold cross validation
# -------------------------------------------------------------------------------------------------------------

set.seed(234)

# At each step, train on very verbatim but the current fold. Predict the current fold.
for(i in 1:ncol(folds)){
  
  current_fold = which(index %in% as.vector(na.omit(folds[,i])))
  other_folds = which(index %in% as.vector(na.omit(as.vector(folds[,-i]))))
  
  for(current_category in 1:length(category)){
    for(current_tone in 1:length(tone)){
      # print(paste("Beginning model",current_category,current_tone))
      
      current_model = naiveBayes(x = W[other_folds,] ,y =GS[other_folds,current_category,current_tone],laplace = 3 )
      
      if(length(table(GS[other_folds,current_category,current_tone]))==1){
        print(paste("warning : Gold standard has only 1 value for this current_category and current_tone :",category[current_category],tone[current_tone], ". 1's effectives =", length(which(GS[other_folds,current_category,current_tone]==1))))
        prediction = rep(0,length(current_fold))
      }else{
        prediction = predict(current_model, newdata = W[current_fold,], type="raw")
        prediction = prediction[,colnames(prediction)=="1"]
      }
      matrixNB[current_fold,current_category,current_tone] = prediction
    }
  }
}
# When there is very few values of a class in the Gold Standard, the prediction fails to provide a probability. by argument frequency, we automatically set these values to 0 to favor Naive Bayes.
matrixNB[is.na(matrixNB)] = 0
saveRDS(matrixNB, "analysis/02_ML_benchmark/data/04_NB/NB.rds")
