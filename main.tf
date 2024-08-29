module "labels" {
  source  = "clouddrove/labels/aws"
  version = "1.3.0"

  name        = var.name
  repository  = var.repository
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
}

resource "aws_kms_key" "redshift" {
  count               = var.encryption ? 1 : 0
  enable_key_rotation = true

}

# Create Security Group only if not using an existing one and if enabled
resource "aws_security_group" "this" {
  count       = (var.use_existing_security_group || !var.enable) ? 0 : 1
  name        = var.cluster_config.security_group_name
  description = "Security group for Redshift cluster"
  vpc_id      = var.cluster_config.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = var.tags
}

# Create Subnet Group only if not using an existing one and if enabled
resource "aws_redshift_subnet_group" "this" {
  count       = (var.use_existing_subnet_group || !var.enable) ? 0 : 1
  name        = var.cluster_config.subnet_group_name
  description = "Subnet group for Redshift cluster"
  subnet_ids  = var.cluster_config.subnet_ids

  tags = var.tags
}

# Generate a random password if needed
resource "random_password" "master_password" {
  count = var.create_random_password && (var.cluster_config.master_password == "" || var.cluster_config.master_password == null) ? 1 : 0

  length           = var.random_password_length
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Redshift Cluster
resource "aws_redshift_cluster" "this" {
  count                               = var.enable ? 1 : 0
  cluster_identifier                  = var.cluster_config.cluster_identifier
  database_name                       = var.cluster_config.database_name
  master_username                     = var.cluster_config.master_username
  master_password                     = var.create_random_password && (var.cluster_config.master_password == "" || var.cluster_config.master_password == null) ? random_password.master_password[0].result : var.cluster_config.master_password
  node_type                           = var.cluster_config.node_type
  cluster_type                        = var.cluster_config.cluster_type
  number_of_nodes                     = var.cluster_config.number_of_nodes
  skip_final_snapshot                 = var.skip_final_snapshot
  publicly_accessible                 = var.cluster_config.publicly_accessible
  kms_key_id                          = var.encryption ? aws_kms_key.redshift[0].arn : null
  encrypted                           = var.encryption
  automated_snapshot_retention_period = var.cluster_config.automated_snapshot_retention_period
  availability_zone                   = var.cluster_config.availability_zone
  cluster_subnet_group_name           = var.use_existing_subnet_group ? var.existing_subnet_group_name : aws_redshift_subnet_group.this[0].name
  vpc_security_group_ids              = var.use_existing_security_group ? [var.existing_security_group_id] : [aws_security_group.this[0].id]
  tags                                = var.tags
}

# Store the generated password in Secrets Manager after creating the Redshift cluster
resource "aws_secretsmanager_secret" "master_password" {
  name        = "${var.name}-master-password"
  description = "Master password for Redshift cluster"
}

resource "aws_secretsmanager_secret_version" "master_password" {
  secret_id     = aws_secretsmanager_secret.master_password.id
  secret_string = aws_redshift_cluster.this[0].master_password

  depends_on = [aws_redshift_cluster.this] # Ensure the secret is created after the Redshift cluster
}

# Create IAM Role
resource "aws_iam_role" "redshift_role" {
  count = var.create_iam_role ? 1 : 0

  name        = var.iam_role_name
  description = var.iam_role_description

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "redshift.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })

  tags = var.tags
}

# Create IAM Policy
resource "aws_iam_policy" "redshift_policy" {
  count = var.create_iam_role ? 1 : 0

  name        = "${var.iam_role_name}-policy"
  description = "Policy for the Redshift cluster IAM role"
  policy      = var.iam_role_policy
}

# Attach IAM Policy to the IAM Role
resource "aws_iam_role_policy_attachment" "attach_policy" {
  count = var.create_iam_role ? 1 : 0

  policy_arn = aws_iam_policy.redshift_policy[0].arn
  role       = aws_iam_role.redshift_role[0].name
}

# Redshift Cluster IAM Roles
# Redshift Cluster IAM Roles
resource "aws_redshift_cluster_iam_roles" "this" {
  count = var.enable && (length(var.iam_role_arns) > 0 || length(var.existing_iam_role_arns) > 0) ? 1 : 0

  cluster_identifier   = aws_redshift_cluster.this[0].id
  iam_role_arns        = concat(var.iam_role_arns, var.existing_iam_role_arns)
  default_iam_role_arn = var.default_iam_role_arn
}

resource "aws_redshift_parameter_group" "this" {
  count = var.enable && var.create_parameter_group ? 1 : 0

  name        = coalesce(var.parameter_group_name, replace(var.cluster_config.cluster_identifier, ".", "-"))
  description = var.parameter_group_description
  family      = var.parameter_group_family

  dynamic "parameter" {
    for_each = var.parameter_group_parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(var.tags, var.parameter_group_tags)
}

locals {
  subnet_group_name = "example-subnet-group" # Update this value to your actual subnet group name
}

resource "aws_redshift_endpoint_access" "this" {
  count = var.enable && var.create_endpoint_access ? 1 : 0

  cluster_identifier = aws_redshift_cluster.this[0].id

  endpoint_name          = var.endpoint_name
  resource_owner         = var.endpoint_resource_owner
  subnet_group_name      = coalesce(var.endpoint_subnet_group_name, local.subnet_group_name)
  vpc_security_group_ids = var.endpoint_vpc_security_group_ids
}


