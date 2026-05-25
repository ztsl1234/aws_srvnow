import sys
import os
import typing

print("--> Initializing environment adjustments...")
# 1. Polyfill to fix PySpark compatibility on modern Python runtimes
sys.modules['typing.io'] = typing

# 2. Establish hard root-level directories to bypass Windows permission bugs
os.environ["HADOOP_HOME"] = "C:\\hadoop"
os.environ["PATH"] = os.environ["PATH"] + ";C:\\hadoop\\bin"
os.environ["TMPDIR"] = "C:\\hadoop\\tmp"
os.environ["TEMP"] = "C:\\hadoop\\tmp"
os.environ["TMP"] = "C:\\hadoop\\tmp"

# Insert this right below your other os.environ lines (around line 13)
os.environ["PYSPARK_PYTHON"] = sys.executable
os.environ["PYSPARK_DRIVER_PYTHON"] = sys.executable

os.makedirs("C:\\hadoop\\tmp", exist_ok=True)

# Dynamically append shared-libs root path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), 'shared-libs')))

print("--> Importing Spark modules...")
from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType
from utils.spark_utils import flatten_structs

def run_verification():
    print("--> Starting local SparkSession builder...")
    # Explicitly disable log4j UI configurations that occasionally hang on Windows terminals
    spark = SparkSession.builder \
        .master("local[1]") \
        .appName("data-platform-local-verification") \
        .config("spark.driver.host", "127.0.0.1") \
        .config("spark.driver.bindAddress", "127.0.0.1") \
        .config("spark.sql.shuffle.partitions", "1") \
        .config("spark.ui.enabled", "false") \
        .config("spark.sql.warehouse.dir", "C:/hadoop/tmp/warehouse") \
        .getOrCreate()
    
    print("--> SparkSession initialized successfully!")
    
    # Setup test schema
    nested_schema = StructType([
        StructField("sys_id", StringType(), True),
        StructField("payload_metadata", StructType([
            StructField("display_value", StringType(), True),
            StructField("operational_status", StringType(), True)
        ]), True)
    ])
    
    test_record = [("INC0001234", ("ServiceNow-Incident", "Active"))]
    input_df = spark.createDataFrame(test_record, schema=nested_schema)
    
    print("--> Running flatten_structs transformation...")
    transformed_df = flatten_structs(input_df)
    
    print("\n================ VERIFICATION RESULT ================")
    print("Transformed DataFrame Columns:", transformed_df.columns)
    transformed_df.show(truncate=False)
    print("=====================================================\n")
    
    spark.stop()
    print("--> SparkSession stopped cleanly. Verification Complete!")

if __name__ == "__main__":
    run_verification()