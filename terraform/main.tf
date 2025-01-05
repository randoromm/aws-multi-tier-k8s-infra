terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = "eu-west-1"
}

# VPC and Networking
module "vpc" {
  source          = "terraform-aws-modules/vpc/aws"
  version         = "5.16.0" # Updated version
  name            = "devops-vpc"
  cidr            = "10.0.0.0/16"
  azs             = ["eu-west-1a", "eu-west-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
}

# EKS cluster
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.31.6" # Use the latest module version
  cluster_name    = "devops-eks"
  cluster_version = "1.27" # Kubernetes version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  tags = {
    Environment = "DevOps-Test"
  }
}

resource "aws_eks_node_group" "default" {
  cluster_name    = "devops-eks" # module.eks.cluster_id
  depends_on      = [module.eks] # Explicit dependency on the cluster
  node_group_name = "default"
  node_role_arn   = aws_iam_role.eks_node_role.arn # aws_iam_role.eks_nodes.arn
  subnet_ids      = module.vpc.private_subnets
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
  instance_types = ["t3.small"]

  tags = {
    Name = "devops-eks-node-group"
  }
}
