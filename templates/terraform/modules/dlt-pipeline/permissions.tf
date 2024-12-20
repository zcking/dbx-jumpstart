/*
 * File: permissions.tf
 * -----
 */

resource "databricks_permissions" "dlt" {
  pipeline_id = databricks_pipeline.this.id

  dynamic "access_control" {
    for_each = var.read_access_groups
    content {
      group_name       = access_control.value
      permission_level = "CAN_VIEW"
    }
  }

  dynamic "access_control" {
    for_each = var.manage_access_groups
    content {
      group_name       = access_control.value
      permission_level = "CAN_MANAGE"
    }
  }

  # ACLs are most often managed manually/adhoc so this Terraform
  # is used to create the initial permissions, but ignores future changes.
  lifecycle {
    ignore_changes = [access_control]
  }
}

resource "databricks_permissions" "repo" {
  count   = var.git_url == null ? 0 : 1
  repo_id = databricks_repo.this[0].id

  dynamic "access_control" {
    for_each = var.read_access_groups
    content {
      group_name       = access_control.value
      permission_level = "CAN_READ"
    }
  }

  dynamic "access_control" {
    for_each = var.manage_access_groups
    content {
      group_name       = access_control.value
      permission_level = "CAN_MANAGE"
    }
  }

  # ACLs are most often managed manually/adhoc so this Terraform
  # is used to create the initial permissions, but ignores future changes.
  lifecycle {
    ignore_changes = [access_control]
  }
}
