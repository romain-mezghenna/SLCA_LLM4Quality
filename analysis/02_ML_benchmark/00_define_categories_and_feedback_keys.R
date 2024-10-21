# This code define categories and feedback(verbatims) identification key


# Check if the active directory is the main folder of the repository. 
getwd()
library(xlsx)

# store the categories names :
category = c(
  "La fluidité et la personnalisation du parcours",
  "L’accueil et l’admission",
  "Le circuit administratif" ,
  "La rapidité de prise en charge et le temps d’attente" ,
  "L’accès au bloc" ,
  "La sortie de l’établissement" ,
  "Le suivi du patient après le séjour hospitalier" ,
  "Les frais supplémentaires et dépassements d’honoraires" ,
  "L’information et les explications" ,
  "L’humanité et la disponibilité des professionnels" ,
  "Les prises en charges médicales et paramédicales", 
  "Gestion de la douleur et médicaments" ,
  "Maternité et pédiatrie" ,
  "L’accès à l’établissement" ,
  "Les locaux et les chambres" ,
  "L’intimité" ,
  "Le calme/volume sonore" ,
  "La température de la chambre" ,
  "Les repas et collations" ,
  "Les services WiFi et TV",
  "Droits des patients"
)
category.en = c(
  "Fluidity and personalization of the care pathway",
  "Reception and admission",
  "Administrative process",
  "Speed of care and waiting time",
  "Access to the operating room",
  "Discharge from the facility",
  "Follow-up care after hospital stay",
  "Additional costs and extra fees",
  "Information and explanations",
  "Humanity and availability of professionals",
  "Medical and paramedical care",
  "Pain management and medication",
  "Maternity and pediatrics",
  "Access to the facility",
  "Facilities and rooms",
  "Privacy",
  "Calm/noise level",
  "Room temperature",
  "Meals and snacks",
  "WiFi and TV services",
  "Patient rights"
)

tone = c("positive","negative")


# Define the index according to the feedback numeration you want to analyse. Article results are set for 1:100 
library(xlsx)
verbatims = read.xlsx("analysis/02_ML_benchmark/data/00_sample/verbatims.xlsx",sheetIndex=1)
index = verbatims$id




# Create Gold standard matrix

library(xlsx)
negative_table = read.xlsx("analysis/02_ML_benchmark/data/01_Gold_standard/negative_table.xlsx", sheetIndex = 1)
positive_table = read.xlsx("analysis/02_ML_benchmark/data/01_Gold_standard/positive_table.xlsx", sheetIndex = 1)

# Create the array skeleton
matrix_GS = array(data=NA, dim=c(
  length(index),
  length(category),
  length(tone)
),dimnames = list(index,category,tone))

matrix_GS[,,"negative"] = as.matrix(negative_table[,-1])
matrix_GS[,,"positive"] = as.matrix(positive_table[,-1])

dimnames(matrix_GS) = list(index,category,tone)


saveRDS(matrix_GS, "analysis/02_ML_benchmark/data/01_Gold_standard/GS.rds")

