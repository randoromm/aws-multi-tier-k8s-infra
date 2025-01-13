# VPC and Networking
module "vpc" {
  source                       = "terraform-aws-modules/vpc/aws"
  version                      = "5.16.0" # Updated version
  name                         = "devops-vpc"
  cidr                         = "10.0.0.0/16"
  azs                          = var.availability_zones
  public_subnets               = var.public_subnets
  private_subnets              = var.private_subnets
  create_database_subnet_group = true
  database_subnets             = var.database_subnets

  enable_dns_hostnames = true # Many 3party apps (and also VPN) require DNS support, so i like to enable it from the start
  enable_dns_support   = true

  enable_nat_gateway     = true
  single_nat_gateway     = true # For prod consider per avz or per subnet
  one_nat_gateway_per_az = false

  public_subnet_tags = {
    "kubernetes.io/role/elb"           = 1
    "kubernetes.io/cluster/devops-eks" = "owned"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"  = 1
    "kubernetes.io/cluster/devops-eks" = "owned"
  }
}

resource "aws_subnet" "bastion_subnet" {
  vpc_id                  = module.vpc.vpc_id
  cidr_block              = var.bastion_subnet
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zones[0]

  tags = {
    "Name" = "bastion_subnet"
  }
}

resource "aws_route_table_association" "bastion_assoc" {
  subnet_id      = aws_subnet.bastion_subnet.id
  route_table_id = module.vpc.public_route_table_ids[0]
}