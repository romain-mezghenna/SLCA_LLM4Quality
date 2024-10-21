# This code evaluates the performances of humans, GPT4 standalone, GPT4+SCA, GPT4+LCA, GPT4+DCA to produce results of experiences 1 to 5

# import data
GS = readRDS("analysis/01_Humans_GPT4_and_CA_performances/data/01_Gold_standard/GS.rds")
GPT4_SCA = readRDS("analysis/01_Humans_GPT4_and_CA_performances/data/02_GPT4/GPT4_SCA.rds")
GPT4_LCA = readRDS("analysis/01_Humans_GPT4_and_CA_performances/data/02_GPT4/GPT4_LCA.rds")
GPT4_SLCA = readRDS("analysis/01_Humans_GPT4_and_CA_performances/data/02_GPT4/GPT4_SLCA.rds")
GPT4 = readRDS("analysis/01_Humans_GPT4_and_CA_performances/data/02_GPT4/GPT4.rds")
humans = readRDS("analysis/01_Humans_GPT4_and_CA_performances/data/03_Humans/humans.rds")


# Store the possible agents
agent = c("1","2","3")
# Create the array squeleton to create a 4 dimensional matrix encompassing three gold standard matrices along : GS2 
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

# The gold standard of reference is this new matrix designed to evaluate 3 agents at a time.
GS = GS2

print_results = function(){
  # humans mean performances
  errors = length(which(humans != GS))
  print(paste("humans errors :",errors))
  missing = length(which(humans[humans==0]!=GS[humans==0]))
  too_much = length(which(humans[humans==1]!=GS[humans==1]))
  print(paste("missing identifications :",missing,"; wrong identifications :", too_much))
  precision = round(length(which(humans[GS==1] ==1)) / length(which(humans==1)),2)
  recall = round(length(which(humans[GS==1] ==1)) / (length(which(GS==1))),2)
  print(paste("humans : precision =",precision,"; recall =",recall))
  
  print("-----")
  # GPT4 alone mean performances
  errors = (length(which(GPT4!= GS)))
  print(paste("GPT4 errors :",errors))
  missing = length(which(GPT4[GPT4==0]!=GS[GPT4==0]))
  too_much = length(which(GPT4[GPT4==1]!=GS[GPT4==1]))
  print(paste("missing identifications :",missing,"; wrong identifications :", too_much))
  precision = round(length(which(GPT4[GS==1] ==1)) / length(which(GPT4==1)),2)
  recall = round(length(which(GPT4[GS==1] ==1)) / (length(which(GS==1))),2)
  print(paste("GPT4 alone : precision =",precision,"; recall =",recall))
  
  
  print("-----")
  # GPT4_SCA mean performances
  errors = (length(which(GPT4_SCA!= GS)))
  print(paste("GPT4_SCA errors :",errors))
  missing = length(which(GPT4_SCA[GPT4_SCA==0]!=GS[GPT4_SCA==0]))
  too_much = length(which(GPT4_SCA[GPT4_SCA==1]!=GS[GPT4_SCA==1]))
  print(paste("missing identifications :",missing,"; wrong identifications :", too_much))
  precision = round(length(which(GPT4_SCA[GS==1] ==1)) / length(which(GPT4_SCA==1)),2)
  recall = round(length(which(GPT4_SCA[GS==1] ==1)) / (length(which(GS==1))),2)
  print(paste("GPT4_SCA : precision =",precision,"; recall =",recall))
  
  print("-----")
  # GPT4_LCA mean performances
  errors = (length(which(GPT4_LCA!= GS)))
  print(paste("GPT4_LCA errors :",errors))
  missing = length(which(GPT4_LCA[GPT4_LCA==0]!=GS[GPT4_LCA==0]))
  too_much = length(which(GPT4_LCA[GPT4_LCA==1]!=GS[GPT4_LCA==1]))
  print(paste("missing identifications :",missing,"; wrong identifications :", too_much))
  precision = round(length(which(GPT4_LCA[GS==1] ==1)) / length(which(GPT4_LCA==1)),2)
  recall = round(length(which(GPT4_LCA[GS==1] ==1)) / (length(which(GS==1))),2)
  print(paste("GPT4_LCA : precision =",precision,"; recall =",recall))
  
  print("-----")
  # GPT4_SLCA mean performances
  errors = (length(which(GPT4_SLCA!= GS)))
  print(paste("GPT4_SLCA errors :",errors))
  missing = length(which(GPT4_SLCA[GPT4_SLCA==0]!=GS[GPT4_SLCA==0]))
  too_much = length(which(GPT4_SLCA[GPT4_SLCA==1]!=GS[GPT4_SLCA==1]))
  print(paste("missing identifications :",missing,"; wrong identifications :", too_much))
  precision = round(length(which(GPT4_SLCA[GS==1] ==1)) / length(which(GPT4_SLCA==1)),2)
  recall = round(length(which(GPT4_SLCA[GS==1] ==1)) / (length(which(GS==1))),2)
  print(paste("GPT4_SLCA : precision =",precision,"; recall =",recall))
  
}

print_results()

