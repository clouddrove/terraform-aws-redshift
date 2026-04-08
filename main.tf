module "labels" {
  source  = "clouddrove/labels/aws"
  version = "1.3.0"

  name        = var.name
  repository  = var.repository
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
}

##-------------------------------------------------------------
## KMS KEY FOR ENCRYPTION
##-------------------------------------------------------------
resource "aws_kms_key" "redshift" {
  count                    = var.enable && var.enable_encryption && var.kms_key_arn == "" ? 1 : 0
  description              = "Customer Managed KMS key for ${module.labels.id} Redshift."
  key_usage                = var.key_usage
  deletion_window_in_days  = var.deletion_window_in_days
  is_enabled               = var.enable_encryption
  enable_key_rotation      = var.enable_key_rotation
  customer_master_key_spec = var.customer_master_key_spec
  policy                   = var.kms_resource_policy
  tags                     = module.labels.tags
}

resource "aws_kms_alias" "default" {
  count         = var.enable && var.enable_encryption && var.kms_key_arn == "" ? 1 : 0
  name          = coalesce(var.alias, format("alias/%v", module.labels.id))
  target_key_id = aws_kms_key.redshift[count.index].key_id
}

##-------------------------------------------------------------
## DEFAULT IAM ROLE FOR REDSHIFT CLUSTER
##-------------------------------------------------------------
module "redshift_iam_role" {
  source  = "clouddrove/iam-role/aws"
  version = "1.3.4"

  enabled             = var.enable && var.create_iam_role ? true : false
  name                = format("%s-role", module.labels.id)
  assume_role_policy  = var.assume_role_policy != "" ? var.assume_role_policy : join("", data.aws_iam_policy_document.redshift[*].json)
  policy_enabled      = var.create_iam_role ? true : false
  policy              = var.policy != "" ? var.policy : join("", data.aws_iam_policy_document.permissions[*].json)
  managed_policy_arns = var.managed_policy_arns
}

