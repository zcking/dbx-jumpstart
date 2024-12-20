# Create the admin users, and a group to manage them. 
# This administrative group will also be the owner of the
# Unity Catalog metastore.

resource "databricks_group" "metastore-admins" {
  provider     = databricks.mws
  display_name = "metastore-admins"
}

resource "databricks_group_role" "metastore-admins" {
  provider = databricks.mws
  group_id = databricks_group.metastore-admins.id
  role     = "account_admin"
}

# Whichever identity (e.g. service principal) this terraform 
# is running as, will need to itself be a metastore admin
data "databricks_current_user" "me" {
  provider = databricks.{{ workspaces | first }}
  depends_on = [
    module.workspaces["{{ workspaces | first }}"].databricks_mws_workspaces
  ]
}

resource "databricks_group_member" "self_metastore_admin" {
  provider  = databricks.mws
  group_id  = databricks_group.metastore-admins.id
  member_id = data.databricks_current_user.me.id
}

# Assign the metastore-admins group ADMIN permission to all workspaces
resource "databricks_mws_permission_assignment" "add_admin_group" {
  provider     = databricks.mws
  for_each     = local.workspace_cidrs
  workspace_id = module.workspaces[each.key].workspace_id
  principal_id = databricks_group.metastore-admins.id
  permissions  = ["ADMIN"]
}
