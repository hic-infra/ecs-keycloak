data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  name                 = "${var.name}-vpc"
  cidr                 = "10.199.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.199.1.0/24", "10.199.2.0/24", "10.199.3.0/24"]
  public_subnets       = ["10.199.4.0/24", "10.199.5.0/24", "10.199.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
}
