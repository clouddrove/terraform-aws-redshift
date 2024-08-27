provider "aws" {
  region = "us-east-1"
}

locals {
  environment = "test-app"
  label_order = ["name", "environment"]
}

module "terraform-aws-redshift" {
  source = "../../"

  enable              = true
  region              = "us-east-1"
  name                = "example-redshift-cluster"
  repository          = "example-repo"
  environment         = local.environment
  managedby           = "terraform"
  label_order         = local.label_order
  skip_final_snapshot = true
  encryption          = true
  tags = {
    Environment = local.environment
    ManagedBy   = "terraform"
  }

  use_existing_security_group = false
  existing_security_group_id  = ""

  use_existing_subnet_group  = false
  existing_subnet_group_name = ""

  ingress_rules = [
    {
      from_port   = 5439
      to_port     = 5439
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  cluster_config = {
    cluster_identifier                  = "example-cluster"
    database_name                       = "exampledb"
    master_username                     = "admin"
    master_password                     = "" # Leave this empty to trigger random password generation
    node_type                           = "dc2.large"
    cluster_type                        = "multi-node"
    number_of_nodes                     = 2
    publicly_accessible                 = true
    automated_snapshot_retention_period = 0
    availability_zone                   = "us-east-1a"
    subnet_group_name                   = "example-subnet-group"
    subnet_ids                          = tolist(module.public_subnets.public_subnet_id)
    vpc_id                              = module.vpc.vpc_id
    security_group_name                 = "example-sg"
  }

  create_random_password = true # Set to true to enable random password generation
  random_password_length = 16

  # Parameter Group Settings
  create_parameter_group      = true
  parameter_group_name        = "example-parameter-group"
  parameter_group_description = "Parameter group for Redshift"
  parameter_group_family      = "redshift-1.0"
  parameter_group_parameters = [
    {
      name  = "enable_user_activity_logging"
      value = "true"
    }
  ]
  parameter_group_tags = {
    Environment = local.environment
    ManagedBy   = "terraform"
  }

  create_iam_role      = true
  iam_role_name        = "example-redshift-role"
  iam_role_description = "IAM role for Redshift"
  iam_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "s3:*"
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })

  # Add existing roles if necessary
  iam_role_arns        = [] # Use existing roles if needed, e.g., ["arn:aws:iam::123456789012:role/ExistingRole"]
  default_iam_role_arn = "" # Use the default IAM role ARN if applicable

  # Endpoint Access Configuration
  create_endpoint_access          = false
  endpoint_name                   = "example-endpoint"
  endpoint_resource_owner         = "924144197303" # Replace with the actual AWS account ID
  endpoint_subnet_group_name      = ""
  endpoint_vpc_security_group_ids = ["sg-xxxxxxxxxxxx"]
}


module "vpc" {
  source      = "clouddrove/vpc/aws"
  version     = "2.0.0"
  name        = "vpc"
  environment = local.environment
  label_order = local.label_order
  cidr_block  = "172.16.0.0/16"
}

module "public_subnets" {
  source             = "clouddrove/subnet/aws"
  version            = "2.0.1"
  name               = "public-subnet"
  environment        = local.environment
  label_order        = local.label_order
  availability_zones = ["us-east-1a", "us-east-1b"]
  vpc_id             = module.vpc.vpc_id
  cidr_block         = module.vpc.vpc_cidr_block
  type               = "public"
  igw_id             = module.vpc.igw_id
  ipv6_cidr_block    = module.vpc.ipv6_cidr_block
}
