provider "aws" {
  region = local.region
}

locals {
  name        = "redshift"
  environment = "test"
  label_order = ["environment", "name"]
  region      = "us-east-1"
}

##--------------------------------------------------------
## VPC MODULE CALL
##--------------------------------------------------------
module "vpc" {
  source  = "clouddrove/vpc/aws"
  version = "2.0.5"

  name        = "${local.name}-vpc"
  environment = local.environment
  label_order = local.label_order

  cidr_block = "10.10.0.0/16"
}

##--------------------------------------------------------
## SUBNET MODULE CALL
##--------------------------------------------------------

module "subnets" {
  source  = "clouddrove/subnet/aws"
  version = "2.0.2"

  name        = "${local.name}-subnet"
  environment = local.environment
  label_order = local.label_order

  nat_gateway_enabled = true
  single_nat_gateway  = true
  availability_zones  = ["${local.region}a", "${local.region}b", "${local.region}c"]
  vpc_id              = module.vpc.vpc_id
  type                = "public-private"
  igw_id              = module.vpc.igw_id
  cidr_block          = "10.10.0.0/16"

  public_inbound_acl_rules = [
    {
      rule_number = 1
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number     = 101
      rule_action     = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      ipv6_cidr_block = "::/0"
    }
  ]

  public_outbound_acl_rules = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number     = 101
      rule_action     = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      ipv6_cidr_block = "::/0"
    },
  ]

  private_inbound_acl_rules = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number     = 101
      rule_action     = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      ipv6_cidr_block = "::/0"
    },
  ]

  private_outbound_acl_rules = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number     = 101
      rule_action     = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      ipv6_cidr_block = "::/0"
    },
  ]
}

##--------------------------------------------------------
## REDSHIFT MODULE CALL
##--------------------------------------------------------
module "redshift" {
  source = "../../"

  enable      = true
  name        = local.name
  environment = local.environment
  label_order = local.label_order

  override_special = true
  cluster_config = {
    database_name                       = "redshiftdb"
    master_username                     = "admin"
    master_password                     = "" # -- Leave this empty to trigger random password generation
    cluster_type                        = "single-node"
    node_type                           = "ra3.large"
    parameter_group_family              = "redshift-2.0"
    number_of_nodes                     = 1
    automated_snapshot_retention_period = 1
    availability_zone                   = "${local.region}a"
    subnet_ids                          = module.subnets.private_subnet_id
    vpc_id                              = module.vpc.vpc_id
    publicly_accessible                 = false
  }
  enable_encryption       = true
  kms_key_arn             = "arn:aws:kms:${local.region}:123456789012:key/a1b2c3d4-a1b2-c1d2-e1f2-a1b2c3d4e5f6" # -- if `kms_key_arn` not provided, a customer managed will be created by module by default.
  enable_key_rotation     = false
  deletion_window_in_days = 7

  create_iam_role      = false                        # -- if set to `true`, a default iam role will be created with permission of ReadOnly Access to CloudwatchLogs, S3, SecretManager, Glue, Lambda
  default_iam_role_arn = module.redshift_iam_role.arn # -- Required only when `create_iam_role = false`
  iam_role_arns        = ["arn:aws:iam::123456789012:role/redshift-s3-admin-access", "arn:aws:iam::123456789012:role/redshift-secrets-admin-access", "arn:aws:iam::123456789012:role/redshift-logs-admin-access"]

  create_security_group = false # -- if set to `true`, a default security-group will be created with InBound(5439) & OutBound(All)
  security_group_ids    = ["sg-xxxxxx1", "sg-xxxxxx2", "sg-xxxxxx3"]

  create_subnet_group      = false # -- if set to `true`, a default redshift subnet group will be created.
  existing_subnet_group_id = "my-redshift-subnet-group"

  create_parameter_group = false # -- if set to `true`, a default redshift parameter group will be created.
  parameter_group_name   = "my-redshift-parameter-group"
  parameter_group_parameters = [ # -- Only applicable if `create_parameter_group = true` and `parameter_group_name` is empty
    {
      name  = "require_ssl"
      value = "true"
    },
    {
      name  = "query_group"
      value = "example"
    },
    {
      name  = "enable_user_activity_logging"
      value = "true"
    }
  ]

  create_endpoint_access          = true
  endpoint_vpc_security_group_ids = ["sg-xxxxx4"] # -- Required if `create_security_group` set to `false`

}

##-------------------------------------------------------------
## DEFAULT IAM ROLE FOR REDSHIFT CLUSTER
##-------------------------------------------------------------
module "redshift_iam_role" {
  source  = "clouddrove/iam-role/aws"
  version = "1.3.4"

  name        = "${local.name}-role"
  environment = local.environment
  label_order = local.label_order

  assume_role_policy  = data.aws_iam_policy_document.redshift.json
  policy_enabled      = false
  policy              = data.aws_iam_policy_document.permissions.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonRedshiftAllCommandsFullAccess"]
}

data "aws_iam_policy_document" "redshift" {
  statement {
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "sagemaker.amazonaws.com",
        "redshift.amazonaws.com",
        "redshift-serverless.amazonaws.com",
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "permissions" {
  statement {
    sid    = "AllowLoggingToCloudWatch"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "S3ReadOnly"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::*",
      "arn:aws:s3:::*/*"
    ]
  }

  statement {
    sid    = "SecretsManagerReadOnly"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecrets"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "GlueReadOnly"
    effect = "Allow"
    actions = [
      "glue:GetDatabase",
      "glue:GetDatabases",
      "glue:GetTable",
      "glue:GetTables",
      "glue:GetPartition",
      "glue:GetPartitions",
      "glue:BatchGetPartition"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "LambdaReadOnly"
    effect = "Allow"
    actions = [
      "lambda:GetFunction",
      "lambda:ListFunctions",
      "lambda:GetFunctionConfiguration",
      "lambda:ListAliases",
      "lambda:ListVersionsByFunction"
    ]
    resources = ["*"]
  }
}

