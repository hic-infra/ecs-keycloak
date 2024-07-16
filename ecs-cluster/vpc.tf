data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.9.0"
  count   = var.vpc-id == "" ? 1 : 0

  name                 = "${var.name}-vpc"
  cidr                 = "10.199.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.199.1.0/24", "10.199.2.0/24", "10.199.3.0/24"]
  public_subnets       = ["10.199.4.0/24", "10.199.5.0/24", "10.199.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  manage_default_security_group = false
  manage_default_route_table    = false
  manage_default_network_acl    = false
  map_public_ip_on_launch       = true
}

# Backwards compatibility with existing deployments
# https://developer.hashicorp.com/terraform/language/modules/develop/refactoring#enabling-count-or-for_each-for-a-resource
moved {
  from = module.vpc
  to   = module.vpc[0]
}
