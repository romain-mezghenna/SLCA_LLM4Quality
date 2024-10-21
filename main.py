from consistency_llm.consistency_evaluation.sca_evaluation import ScaEvaluation
from consistency_llm.consistency_evaluation.slca_evaluation import SlcaEvaluation
from consistency_llm.consistency_evaluation.lca_evaluation import LcaEvaluation
from consistency_llm.llm_queries.few_shot_cot_classification import FewShotCotClassification
from consistency_llm.llm_queries.initial_classification import InitialClassification
import argparse

# Retrieve output directory
parser = argparse.ArgumentParser(description="Process some arguments.")
parser.add_argument('--output-dir', type=str, required=True, help='Output directory name')
parser.add_argument('--input-csv', type=str, required=True, help='Input CSV file')
args = parser.parse_args()
output_dir = args.output_dir
input_csv = args.input_csv

# LLM queries
initial_classification = InitialClassification(input_csv, output_dir)
initial_classification.run()
few_shot_cot_classification = FewShotCotClassification(input_csv, output_dir)
few_shot_cot_classification.run()

# Consistency evaluation
sca_evaluation = ScaEvaluation(output_dir)
sca_evaluation.run()
lca_evaluation = LcaEvaluation(output_dir)
lca_evaluation.run()
slca_evaluation = SlcaEvaluation(output_dir)
slca_evaluation.run()