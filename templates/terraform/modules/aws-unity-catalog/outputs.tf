output "metastore_id" {
  description = "Unity Catalog Metastore ID"
  value       = resource.databricks_metastore.this.id
}

output "s3_bucket" {
  value       = aws_s3_bucket.metastore.bucket
  description = "S3 bucket where the metastore data is stored"
}