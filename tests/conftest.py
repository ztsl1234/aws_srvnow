import pytest
from pyspark.sql import SparkSession

@pytest.fixture(scope="session")
def spark_session():
    """
    Spins up a lightweight, isolated local mode Spark Engine instance 
    to facilitate code unit validation testing deterministically.
    """
    spark = SparkSession.builder \
        .master("local[2]") \
        .appName("data-platform-unit-testing") \
        .config("spark.sql.shuffle.partitions", "1") \
        .getOrCreate()
    yield spark
    spark.stop()