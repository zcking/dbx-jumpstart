locals {
  metastore_bucket_name_prefix = "${var.name}-${var.region}-metastore"
}

# This will be the main S3 bucket used for our Metastore in Unity Catalog.
# Whenever MANAGED tables are created, they will be stored in this bucket.
#trivy:ignore:avd-aws-0089
resource "aws_s3_bucket" "metastore" {
  bucket_prefix = local.metastore_bucket_name_prefix
  force_destroy = true
  tags = merge(var.tags, {
    Name = local.metastore_bucket_name_prefix
  })
}

# Encrypt the bucket with AES256 SSE
# using a Customer Managed KMS Key
resource "aws_kms_key" "metastore" {
  enable_key_rotation = true
  description         = "Customer managed key for Databricks bucket ${var.name}-metastore"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "metastore" {
  bucket = aws_s3_bucket.metastore.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.metastore.key_id
    }
  }
}

# Disable s3 object versioning as it does not work well with Delta Lake
#trivy:ignore:avd-aws-0090
resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.metastore.id
  versioning_configuration {
    status = "Disabled"
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "metastore" {
  bucket                  = aws_s3_bucket.metastore.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on              = [aws_s3_bucket.metastore]
}