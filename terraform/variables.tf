variable "key_name" {
  description = "Name of the EC2 Key Pair to access EKS worker nodes"
  default     = "my-ec2-keypair" # Replace with your actual key pair name
}

# VPC
variable "region" {
  description = "The AWS region to deploy resources in."
  default     = "eu-west-1"
}

variable "availability_zones" {
  description = "List of availability zones for high availability."
  default     = ["eu-west-1a", "eu-west-1b"]
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets."
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets."
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}