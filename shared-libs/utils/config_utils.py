import json
from pyspark.sql import SparkSession

def load_s3_json_config(s3_path: str) -> dict:
    """
    Collects a target JSON environment configurations file directly out of 
    S3 using the internal SparkContext, returning an operational dictionary.
    """
    spark = SparkSession.builder.getOrCreate()
    sc = spark.sparkContext
    try:
        rdd = sc.textFile(s3_path)
        config_string = "".join(rdd.collect())
        return json.loads(config_string)
    except Exception as e:
        raise RuntimeError(f"Failed to execute configuration extraction from path: {s3_path}. Trace: {str(e)}")