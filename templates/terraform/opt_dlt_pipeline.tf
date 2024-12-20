module "dlt_pipeline" {
  source = "./modules/dlt_pipeline"
  providers = {
    databricks = databricks.{{ workspaces | first }}
  }
  cloud_files_format = "json"
  cloud_files_path   = "s3://mybucket/myfolder/"
  development        = true
}