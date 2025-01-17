# EKS cluster
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 20.31" # Module version
  cluster_name    = "devops-eks"
  cluster_version = "1.31" # Kubernetes version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets
  enable_irsa     = true # Automatically create OIDC provider for ALB

  # Enable both private and public access
  cluster_endpoint_private_access = true # Enables private access to the Kubernetes API server from within the VPC
  cluster_endpoint_public_access  = true # Enables public access to the Kubernetes API server, typically for administrative purposes to use Kubectl from local machine

  # Restrict public access to YOUR IPv4 address
  # NB! Change this value in variables to have kubectl access!
  cluster_endpoint_public_access_cidrs = [var.eks_public_access_ip4]

  enable_cluster_creator_admin_permissions = true # Automatically grants cluster creator admin permissions

  tags = {
    Environment = "DevOps-Test"
  }
}

# Create managed node group
resource "aws_eks_node_group" "default" {
  cluster_name    = "devops-eks" # module.eks.cluster_id # "devops-eks"
  depends_on      = [module.eks] # Explicit dependency on the cluster
  node_group_name = "default"
  node_role_arn   = aws_iam_role.eks_node_role.arn # aws_iam_role.eks_nodes.arn
  subnet_ids      = module.vpc.private_subnets
  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }
  instance_types = ["t3.small"]

  tags = {
    Name = "devops-eks-node-group"
  }
}