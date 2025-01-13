output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "default_security_group_id" {
  value = module.vpc.default_security_group_id
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_id
}

output "eks_cluster_endpoint" {
  description = "Endpoint for the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "eks_node_role_arn" {
  description = "IAM Role for EKS worker nodes"
  value       = aws_iam_role.eks_node_role.arn
}

output "rds_endpoint" {
  value = module.rds.db_instance_endpoint
}

output "alb_dns_name" {
  value = module.alb.dns_name
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider"
  value       = module.eks.oidc_provider_arn
}

output "oidc_provider_url" {
  description = "URL of the OIDC provider"
  value       = module.eks.cluster_oidc_issuer_url
}

output "alb_controller_iam_policy_arn" {
  description = "IAM Policy ARN for the ALB Controller"
  value       = aws_iam_policy.alb_controller_policy.arn
}

output "alb_controller_iam_role_arn" {
  description = "IAM Role ARN for the ALB Controller"
  value       = aws_iam_role.alb_controller_role.arn
}