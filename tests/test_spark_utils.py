import pytest
from pyspark.sql.types import StructType, StructField, StringType
from utils.spark_utils import flatten_structs

def test_flatten_structs_unpacks_nested_data(spark_session):
    # Setup structural multi-nested input payload framework
    nested_schema = StructType([
        StructField("sys_id", StringType(), True),
        StructField("payload_metadata", StructType([
            StructField("display_value", StringType(), True),
            StructField("operational_status", StringType(), True)
        ]), True)
    ])
    
    test_record = [("INC0001234", ("ServiceNow-Incident", "Active"))]
    input_df = spark_session.createDataFrame(test_record, schema=nested_schema)
    
    # Run the transformation algorithm
    transformed_df = flatten_structs(input_df)
    
    # Confirm flat key mapping schema outputs
    assert "payload_metadata_display_value" in transformed_df.columns
    assert "payload_metadata_operational_status" in transformed_df.columns
    assert "payload_metadata" not in transformed_df.columns
    
    assert transformed_df.count() == 1
    extracted_record = transformed_df.collect()[0]
    assert extracted_record["payload_metadata_display_value"] == "ServiceNow-Incident"
    assert extracted_record["payload_metadata_operational_status"] == "Active"