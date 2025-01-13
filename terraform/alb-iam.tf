data "aws_iam_policy_document" "alb_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.eks_oidc_provider.arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:alb-controller-service-account"]
    }
  }
}

resource "aws_iam_role" "alb_controller_role" {
  name               = "alb-controller-role"
  assume_role_policy = data.aws_iam_policy_document.alb_assume_role_policy.json
}

# Load the ALB Controller IAM policy from JSON
resource "aws_iam_policy" "alb_controller_policy" {
  name        = "alb-controller-policy"
  description = "IAM policy for AWS Load Balancer Controller"
  policy      = file("iam_policy.json")
}

# Attach the ALB Controller policy to the ALB Controller role
resource "aws_iam_role_policy_attachment" "alb_controller_policy_attachment" {
  role       = aws_iam_role.alb_controller_role.name
  policy_arn = aws_iam_policy.alb_controller_policy.arn
}