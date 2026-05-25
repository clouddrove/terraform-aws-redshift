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

  override_special    = "!#$%&*()-_=+[]{}<>:?"
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonRedshiftAllCommandsFullAccess"]

  cluster_config = {
    database_name                       = "redshiftdb"
    master_username                     = "admin"
    master_password                     = "" # Leave this empty to trigger random password generation
    node_type                           = "ra3.large"
    cluster_type                        = "single-node"
    parameter_group_family              = "redshift-2.0"
    number_of_nodes                     = 1
    automated_snapshot_retention_period = 1
    availability_zone                   = "${local.region}a"
    subnet_ids                          = module.subnets.private_subnet_id
    vpc_id                              = module.vpc.vpc_id
  }
}

