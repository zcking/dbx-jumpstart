# Create the prerequisite resources for Unity Catalog,
# and bind it to the Databricks workspaces.
module "unity-catalog" {
  source = "./modules/aws-unity-catalog"
  providers = {
    databricks = databricks.mws
  }
  aws_account_id           = local.aws_account_id
  name                     = local.name
  region                   = local.region
  databricks_account_id    = local.account_id
  databricks_workspace_ids = [for workspace in module.workspaces : workspace.workspace_id]
  unity_metastore_owner    = databricks_group.metastore-admins.display_name
  tags = {
    "Component" = "Databricks"
    "ManagedBy" = "Terraform"
  }
  depends_on = [
    databricks_group_member.self_metastore_admin
  ]
}

# Create the core catalogs in Unity Catalog.
# These are the foundation for separating data and 
# creating boundaries by environment and/or business unit purpose.
{%- for catalog in catalogs %}
resource "databricks_catalog" "{{ catalog }}" {
  provider     = databricks.{{ workspaces | first }}
  metastore_id = module.unity-catalog.metastore_id
  name         = "{{ catalog }}"
  comment      = "{{ catalog }} catalog is managed by Terraform"
  # owner = databricks_group.metastore-admins.display_name
  depends_on = [
    databricks_group_member.self_metastore_admin,
    module.unity-catalog.databricks_metastore_assignment
  ]
}

# Grant the metastore-admins ALL PRIVILEGES on the {{ catalog }} catalog.
resource "databricks_grant" "{{ catalog }}-admins" {
  provider   = databricks.{{ workspaces | first }}
  catalog    = databricks_catalog.{{ catalog }}.name
  principal  = databricks_group.metastore-admins.display_name
  privileges = ["ALL_PRIVILEGES"]
}
{% endfor %}