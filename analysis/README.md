
# Analysis of consistency assessed LLMs performances on patient feedback classification

## Overview
The folder analysis allow to compare the performances of humans versus classical machine learning versus LLM standalone versus consistency assessed over patient feedback classification. This repository contains toy examples. To reproduce the results of the article "Logical Consistency Elevates LLMs To Experts Level in Patient Feedback Classification", the toy examples have to be replaced in your local repository by the original data, provided by the research ERIOS team on reasonable request at z-loi@chu-montpellier.fr.


## Usage

### Requirements

```bash
r > 4.4.1

# Specific libraries :
Biobase from Bioconductor > 3.19
tensorflow for R > 2.16
```

The analysis of performances requires access to patient feedbacks to classify and to have produced consistency assessed LLMs predictions.
Patient feedbacks are meant to be stored respectively in the xlsx files :
- analysis\01_Humans_GPT4_and_CA_performances\data\00_sample\verbatims.xlsx
- analysis\02_ML_benchmark\data\00_sample\verbatims.xlsx
The patients feedbacks must have been classified by human agents as gold standards, which results must be stored in xlsx files with a structure identical to those provided in toy examples :
- analysis\01_Humans_GPT4_and_CA_performances\data\01_Gold_standard\positive_table.xlsx
- analysis\01_Humans_GPT4_and_CA_performances\data\01_Gold_standard\negative_table.xlsx

To run the LLMs predictions :
#### With GPT-4 API active
```bash
poetry run python3 main.py --output-dir="analysis\01_Humans_GPT4_and_CA_performances\data\02_GPT4\output_gpt4-1" --input-csv="analysis\01_Humans_GPT4_and_CA_performances\data\00_sample\verbatims.xlsx"
poetry run python3 main.py --output-dir="analysis\01_Humans_GPT4_and_CA_performances\data\02_GPT4\output_gpt4-2" --input-csv="analysis\01_Humans_GPT4_and_CA_performances\data\00_sample\verbatims.xlsx"
poetry run python3 main.py --output-dir="analysis\01_Humans_GPT4_and_CA_performances\data\02_GPT4\output_gpt4-3" --input-csv="analysis\01_Humans_GPT4_and_CA_performances\data\00_sample\verbatims.xlsx"
poetry run python3 main.py --output-dir="analysis\02_ML_benchmark\data\02_GPT4" --input-csv="analysis\02_ML_benchmark\data\00_sample\verbatims.xlsx"
```
#### With Llama3.1 API active
```bash
poetry run python3 main.py --output-dir="analysis\02_ML_benchmark\data\02_GPT4" --input-csv="analysis\02_ML_benchmark\data\00_sample\verbatims.xlsx"
```

### Configuration
To run the R scripts properly, it is required that the working directory is and remains the root folder of the github repository.
Any attempt with any other setting will result shortly in a path error.

## Run
For each experiment represented by a sub-folder in the analysis folder, R scripts are required to be run in numeric order.
In 01_Humans_GPT4_and_CA_performances, between script 05_create_GPT4_CA_error_list.R and 06_hallucination_rates.R, a human must classify each error of GPT4 from :
- analysis\01_Humans_GPT4_and_CA_performances\data\02_GPT4\GPT4_output_1_errors.xlsx
- analysis\01_Humans_GPT4_and_CA_performances\data\02_GPT4\GPT4_output_2_errors.xlsx
- analysis\01_Humans_GPT4_and_CA_performances\data\02_GPT4\GPT4_LCA_SLCA_errors_1.xlsx
- analysis\01_Humans_GPT4_and_CA_performances\data\02_GPT4\GPT4_LCA_SLCA_errors_2.xlsx
Determining for each row the presence or absence of extrinsic faithfulness hallucinations. This classification must be stored respectively in the xlsx files :
- analysis\01_Humans_GPT4_and_CA_performances\data\02_GPT4\GPT4_hallucinations_check_1.xlsx
- analysis\01_Humans_GPT4_and_CA_performances\data\02_GPT4\GPT4_hallucinations_check_2.xlsx
- analysis\01_Humans_GPT4_and_CA_performances\data\02_GPT4\GPT4_LCA_SLCA_hallucination_check_1.xlsx
- analysis\01_Humans_GPT4_and_CA_performances\data\02_GPT4\GPT4_LCA_SLCA_hallucination_check_2.xlsx
The structure of the file must be identical to the toy example's one.

