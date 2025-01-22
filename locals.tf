locals {  
    project_tags = {
        Environment = "Dev"
        Project     = var.project
        Owner       = "Nicolas Carballal"
    }

    new_arguments = {
        "--TABLE_NAME"          = var.raw_table_name
        "--RAW_BUCKET"          = local.raw_bucket_name
        "--ARTIFACTS_BUCKET"    = local.artifacts_bucket_name
    }

    spark_arguments = merge(var.spark_arguments, local.new_arguments)

    spark_configurations = {
        number_of_workers = 2
        worker_type = "G.1X"
        max_retries = 0
        timeout = 2880
        default_arguments = local.spark_arguments
    }

    glue_job_name = "load-to-s3-${var.project}-${var.owner}"

    script_path = "scripts/${local.glue_job_name}.py"

    raw_bucket_name = "raw-bucket-${var.project}-${var.owner}"

    artifacts_bucket_name = "artifacts-bucket-${var.project}-${var.owner}"
}