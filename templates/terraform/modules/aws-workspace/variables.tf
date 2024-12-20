variable "name" {
  type        = string
  description = "Workspace name"
}

variable "region" {
  type        = string
  description = "Cloud region where resources will be created"
}

variable "cidr_block" {
  type        = string
  description = "Workspace CIDR block"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags for the workspace resources"
  default     = {}
}

variable "databricks_account_id" {
  type        = string
  description = "Databricks account ID"
}