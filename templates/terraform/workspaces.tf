{% if cloud == 'AWS' %}
module "workspaces" {
  for_each = local.workspace_cidrs
  source   = "./modules/aws-workspace"
  providers = {
    databricks = databricks.mws
  }
  name                  = each.key
  databricks_account_id = local.account_id
  cidr_block            = each.value
  region                = local.region
  tags = {
    "Environment" = each.key
    "Component"   = "Databricks"
    "ManagedBy"   = "Terraform"
  }
}
{% else %}
# Sorry, the {{ cloud }} cloud is not yet supported.
{% endif %}

