import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

from utils.spark_utils import flatten_structs
from utils.config_utils import load_s3_json_config

args = getResolvedOptions(sys.argv, ['JOB_NAME', 'ENV'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

config_path = f"s3://sn-meta-data-sl-{args['ENV']}/configs/{args['ENV']}_config.json"
job_config = load_s3_json_config(config_path)

source_path = job_config["source_s3_path"]
target_path = job_config["target_s3_path"]
partition_col = job_config.get("partition_column", "sys_created_on_date")

raw_df = spark.read.format("json").load(source_path)

if raw_df.rdd.isEmpty():
    print("Ingestion Target Landing Zone clean. No records detected.")
    job.commit()
    sys.exit(0)

flattened_df = flatten_structs(raw_df)

flattened_df.write \
    .mode("append") \
    .partitionBy(partition_col) \
    .format("parquet") \
    .save(target_path)

job.commit()