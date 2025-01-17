#resource "aws_iam_openid_connect_provider" "eks_oidc_provider" {
#  client_id_list  = ["sts.amazonaws.com"]
#  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da0e6df3d8b"] # AWS default
#  url             = module.eks.cluster_oidc_issuer_url
#  depends_on      = [module.eks]
#}

# As OIDC provider is created by EKS module, we just fetch it with data block
data "aws_iam_openid_connect_provider" "eks_oidc_provider" {
  arn = module.eks.oidc_provider_arn
}

# Used for temp auth token by alb-controller-helm.tf
data "aws_eks_cluster_auth" "cluster" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

# Used for metadata by alb-controller-helm.tf
data "aws_eks_cluster" "cluster" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}
