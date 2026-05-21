from pyspark.sql import DataFrame
from pyspark.sql.types import StructType
from pyspark.sql.functions import col

def flatten_structs(df: DataFrame) -> DataFrame:
    """
    Recursively flattens all nested StructType complex columns in a Spark DataFrame.
    Unpacks unstructured or multi-nested source payloads down into a flat schema.
    """
    opened_struct = True
    while opened_struct:
        opened_struct = False
        current_schema = df.schema
        new_fields = []
        
        for field in current_schema.fields:
            if isinstance(field.dataType, StructType):
                opened_struct = True
                for sub_field in field.dataType.fields:
                    new_fields.append(
                        col(f"{field.name}.{sub_field.name}").alias(f"{field.name}_{sub_field.name}")
                    )
            else:
                new_fields.append(col(field.name))
        
        if opened_struct:
            df = df.select(new_fields)
            
    return df