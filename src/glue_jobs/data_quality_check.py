import sys
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from utils.config_utils import load_s3_json_config

args = getResolvedOptions(sys.argv, ['JOB_NAME', 'ENV'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

config_path = f"s3://sn-meta-data-sl-{args['ENV']}/configs/{args['ENV']}_config.json"
job_config = load_s3_json_config(config_path)
target_path = job_config["target_s3_path"]

# Validate target schema ingestion metrics
processed_df = spark.read.format("parquet").load(target_path)
total_records = processed_df.count()

if total_records == 0:
    raise ValueError(f"CRITICAL: Integrity assertion failed. Zero metrics found inside target: {target_path}")

print(f"Data Quality Analysis Successful. Active Record Count: {total_records}")
job.commit()