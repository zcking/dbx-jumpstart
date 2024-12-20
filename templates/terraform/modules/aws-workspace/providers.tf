terraform {
  required_version = ">= 1.7.0"
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.5"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.32"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.10"
    }
  }
}