## Analysis Explanations
### Input data

The methods needs the following data :
- All texts to classify must be stored as independant txt files stored in the path according to previous directives.
- A human made scope of the categories defined by the available implication ensuring Logical consistency must be provided as a json file stored in "datas/categories.json".
- The two prompts (initial_classification_prompt.txt and few_shot_cot_classification_prompt.txt) used to direct LLMs stored in "datas/".

initial_classification_prompt.txt contains general good practices in prompt engineering to perform sel-consistency assessment (SCA).
few_shot_cot_classification_prompt.txt applies philosophy of logic agruments assessment methods to direct the LLM to provide a structured chain of thought to perform logical consistency assessment (LCA).

### LLM raw classification

Four raw outputs per feedback are generated as independant txt files stored in their respective folders : output_{model_name}/llm_queries/output1 and output_{model_name}/llm_queries/output2.
Each folder contain two generated raw outputs as follows :
- initial_classification_result_1_x.txt
- few_shot_cot_classification_result_1_x.txt

The initial classification generation takes in entry the feedback and the prompt initial_classification_prompt.txt to provide a LLM classification with classical prompt engineering.
The few shot classification generation takes in entry the feedback, the initial_classification_result_1.txt, the categories.json and the prompt few_shot_cot_classification_prompt.txt to direct the LLM to provide a structured chain of thought.

The "_x" at the end of the files names correspond to the index of the corresponding feedback.
The computation minimize the number of needed API requests. Only four API resquests are needed to classify a text with every three methods.
Every txt output will follow a json structure. This structure might be invalid depending on the chosen LLM and its performances. The json structure is described as following :
```json
{
    "Category group 1" :{
        "Category name 1" :{
            "positive":"",
            "negative" :"",
            "neutral" :"",
            "not mentionned" :""
        },...
    },...
}
```
The positive key has a value if the category is favorably mentionned.
The negative key has a value if the category is unfavorably mentionned.
The neutral key has a value if the category is mentionned but the tone is not oriented in either polarity.
The not mentionned key has a value if the category is not mentionned.
The values are directed to be a chain of thought justifying the mention identification.
The key difference between each method relies on the interpretation method of these chain of thought.

### LLM parsed classification

#### Self-consistency

Self-consistency assessed prediction is applied as follows :
- Apply initial classification prompt merged with the feedback to classify
- Repeat step 1

Only categories/tones identified twice will be kept and stored as 1 in the corresponding parsed classification as a json file with the following structure :
```json
{
    "Category name 1": {
            "positive": 1,
            "negative": 0
    },...
}
```
This result is stored in output_{model_name}/evaluations/sca/result_x.json

#### Logical consistency

Logical consistency assessed prediction is applied as follows :
- Retrieve a LLM standalone assessed prediction
- Resume the conversation with the LLM by sending few shot classification prompt merged with categories.json

The LLM response will contain revised prediction with structured CoT. Logical consistency will be assessed if at least one of the two CoT checks the needed requirements.
These requirements are : 
- The argument to define a category as present must contain as directed the character pipe "|"
- At least 4 characters must follow the pipe character
- The string preceding the pipe charcater must be a valid implication of the adequate category in the categories.json.

The LLM is directed to provide a citation of the verbatim after the pipe character. However, as feedbacks contain often typos and LLMs tend to corrects them, it is more robust to only check the presence of a sufficiently lengthy string after the "|".

Only categories/tones identified with a valid CoT are kept and stored as 1 in the corresponding parsed classification as a json file with the following structure :
```json
{
    "Category name 1": {
            "positive": 1,
            "negative": 0
    },...
}
```
This result is stored in output_{model_name}/evaluations/lca/result_x.json

#### Self-logical consistency

The Self-logical consistency prediction is generated performing SCA then LCA classifications. The two predictions of SCA are directed with the CoT logical structuration prompt. Only categories identified twice, fulfilling SCA, and providing at least one valid CoT structure, fulfilling LCA, are considered as Self-logical consistency assessed. 
This result is stored in output_{model_name}/evaluations/slca/result_x.json

