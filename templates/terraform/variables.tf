locals {
  name            = "{{ name }}"
  account_id      = "{{ account_id }}"
  aws_account_id  = "{{ aws_account_id }}"
  region          = "{{ region}}"
  workspaces      = {{ workspaces | tojson }}
  cidr_blocks     = [for i in range(4, 4 + length(local.workspaces)) : "10.${i}.0.0/16"]
  workspace_cidrs = zipmap(local.workspaces, local.cidr_blocks)
}

