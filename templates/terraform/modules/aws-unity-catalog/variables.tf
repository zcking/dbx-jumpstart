variable "tags" {
  default     = {}
  type        = map(string)
  description = "(Optional) List of tags to be propagated across all assets in this demo"
}

variable "name" {
  type        = string
  description = "(Required) Base name for resources created by this module"
}

variable "region" {
  type        = string
  description = "(Required) AWS region where the assets will be deployed"
}

variable "aws_account_id" {
  type        = string
  description = "(Required) AWS account ID where the cross-account role for Unity Catalog will be created"
}

variable "databricks_account_id" {
  type        = string
  description = "(Required) Databricks Account ID"
}

variable "databricks_workspace_ids" {
  description = <<EOT
  List of Databricks workspace IDs to be enabled with Unity Catalog.
  Enter with square brackets and double quotes
  e.g. ["111111111", "222222222"]
  EOT
  type        = list(string)
  default     = []
}

variable "unity_metastore_owner" {
  description = "(Required) Name of the principal that will be the owner of the Metastore"
  type        = string
}

locals {
  metastore_name = "main"
}