### Other machine learning models predictions

#### Regex
The Regex is a model owned by the University Hospital Center of Montpellier, France. the structure of its decision tree cannot be published. Its classification results are presented with the same structure presented in the corresponding toy example

#### Naive Bayes
A dimensional reduction is operated on the feedback corpus using a non-negative matrix factorization. The Naive Bayes algorithm is trained and evaluated for each category to identify in 10 fold-crossvalidation.

#### Long short term memory
A simple numerical vectorization of the feedback corpus is perfomed without embedding. The Long Short Term Memory algorithm is trained and evaluated for each category to identify in 10 fold-crossvalidation.

### Performances measurement

#### Data parsing

The ensemble of the results for one agent type are stored for convenience in a 4d boolean matrix. The dimensions represent : 

- Each row of the matrix correspond to a text
- Each colomn correspond to a category
- The two 3d slices correspond respectively to the favorable tone and the unfavorable tone.
- The three 4d slices respresent each agent.

As 5 types of agents and 1 gold standard are presented in Humans_GPT4_and_CA experiments and as each type contains 3 different agents, the corresponding matrices will be :
- analysis/01_Humans_GPT4_and_CA_performances/data/01_Gold_standard/GS.rds
- analysis/01_Humans_GPT4_and_CA_performances/data/03_Humans/humans.rds
- analysis/01_Humans_GPT4_and_CA_performances/data/02_GPT4/GPT4.rds
- analysis/01_Humans_GPT4_and_CA_performances/data/02_GPT4/GPT4_SCA.rds
- analysis/01_Humans_GPT4_and_CA_performances/data/02_GPT4/GPT4_LCA.rds
- analysis/01_Humans_GPT4_and_CA_performances/data/02_GPT4/GPT4_SLCA.rds

The gold standard is constituted of three times the 3d matrix of the established gold standard.

As 11 agents (GPT-4,, GPT-4+SCA, GPT-4+LCA GPT-4+SLCA, Llama-3, Llama-3+SCA, Llama-3+LCA, Llama-3+SLCA, Naive Bayes, Long Short Term Memory, Regex) and 1 gold standard are presented for the benchmark experiments, the corresponding 3d matrices are :
- analysis/02_ML_benchmark/data/01_Gold_standard/GS.rds
- analysis/02_ML_benchmark/data/02_GPT4/GPT4.rds
- analysis/02_ML_benchmark/data/02_GPT4/GPT4_SCA.rds
- analysis/02_ML_benchmark/data/02_GPT4/GPT4_LCA.rds
- analysis/02_ML_benchmark/data/02_GPT4/GPT4_SLCA.rds
- analysis/02_ML_benchmark/data/03_Regex/Regex.rds
- analysis/02_ML_benchmark/data/04_NB/NB.rds
- analysis/02_ML_benchmark/data/05_LSTM/LSTM.rds
- analysis/02_ML_benchmark/data/06_Llama3/Llama3.rds
- analysis/02_ML_benchmark/data/06_Llama3/Llama3_SCA.rds
- analysis/02_ML_benchmark/data/06_Llama3/Llama3_LCA.rds
- analysis/02_ML_benchmark/data/06_Llama3/Llama3_SLCA.rds

As only one agent of each type is presented in the benchmark experiment, there is no fourth dimension.

#### Performances evaluation

Once the numeric matrices are produced, the performances evaluation can be performed with comparison with the human-led gold standard of similar structure.
The explored metrics are for each agent : precision, recall, precision-recall area under the curve, global accuracy, and reproducibility (Krippendorff's alpha) between agents of the same type. The Humans_GPT4_and_CA experiment explore extrinsic faithfulness hallucinations as well.
Performances metrics and classical machine learning predictions are computed through the R scripts in the folders :
- analysis/01_Humans_GPT4_and_CA_performances
- analysis/02_ML_benchmark
- analysis/03_Supplementary_data
Each scripts are numbered and meant to be computed in order.

### Data avalaibility

The raw data access wil be granted to any reasonable request to the corresponding authors after article submission (cf top of the document).
