import sys
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from pyspark.context import SparkContext
from awsglue.job import Job
from pyspark.sql.functions import current_date
from spark_utils import load_config, flatten_structs # Shared Utility

# 1. Initialize
args = getResolvedOptions(sys.argv, ['JOB_NAME', 'CONFIG_PATH'])
glueContext = GlueContext(SparkContext.getOrCreate())
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# 2. Extract & Transform
config = load_config(args['CONFIG_PATH'])
raw_df = spark.read.option("header", "True").csv(config['source_path'])
final_df = flatten_structs(raw_df).withColumn("load_date", current_date())

# 3. Load
final_df.write.mode("overwrite").partitionBy("load_date").parquet(config['target_path'])
job.commit()