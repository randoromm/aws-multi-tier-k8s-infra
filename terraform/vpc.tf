# VPC and Networking
module "vpc" {
  source          = "terraform-aws-modules/vpc/aws"
  version         = "5.16.0" # Updated version
  name            = "devops-vpc"
  cidr            = "10.0.0.0/16"
  azs             = var.availability_zones
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  #enable_nat_gateway = true
}