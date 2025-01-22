resource "aws_s3_bucket" "raw-bucket" {
    bucket = var.raw_bucket_name
    tags = var.s3_bucket_tags
}

resource "aws_s3_bucket" "artifacts-bucket" {
    bucket = var.artifacts_bucket_name
    tags = var.s3_bucket_tags
}

resource "aws_s3_object" "glue-script" {
  bucket = aws_s3_bucket.artifacts-bucket.id
  key    = var.script_path
  source = "./scripts/glue_script.py"

  etag = filemd5("./scripts/glue_script.py")
}

resource "aws_s3_object" "etl-configs" {
  bucket = aws_s3_bucket.artifacts-bucket.id
  key    = "etl-configs/${var.raw_table_name}.json"
  source = "./etl-configs/${var.raw_table_name}.json"

  etag = filemd5("./etl-configs/${var.raw_table_name}.json")
}