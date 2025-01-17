# Connect terraform to EKS cluster
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
}

# Create a service account in kube-system namespace
resource "kubernetes_service_account" "alb_controller_service_account" {
  metadata {
    name      = "alb-controller-service-account"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::222634395930:role/alb-controller-role" # Link the service account to AWS IAM role
    }
  }
}