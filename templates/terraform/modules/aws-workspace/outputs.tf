output "databricks_host" {
  value = databricks_mws_workspaces.this.workspace_url
}

output "databricks_token" {
  value     = databricks_mws_workspaces.this.token[0].token_value
  sensitive = true
}

output "workspace_id" {
  value = databricks_mws_workspaces.this.workspace_id
}

output "s3_bucket" {
  value = aws_s3_bucket.root_storage_bucket.bucket
}

output "vpc_id" {
  value = module.vpc.vpc_id
}