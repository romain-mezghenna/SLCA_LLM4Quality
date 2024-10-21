#This code defines categories, tones, and feedbacks (verbatims) to consider.

# Check if the active directory is the repository folder
getwd()

library(xlsx)
# store the categories names (French):
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
# store the categories names (English):
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

# Possible polarities. "positive" means it is a favorable tone, "negative" that it is a unfavorable tone 
tone = c("positive","negative")

# Define the index according to the feedback numeration you want to analyse. Article results are set for 1:100 
library(xlsx)
verbatims = read.xlsx("analysis/01_Humans_GPT4_and_CA_performances/data/00_sample/verbatims.xlsx",sheetIndex=1)
index = verbatims$id

