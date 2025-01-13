resource "aws_iam_role" "alb_controller_role" {
  name = "alb-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })
}

# Load the policy from the JSON file
resource "aws_iam_policy" "alb_controller_policy" {
  name        = "alb-controller-policy"
  description = "IAM policy for AWS Load Balancer Controller"
  policy      = file("iam_policy.json")
}

# Attach the policy to the EKS node role
resource "aws_iam_role_policy_attachment" "alb_controller_policy_attachment" {
  role       = aws_iam_role.alb_controller_role.name
  policy_arn = aws_iam_policy.alb_controller_policy.arn
}