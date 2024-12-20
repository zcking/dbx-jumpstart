data "aws_availability_zones" "available" {}
#trivy:ignore:avd-aws-0057
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.1"

  name       = "databricks-${var.name}"
  cidr       = var.cidr_block
  azs        = data.aws_availability_zones.available.names
  create_vpc = true
  tags       = var.tags

  enable_dns_hostnames = true
  enable_nat_gateway   = true
  single_nat_gateway   = true
  create_igw           = true

  # VPC Flow logs sent to Cloudwatch
  enable_flow_log                                 = true
  flow_log_cloudwatch_log_group_retention_in_days = 3
  create_flow_log_cloudwatch_log_group            = true
  create_flow_log_cloudwatch_iam_role             = true

  public_subnets = [
    cidrsubnet(var.cidr_block, 3, 0)
  ]
  private_subnets = [
    cidrsubnet(var.cidr_block, 3, 1),
    cidrsubnet(var.cidr_block, 3, 2)
  ]

  manage_default_security_group = true
  default_security_group_name   = "${var.name}-sg"

  default_security_group_egress = [{
    cidr_blocks = "0.0.0.0/0"
  }]

  default_security_group_ingress = [{
    description = "Allow all internal TCP and UDP"
    self        = true
  }]
}