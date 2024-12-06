output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_id
}

output "eks_cluster_endpoint" {
  description = "Endpoint for the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "eks_node_role" {
  description = "IAM Role for EKS worker nodes"
  value       = aws_iam_role.eks_nodes.name
}