# Network configuration in the Databricks account.
# This is how Databricks will know which VPC and subnets to use.
resource "databricks_mws_networks" "this" {
  account_id         = var.databricks_account_id
  network_name       = "${var.name}-network"
  security_group_ids = [module.vpc.default_security_group_id]
  subnet_ids         = module.vpc.private_subnets
  vpc_id             = module.vpc.vpc_id
}

# Storage configuration in the Databricks account.
# This is how Databricks will know where to store data for the workspace.
resource "databricks_mws_storage_configurations" "this" {
  account_id                 = var.databricks_account_id
  bucket_name                = aws_s3_bucket.root_storage_bucket.bucket
  storage_configuration_name = "${var.name}-storage"
}

# IAM configuration in the Databricks account.
# This is how Databricks will know how to authenticate with AWS
# and perform actions like creating VMs when launching jobs.
resource "databricks_mws_credentials" "this" {
  role_arn         = aws_iam_role.cross_account_role.arn
  credentials_name = "${var.name}-creds"
  depends_on       = [time_sleep.wait]
}

## Adding 20 second timer to avoid Failed credential validation check
resource "time_sleep" "wait" {
  create_duration = "20s"
  depends_on = [
    aws_iam_role_policy.this
  ]
}

# Finanlly, create the workspace itself, with all the configurations
resource "databricks_mws_workspaces" "this" {
  account_id     = var.databricks_account_id
  aws_region     = var.region
  workspace_name = var.name

  credentials_id           = databricks_mws_credentials.this.credentials_id
  storage_configuration_id = databricks_mws_storage_configurations.this.storage_configuration_id
  network_id               = databricks_mws_networks.this.network_id

  token {
    comment = "Terraform"
  }
}