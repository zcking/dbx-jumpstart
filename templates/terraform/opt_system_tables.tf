{% if 'system_tables' in features -%}
module "system-schemas" {
  source = "./modules/system-schemas"
  providers = {
    databricks = databricks.{{ workspaces | first }}
  }
  depends_on = [ 
    module.workspaces["{{ workspaces | first }}"].databricks_mws_workspaces
  ]
}
{% endif %}