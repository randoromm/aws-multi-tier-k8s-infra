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
  version         = "5.16.0" # updated version
  name            = "devops-vpc"
  cidr            = "10.0.0.0/16"
  azs             = ["eu-west-1a", "eu-west-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
}

# EKS cluster
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "19.16.0" # Use the latest module version
  cluster_name    = "devops-eks"
  cluster_version = "1.27" # Kubernetes version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  tags = {
    Environment = "DevOps-Test"
  }
}

resource "aws_eks_node_group" "default" {
  cluster_name    = module.eks.cluster_id
  node_group_name = "default"
  node_role_arn   = aws_iam_role.eks_nodes.arn
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

resource "aws_iam_role" "eks_nodes" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_policy" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
