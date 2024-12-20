# https://docs.databricks.com/en/administration-guide/system-tables/index.html

locals {
  system_schemas = toset([
    "storage",
    "access",
    "billing",
    "compute",
    "marketplace",
    "operational_data",
    "lineage"
  ])
}

resource "databricks_system_schema" "this" {
  for_each = local.system_schemas
  schema = each.value
}