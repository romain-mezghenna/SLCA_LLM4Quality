import pika
import json
import os
import time
import logging
from datetime import datetime, timezone
from pydantic import BaseModel, Field
from typing import Optional, Dict
from bson import ObjectId
from consistency_llm.consistency_evaluation.sca_evaluation import ScaEvaluation
from consistency_llm.consistency_evaluation.slca_evaluation import SlcaEvaluation
from consistency_llm.consistency_evaluation.lca_evaluation import LcaEvaluation
from consistency_llm.llm_queries.few_shot_cot_classification import FewShotCotClassification
from consistency_llm.llm_queries.initial_classification import InitialClassification

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

RABBITMQ_HOST = "localhost"
WORKER_REQUESTS_QUEUE = "worker_requests"
WORKER_RESPONSES_QUEUE = "worker_responses"
MAX_RETRIES = 5
RETRY_DELAY = 5  # seconds


# Verbatim model
class Verbatim(BaseModel):
    id: str = Field(default_factory=lambda: str(ObjectId()))
    content: str
    status: str
    result: Optional[Dict[str, Dict[str, str]]] = None
    year: int
    created_at: Optional[datetime] = Field(
        default_factory=lambda: datetime.now(timezone.utc)
    )

    class Config:
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        populate_by_name = True

    def to_json(self):
        return self.model_dump_json(by_alias=True, exclude_unset=True)

    @classmethod
    def from_json(cls, data: dict):
        return cls(
            id=str(data.get("id")) if data.get("id") else None,
            content=data["content"],
            status=data["status"],
            result=data.get("result"),
            year=data["year"],
            created_at=data.get("created_at"),
        )


def connect_to_rabbitmq():
    for attempt in range(MAX_RETRIES):
        try:
            logger.info(
                f"Attempting to connect to RabbitMQ (Attempt {attempt + 1}/{MAX_RETRIES})..."
            )
            connection = pika.BlockingConnection(
                pika.ConnectionParameters(host=RABBITMQ_HOST)
            )
            logger.info("Successfully connected to RabbitMQ.")
            return connection
        except pika.exceptions.AMQPConnectionError as e:
            logger.error(f"RabbitMQ connection failed: {e}")
            if attempt < MAX_RETRIES - 1:
                logger.info(f"Retrying in {RETRY_DELAY} seconds...")
                time.sleep(RETRY_DELAY)
            else:
                logger.error("Max retries reached. Could not connect to RabbitMQ.")
                raise


def process_verbatim_pipeline(verbatim: Verbatim) -> Verbatim:
    """
    Process the pipeline for a given verbatim message.
    """
    try:

        output_dir = f"/tmp/output_{verbatim.id}"
        input_csv = f"/tmp/input_{verbatim.id}.csv"

        # Write content to a CSV file
        with open(input_csv, "w") as csv_file:
            csv_file.write(verbatim.content)

        
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


        # Get the result from the output file 
        with open(f"{output_dir}/evaluations/result_1.json", "r") as file:
            processed_result = json.load(file).output

        
        # Update the Verbatim instance
        verbatim.result = processed_result
        verbatim.status = "SUCCESS"

        # Clears tmp files
        # TODO : Uncomment theses lines
        # os.remove(input_csv)
        # os.remove(output_dir)

        return verbatim

    except Exception as e:
        logger.error(f"Error in processing pipeline: {e}")
        # Return an error Verbatim object
        return Verbatim(
            id=verbatim.id,
            content=verbatim.content,
            year=verbatim.year,
            status="ERROR",
            result=None,
        )


def callback(ch, method, properties, body):
    try:
        message = json.loads(body)
        print(isinstance(message, dict))
        logger.info(f"Received message: {message}")

        verbatim = Verbatim.from_json(json.loads(message))
        processed_verbatim = process_verbatim_pipeline(verbatim)

        publish_message(WORKER_RESPONSES_QUEUE, processed_verbatim.to_json())
        logger.info(
            f"Processed and published result for verbatim ID: {processed_verbatim.id}"
        )

        ch.basic_ack(delivery_tag=method.delivery_tag)

    except Exception as e:
        logger.error(f"Error processing message: {e}")
        ch.basic_nack(delivery_tag=method.delivery_tag, requeue=False)


def publish_message(queue, message):
    connection = connect_to_rabbitmq()
    channel = connection.channel()
    channel.queue_declare(queue=queue, durable=True)
    channel.basic_publish(exchange="", routing_key=queue, body=message)
    connection.close()


def main():
    connection = connect_to_rabbitmq()
    channel = connection.channel()

    channel.queue_declare(queue=WORKER_REQUESTS_QUEUE, durable=True)
    channel.basic_consume(queue=WORKER_REQUESTS_QUEUE, on_message_callback=callback)

    logger.info(f"Listening for messages on {WORKER_REQUESTS_QUEUE}...")
    try:
        channel.start_consuming()
    except KeyboardInterrupt:
        logger.info("Worker shutting down...")
        channel.stop_consuming()
        connection.close()


if __name__ == "__main__":
    main()
