#This code trains and evaluates Long short term memory in a 10 fold cross validation.

GS = readRDS("analysis/02_ML_benchmark/data/01_Gold_standard/GS.rds")

# Create the array skeleton for the classification
matrix_LSTM = array(data=NA, dim=c(
  length(index),
  length(category),
  length(tone)
), 
dimnames = list(index,category,tone))


# Create a vector of preprocessed verbatims from the previous analysis
verbatims = corpus$content

library(dplyr)
library(keras)
library(tensorflow)
library(reticulate)
# install_tensorflow() # If tensorflow is not already intalled

# Set seed for reproducibility
set.seed(456)

# Tokenize the text
tokenizer <- text_tokenizer()
fit_text_tokenizer(tokenizer, verbatims)
# Convert the text to sequences
sequences <- texts_to_sequences(tokenizer, verbatims)
# Pad sequences to ensure equal length
verbatims =  pad_sequences(sequences)
# Convert verbatims to integer type
verbatims <- matrix(as.integer(verbatims), nrow = nrow(verbatims), ncol = ncol(verbatims))
# Verbatims is now a matrix representing the sequence of each verbatim
# Its dim are 1170 rows (one for each verbatim), 
# for 158 columns (max length for any verbatim in this set)


# The 10-folds takes about 5 hours computation on a i7 processor. The log allows you to run it over multiple sessions by modifying the for loop.
# It is advised to run only if you want to check the reproducibility of the results.
# The folds are defined in the previous script 04_create_NB_matrix.R

# Beware that LSTM needs a minimum volume of data to be efficient. Toy examples return numerous execptions avoiding prediction.

for(i in 1:ncol(folds)){
  print("-----------------------------------------------------------------------------------------------------")
  print(paste("Beginning fold",i))
  print("-----------------------------------------------------------------------------------------------------")
  current_fold = which(index %in% as.vector(na.omit(folds[,i])))
  other_folds = which(index %in% as.vector(na.omit(as.vector(folds[,-i]))))

  for(current_category in 1:length(category)){
    for(current_tone in 1:length(tone)){

      if(file.exists("analysis/02_ML_benchmark/data/05_LSTM/LSTM.rds")){
        matrix_LSTM = readRDS("analysis/02_ML_benchmark/data/05_LSTM/LSTM.rds")
      }

      print(paste("Beginning category",current_category,":",category[current_category], ",",tone[current_tone]))

      # Prepare the model
      model <- keras_model_sequential()
      # Add Input layer
      model$add(layer_input(shape = list(ncol(verbatims)), dtype = 'int32'))
      # Add layers using $add()
      model$add(layer_embedding(
        input_dim = max(unlist(verbatims)) + 1,
        output_dim = 50
      ))
      model$add(layer_lstm(units = 50, return_sequences = TRUE))
      model$add(layer_lstm(units = 50, return_sequences = FALSE))
      model$add(layer_dense(units = 1, activation = 'sigmoid'))

      # Compile the model
      model$compile(
        loss = 'binary_crossentropy',
        optimizer = 'adam',
        metrics = list('accuracy')
      )

      # Convert GS to categorical labels
      target = GS[,current_category,current_tone]

      if(length(table(target)) ==1){
        print(paste("warning : Gold standard has only 1 value for this current_category and current_tone :",category[current_category],tone[current_tone], ". 1's effectives =", length(which(GS[other_folds,current_category,current_tone]==1))))
        output = GS[current_fold,current_category,current_tone]
      }else{

        class_weight <- dict()
        class_weight[[0L]] <- 1
        class_weight[[1L]] <- 20

        # Prepare training data
        x_train <- verbatims[other_folds, ]
        x_train <- matrix(as.integer(x_train), nrow = nrow(x_train), ncol = ncol(x_train))

        # Ensure target is numeric (float)
        y_train <- as.numeric(target[other_folds])

        # Prepare test data
        x_test <- verbatims[current_fold, ]
        x_test <- matrix(as.integer(x_test), nrow = nrow(x_test), ncol = ncol(x_test))


        # Convert x_train and y_train to TensorFlow tensors
        x_train <- tf$constant(x_train, dtype = tf$int32)
        y_train <- tf$constant(y_train, dtype = tf$float32)

        # Train the model
        history <- model$fit(
          x = x_train,
          y = y_train,
          epochs = 10L,
          batch_size = 32L,
          class_weight = class_weight
        )

        # Predict
        output = model$predict(x_test)
      }
      matrix_LSTM[current_fold,current_category,current_tone] = output
      saveRDS(matrix_LSTM, "analysis/02_ML_benchmark/data/05_LSTM/LSTM.rds")

      # Save progress into a log in case of intercurrent issue.
      write.table(paste(Sys.time()," : current_fold :",i,"; current_category :",current_category,"; current_tone :",current_tone,"; done"),"analysis/02_ML_benchmark/data/05_LSTM/log.txt",append=TRUE)
    }
  }
}

