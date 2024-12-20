'''
File: pipeline.py
-----

Main entrypoint for Delta Live Tables (DLT) pipeline
to execute. This pipeline uses AutoLoader to incrementally
ingest data from cloud files such as in S3, ADLS, or GCS.
'''

import json
import dlt
from pyspark.sql import functions as F


# Pipeline Parameters
cloud_files_path = spark.conf.get("cloud_files.path")
cloud_files_format = spark.conf.get("cloud_files.format", "json")
bronze_partition_cols = spark.conf.get("bronze.partition_cols", "").split(",")
bronze_table_props = json.loads(spark.conf.get("bronze.table_properties", "{}"))
silver_partition_cols = spark.conf.get("silver.partition_cols", "").split(",")
silver_table_props = json.loads(spark.conf.get("silver.table_properties", "{}"))
gold_table_props = json.loads(spark.conf.get("gold.table_properties", "{}"))

bronze_table_props.update({"quality": "bronze"})
silver_table_props.update({"quality": "silver"})
gold_table_props.update({"quality": "gold"})


@dlt.table(
    comment="Bronze layer of incrementally ingested data from cloud files",
    partition_cols=bronze_partition_cols,
    table_properties=bronze_table_props
)
def bronze():
    """
    Represents the Bronze table of the pipeline, incrementally
    ingested from the raw cloud files.
    """
    return (
        spark.readStream.format("cloudFiles")
            .option("cloudFiles.format", cloud_files_format)
            .load(cloud_files_path)
    )


@dlt.table(
    comment="Silver layer of cleaned data",
    partition_cols=silver_partition_cols,
    table_properties=silver_table_props
)
def silver():
    """
    Represents the Silver table of the pipeline, containing
    cleaned rows from the Bronze table and having data quality enforcement.
    """
    return (
        dlt.read_stream("bronze")
            .withColumn("processed_time", F.current_timestamp())
            .withColumn("processed_date", F.current_date())
    )


@dlt.view(
    comment="Gold layer of cleaned data with business logic",
    table_properties=gold_table_props
)
def gold():
    """
    Represents the Gold table of the pipeline, containing
    a very high quality dataset with business logic applied.
    """
    return (
        dlt.read("silver")
            .where("processed_date >= NOW() - INTERVAL 30 DAY")
            .groupBy("processed_date")
            .count()
    )