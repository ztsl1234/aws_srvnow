import sys
import os
import typing

# 1. Dynamically append your shared-libs folder to Python's structural search path
current_dir = os.path.dirname(os.path.abspath(__file__))  # Points to tests/
project_root = os.path.dirname(current_dir)               # Points to aws_srvnow/
shared_libs_path = os.path.join(project_root, "shared-libs")

if shared_libs_path not in sys.path:
    sys.path.insert(0, shared_libs_path)

# 2. Polyfill to fix PySpark compatibility on modern Python runtimes
sys.modules['typing.io'] = typing

# 3. Tell Spark's Java workers to use this exact venv Python executable
os.environ["PYSPARK_PYTHON"] = sys.executable
os.environ["PYSPARK_DRIVER_PYTHON"] = sys.executable

# 4. Establish hard root-level directories for the Windows subsystem
os.environ["HADOOP_HOME"] = "C:\\hadoop"
os.environ["PATH"] = "C:\\hadoop\\bin;" + os.environ["PATH"]

os.environ["TMPDIR"] = "C:\\hadoop\\tmp"
os.environ["TEMP"] = "C:\\hadoop\\tmp"
os.environ["TMP"] = "C:\\hadoop\\tmp"

os.makedirs("C:\\hadoop\\tmp", exist_ok=True)

import pytest
from pyspark.sql import SparkSession

@pytest.fixture(scope="session")
def spark_session():
    """
    Spins up an isolated local-mode Spark Engine instance.
    """
    spark = SparkSession.builder \
        .master("local[1]") \
        .appName("data-platform-unit-testing") \
        .config("spark.driver.host", "127.0.0.1") \
        .config("spark.driver.bindAddress", "127.0.0.1") \
        .config("spark.sql.shuffle.partitions", "1") \
        .config("spark.ui.enabled", "false") \
        .config("spark.sql.warehouse.dir", "C:\\hadoop\\tmp\\warehouse") \
        .config("spark.local.dir", "C:\\hadoop\\tmp\\spark-local") \
        .getOrCreate()
    yield spark
    spark.stop()