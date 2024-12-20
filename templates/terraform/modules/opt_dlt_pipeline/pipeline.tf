locals {
  tags = merge(var.tags, {
    "Component" = "DLT"
    "ManagedBy" = "Terraform"
  })
  tbl_properties_tags = tomap({ for k, v in local.tags : "tags.${k}" => v })
}

data "databricks_current_user" "me" {}

resource "databricks_notebook" "dlt_autoloader" {
  source   = "${path.module}/../../../notebooks/dlt_pipeline/pipeline.py"
  path     = "/Shared/samples/dlt_pipeline.py"
  language = "PYTHON"
}

module "dlt_pipeline" {
  source         = "../dlt-pipeline"
  name           = "example-dlt-autoloader"
  git_url        = null # If you want to use Repos, set this to the URL of the repo
  git_branch     = null # If you want to use Repos, set this to the branch of the repo
  notebook_path  = databricks_notebook.dlt_autoloader.id
  catalog        = "examples"
  schema         = "dlt_autoloader"
  photon_enabled = false
  development    = var.development
  min_workers    = var.min_workers
  max_workers    = var.max_workers
#   notifications = [
#     {
#       alerts           = ["on-update-failure", "on-update-fatal-failure", "on-flow-failure"]
#       email_recipients = [data.databricks_current_user.me.user_name]
#     }
#   ]

  # Parameters can be read from the pipeline with `spark.conf.get(...)`
  parameters = {
    "cloud_files.format" : var.cloud_files_format,
    "cloud_files.path" : var.cloud_files_path,
    "bronze.table_properties" : jsonencode(local.tbl_properties_tags),
    "silver.table_properties" : jsonencode(local.tbl_properties_tags),
    "gold.table_properties" : jsonencode(local.tbl_properties_tags)
  }

  tags = local.tags
}

/** Outputs **/

output "pipeline_id" {
  value = module.dlt_pipeline.pipeline_id
}