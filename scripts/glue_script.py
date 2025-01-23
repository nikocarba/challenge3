import requests
import boto3
import os
import sys
import json
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.context import SparkContext
from pyspark.sql.functions import regexp_replace, expr, lpad, to_date
from awsglue.dynamicframe import DynamicFrame
from pyspark.sql.types import StructType, StructField, StringType, DoubleType, IntegerType

import logging
import pandas as pd


## @params: [JOB_NAME]
args = getResolvedOptions(sys.argv, ['JOB_NAME', 'TABLE_NAME', 'RAW_BUCKET', 'ARTIFACTS_BUCKET'])
table_name = args['TABLE_NAME']
raw_bucket = args['RAW_BUCKET']
artifacts_bucket = args['ARTIFACTS_BUCKET']

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

logging.basicConfig()
logger = logging.getLogger(__name__)
logger.setLevel(getattr(logging, os.getenv('LOG_LEVEL', 'INFO')))
logger.info('Start execution')

# Function to fetch data from the API
def fetch_data():
    url = f"https://api.sampleapis.com/fakebank/accounts"
    try:
        response = requests.get(url)
        response.raise_for_status()
        logging.info(f"Data fetched.")
        print(len(response.json()))
        return response.json()
    except requests.exceptions.RequestException as e:
        logging.error(f"Failed to fetch data: {e}")
        return None

def load_data_to_dataframe(data):    
    # Parallelize data and normalize in Spark
    rdd = spark.sparkContext.parallelize(data)
    normalized_rdd = rdd.map(
        lambda item: {
            **item,
            "debit": float(item["debit"]) if item["debit"] is not None else None,
            "credit": float(item["credit"]) if item["credit"] is not None else None
        }
    )
    
    # Create DataFrame with schema inference
    df = spark.createDataFrame(normalized_rdd)
    print("####HEAD####")
    print(df.show(5))
    return df

def get_json_parameters(etl_name, s3_artifacts_bucket):
    """
    Gets the job configurations for the ETL from a json file in s3
    """
    s3 = boto3.client('s3')
    file_path = f'etl-configs/{etl_name}.json'

    s3_object = s3.get_object(Bucket=s3_artifacts_bucket, Key=file_path)
    json_data = s3_object['Body'].read().decode('utf-8')
    job_params = json.loads(json_data)
    return job_params

def write_to_S3(data, bucket_stg, folders_path, table_name, target_glue_db):
    path = f's3://{bucket_stg}/{folders_path}/{table_name}'

    df = DynamicFrame.fromDF(data, glueContext, table_name)
    sink = glueContext.getSink(
            connection_type="s3", 
            path=path,
            enableUpdateCatalog=True, 
            updateBehavior="UPDATE_IN_DATABASE"
    )
    sink.setFormat("glueparquet")
    sink.setCatalogInfo(catalogDatabase=target_glue_db, catalogTableName=table_name)
    sink.writeFrame(df)

def rename_col(df, mapping):
    for col in mapping:
        df = df.withColumnRenamed(col, mapping[col])
    return df
    
def standardize_col_name(df):
    for col in df.schema.names:
        df = df.withColumnRenamed(col, col.upper().replace(" ", "_"))
    return df

def normalize_dates(df, col_names):
    for col in col_names:
        df = df.withColumn(col, to_date(df[col],"yyyy-MM-dd"))
    return df

def remove_from_col(col_name, str_to_remove):
    return df.withColumn(col_name, regexp_replace(col_name, str_to_remove, ""))

configs = get_json_parameters(table_name, artifacts_bucket)

df = load_data_to_dataframe(fetch_data())

# Transformations
df = normalize_dates(df, ['transactiondate'])
df = rename_col(df, configs['rename_cols'])

# Write data to S3
write_to_S3(df, raw_bucket, 'api_response', table_name, 'default')

job.commit()