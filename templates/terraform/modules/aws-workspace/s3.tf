locals {
  root_bucket_name_prefix = "${var.name}-${var.region}-root"
}

# The following S3 bucket will serve as the root storage for the workspace
# such as user notebooks. Note: this is not the same as the 
# main bucket used for your Metastore in Unity Catalog.
#tfsec:ignore:avd-aws-0089
resource "aws_s3_bucket" "root_storage_bucket" {
  bucket_prefix = local.root_bucket_name_prefix
  force_destroy = true
  tags = merge(var.tags, {
    Name = local.root_bucket_name_prefix
  })
}

# Disable s3 object versioning as it does not work well with Delta Lake
#trivy:ignore:avd-aws-0090
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.root_storage_bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}

# Enforce ownership by the bucket owner. This simplifies 
# object ownership / object ACLs for cross-account access patterns.
resource "aws_s3_bucket_ownership_controls" "state" {
  bucket = aws_s3_bucket.root_storage_bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Encrypt the bucket with AES256 SSE
# trivy:ignore:avd-aws-0132
resource "aws_s3_bucket_server_side_encryption_configuration" "root_storage_bucket" {
  bucket = aws_s3_bucket.root_storage_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "root_storage_bucket" {
  bucket                  = aws_s3_bucket.root_storage_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "root_bucket_policy" {
  bucket     = aws_s3_bucket.root_storage_bucket.id
  policy     = data.databricks_aws_bucket_policy.this.json
  depends_on = [aws_s3_bucket_public_access_block.root_storage_bucket]
}

# This bucket policy is required to allow cross-account access
# from the Databricks control plane.
data "databricks_aws_bucket_policy" "this" {
  bucket = aws_s3_bucket.root_storage_bucket.bucket
}