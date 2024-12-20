resource "databricks_repo" "this" {
  count        = var.git_url == null ? 0 : 1
  url          = var.git_url
  git_provider = var.git_provider
  path         = "/Repos/pipelines/${var.name}"
  branch       = var.git_branch
  tag          = var.git_tag
}