#This code provides p-values to measure classifications differences between humans and GPT4 +/-CA  models 


GS = readRDS("analysis/01_Humans_GPT4_and_CA_performances/data/01_Gold_standard/GS.rds")
GPT4 = readRDS("analysis/01_Humans_GPT4_and_CA_performances/data/02_GPT4/GPT4.rds")
GPT4_SCA = readRDS("analysis/01_Humans_GPT4_and_CA_performances/data/02_GPT4/GPT4_SCA.rds")
GPT4_LCA = readRDS("analysis/01_Humans_GPT4_and_CA_performances/data/02_GPT4/GPT4_LCA.rds")
GPT4_SLCA = readRDS("analysis/01_Humans_GPT4_and_CA_performances/data/02_GPT4/GPT4_SLCA.rds")
humans = readRDS("analysis/01_Humans_GPT4_and_CA_performances/data/03_Humans/humans.rds")


#GPT-4 standalone vs humans
contingent_table = table(as.vector(humans),as.vector(GPT4))
mcnemar.test(contingent_table)


#GPT-4 +SCA vs humans
contingent_table = table(as.vector(humans),as.vector(GPT4_SCA))
mcnemar.test(contingent_table)

#GPT-4 +LCA vs humans
contingent_table = table(as.vector(humans),as.vector(GPT4_LCA))
mcnemar.test(contingent_table)


#GPT-4 +SLCA vs humans
contingent_table = table(as.vector(humans),as.vector(GPT4_SLCA))
mcnemar.test(contingent_table)
