terraform {
  required_version = ">= 1.7.0"
  required_providers {
    # Workspace level provider
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.5"
    }
  }
}