data "aws_iam_policy_document" "redshift" {
  count = var.enable && var.create_iam_role ? 1 : 0
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
  count = var.enable && var.create_iam_role ? 1 : 0
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

resource "aws_redshift_cluster_iam_roles" "this" {
  count              = var.enable ? 1 : 0
  cluster_identifier = join("", aws_redshift_cluster.this[*].id)

  iam_role_arns = distinct(concat(
    try(var.iam_role_arns, []),
    [var.create_iam_role ? module.redshift_iam_role.arn : var.default_iam_role_arn]
  ))

}

##-------------------------------------------------------------
## DEFAULT SECURITY FOR REDSHIFT CLUSTER
##-------------------------------------------------------------
module "security_group" {
  source  = "clouddrove/security-group/aws"
  version = "2.0.0"

  enable = var.enable && var.create_security_group && var.security_group_ids == [] ? true : false

  name   = format("%s-sg", module.labels.id)
  vpc_id = var.cluster_config.vpc_id

  ## INGRESS Rules
  new_sg_ingress_rules_with_cidr_blocks = [{
    rule_count  = 1
    from_port   = 5439
    protocol    = "tcp"
    to_port     = 5439
    cidr_blocks = var.allowed_ips
    description = "Allow Redshift traffic."
    }
  ]

  ## EGRESS Rules
  new_sg_egress_rules_with_cidr_blocks = [{
    rule_count  = 1
    from_port   = 0
    protocol    = "-1" # all protocols
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic."
  }]
}

##-------------------------------------------------------------
## DEFAULT SUBNET GROUP FOR REDSHIFT CLUSTER
##-------------------------------------------------------------
resource "aws_redshift_subnet_group" "this" {
  count       = var.enable && var.create_subnet_group && var.existing_subnet_group_id == "" ? 1 : 0
  name        = format("%s-subnet-group", module.labels.id)
  description = "Subnet group for ${module.labels.id} Redshift cluster"
  subnet_ids  = var.cluster_config.subnet_ids
  tags        = merge(module.labels.tags, var.tags)
}

##-------------------------------------------------------------
## DEFAULT PARAMETER GROUP FOR REDSHIFT CLUSTER
##-------------------------------------------------------------
resource "aws_redshift_parameter_group" "this" {
  count = var.enable && var.create_parameter_group && var.parameter_group_name == "" ? 1 : 0

  name        = format("%s-parameter-group", module.labels.id)
  description = "Parameter group for ${module.labels.id} Redshift Cluster"
  family      = var.cluster_config.parameter_group_family

  dynamic "parameter" {
    for_each = var.parameter_group_parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(module.labels.tags, var.tags)
}

##-------------------------------------------------------------
## MANAGED PASSWORD FOR REDSHIFT CLUSTER
##-------------------------------------------------------------
resource "random_password" "master_password" {
  count = var.enable && var.create_random_password ? 1 : 0

  length           = var.random_password_length
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  special          = var.override_special != "" ? true : false
  override_special = var.override_special
}

resource "random_id" "secret" {
  count       = var.enable && var.create_secret_manager ? 1 : 0
  byte_length = 5
}

resource "aws_secretsmanager_secret" "master_password" {
  count       = var.enable && var.create_secret_manager ? 1 : 0
  name        = format("%s-master-password-${join("", random_id.secret[*].hex)}", module.labels.id)
  description = "Master password for ${module.labels.id} Redshift cluster"
  tags        = merge(module.labels.tags, var.tags)
}

resource "aws_secretsmanager_secret_version" "master_password" {
  count         = var.enable && var.create_secret_manager ? 1 : 0
  secret_id     = aws_secretsmanager_secret.master_password[count.index].id
  secret_string = join("", aws_redshift_cluster.this[*].master_password)

  depends_on = [aws_redshift_cluster.this] # Ensure the secret is created after the Redshift cluster
}

##-------------------------------------------------------------
## REDSHIFT CLUSTER
##-------------------------------------------------------------
data "aws_region" "current" {}
data "aws_redshift_cluster" "this" {
  count              = var.enable ? 1 : 0
  cluster_identifier = try(join("", aws_redshift_cluster.this[*].id), null)
}

resource "aws_redshift_cluster" "this" {
  count = var.enable ? 1 : 0

  region                              = data.aws_region.current.name
  skip_final_snapshot                 = var.skip_final_snapshot
  encrypted                           = var.enable_encryption
  kms_key_id                          = var.enable_encryption == false ? null : ((var.enable_encryption && var.kms_key_arn == "") ? join("", aws_kms_key.redshift[*].arn) : var.kms_key_arn)
  vpc_security_group_ids              = var.create_security_group ? module.security_group.security_group_id : var.security_group_ids
  cluster_parameter_group_name        = var.create_parameter_group ? join("", aws_redshift_parameter_group.this[*].id) : var.parameter_group_name
  cluster_subnet_group_name           = var.create_subnet_group ? join("", aws_redshift_subnet_group.this[*].name) : var.existing_subnet_group_id
  master_password                     = var.create_random_password ? join("", random_password.master_password[*].result) : var.cluster_config.master_password
  iam_roles                           = distinct(concat(try(var.iam_role_arns, []), [var.create_iam_role ? module.redshift_iam_role.arn : var.default_iam_role_arn]))
  default_iam_role_arn                = var.create_iam_role ? module.redshift_iam_role.arn : var.default_iam_role_arn
  automated_snapshot_retention_period = var.cluster_config.automated_snapshot_retention_period
  availability_zone                   = var.cluster_config.availability_zone
  cluster_type                        = try(var.cluster_config.cluster_type, "single-node")
  node_type                           = var.cluster_config.node_type
  number_of_nodes                     = var.cluster_config.number_of_nodes
  publicly_accessible                 = var.cluster_config.publicly_accessible
  allow_version_upgrade               = try(var.cluster_config.allow_version_upgrade, null)
  cluster_identifier                  = try(var.cluster_config.cluster_identifier, module.labels.id)
  cluster_version                     = try(var.cluster_config.cluster_version, null)
  database_name                       = try(var.cluster_config.database_name, "redshift")
  elastic_ip                          = try(var.cluster_config.elastic_ip, null)
  enhanced_vpc_routing                = try(var.cluster_config.enhanced_vpc_routing, false)
  master_username                     = try(var.cluster_config.master_username, "admin")
  owner_account                       = try(var.cluster_config.owner_account, null)
  port                                = try(var.cluster_config.port, 5439)
  preferred_maintenance_window        = try(var.cluster_config.preferred_maintenance_window, null)
  snapshot_identifier                 = try(var.cluster_config.snapshot_identifier, null)
  tags                                = merge(module.labels.tags, var.tags)
}

##-------------------------------------------------------------
## ENABLE TO MANAGE ENDPOINT ACCESS FOR REDSHIFT CLUSTER
##-------------------------------------------------------------
resource "aws_redshift_endpoint_access" "this" {
  count = var.enable && var.create_endpoint_access ? 1 : 0

  cluster_identifier     = join("", aws_redshift_cluster.this[*].id)
  endpoint_name          = format("%s-endpoint", module.labels.id)
  resource_owner         = var.endpoint_resource_owner
  subnet_group_name      = var.create_subnet_group ? join("", aws_redshift_subnet_group.this[*].id) : var.existing_subnet_group_id
  vpc_security_group_ids = var.create_security_group && var.endpoint_vpc_security_group_ids == [] ? module.security_group.security_group_id : var.endpoint_vpc_security_group_ids
}
