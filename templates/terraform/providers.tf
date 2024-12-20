terraform {
  required_version = ">= 1.7.0"

  backend "s3" {
    bucket  = "terraform-states-{{ aws_account_id }}-{{ region }}"
    region  = "{{ region }}"
    key     = "tfstates/databricks-jumpstart/{{ name }}.tfstate"
    profile = "lakehouse"
  }

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

provider "time" {}

# TODO: handle the possibility of multiple AWS accounts
provider "aws" {
  profile = "{{ name }}"
  region  = "{{ region }}"
  default_tags {
    tags = {
      "Component" = "Databricks"
      "ManagedBy" = "Terraform"
    }
  }
}

# Configure the account-level provider for Databricks
# which is used for account-level APIs such as creating
# workspaces and account users/groups.
provider "databricks" {
  alias      = "mws"
  host       = "https://accounts.cloud.databricks.com"
  account_id = "{{ account_id }}"
  profile    = "{{ name }}"
}

# Configure workspace-level providers for each
# Databricks workspace that will be created.
# This is used for workspace-level APIs such as 
# jobs, clusters, cluster policies, etc.
{%- for workspace in workspaces %}
provider "databricks" {
  alias = "{{ workspace }}"
  host  = module.workspaces["{{ workspace }}"].databricks_host
  token = module.workspaces["{{ workspace }}"].databricks_token
}
{% endfor %}