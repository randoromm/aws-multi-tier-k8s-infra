resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for RDS instance"

  # Ideally access would be restricted to 2 SGs. Backend SG and Bastion SG
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    cidr_blocks     = [module.vpc.vpc_cidr_block] # Allow access within the VPC
    security_groups = [aws_security_group.bastion_sg.id]
  }

  # Ideally also egress would be limited to only necessary security groups (backend, bastion, s3 etc..)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.10.0"

  identifier     = "devops-task-db"
  engine         = "postgres"
  engine_version = "14"

  instance_class    = "db.t3.micro"
  allocated_storage = 20

  # IAM Roles could be implemented to enable application access.
  db_name  = "appdb"
  username = var.db_username
  password = var.db_password

  multi_az               = true
  db_subnet_group_name   = module.vpc.database_subnet_group
  subnet_ids             = module.vpc.database_subnets
  vpc_security_group_ids = [module.vpc.default_security_group_id]

  publicly_accessible = false

  family = var.db_family
}