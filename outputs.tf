##-------------------------------------------------------------
## REDSHIFT CLUSTER
##-------------------------------------------------------------
output "id" {
  value       = try(join("", aws_redshift_cluster.this[*].id), null)
  description = "The Redshift Cluster ID."
}

output "arn" {
  value       = try(join("", aws_redshift_cluster.this[*].arn), null)
  description = "Amazon Resource Name (ARN) of cluster"
}

output "cluster_identifier" {
  value       = try(join("", aws_redshift_cluster.this[*].cluster_identifier), null)
  description = "The Cluster Identifier"
}

output "cluster_type" {
  value       = try(join("", aws_redshift_cluster.this[*].cluster_type), null)
  description = "The cluster type"
}

output "node_type" {
  value       = try(join("", aws_redshift_cluster.this[*].node_type), null)
  description = "The type of nodes in the cluster"
}

output "database_name" {
  value       = try(join("", aws_redshift_cluster.this[*].database_name), null)
  description = "The name of the default database in the Cluster"
}

output "availability_zone" {
  value       = try(join("", aws_redshift_cluster.this[*].availability_zone), null)
  description = "The availability zone of the Cluster"
}

output "automated_snapshot_retention_period" {
  value       = try(join("", aws_redshift_cluster.this[*].automated_snapshot_retention_period), null)
  description = "The backup retention period"
}

output "preferred_maintenance_window" {
  value       = try(join("", aws_redshift_cluster.this[*].preferred_maintenance_window), null)
  description = "The backup window"
}

output "endpoint" {
  value       = try(join("", aws_redshift_cluster.this[*].endpoint), null)
  description = "The connection endpoint"
}

output "encrypted" {
  value       = try(join("", aws_redshift_cluster.this[*].encrypted), null)
  description = "Whether the data in the cluster is encrypted"
}

output "vpc_security_group_ids" {
  value       = try(flatten(aws_redshift_cluster.this[*].vpc_security_group_ids), null)
  description = "The VPC security group Ids associated with the cluster"
}

output "dns_name" {
  value       = try(join("", aws_redshift_cluster.this[*].dns_name), null)
  description = "The DNS name of the cluster"
}

output "port" {
  value       = try(join("", aws_redshift_cluster.this[*].port), null)
  description = "The Port the cluster responds on"
}

output "cluster_version" {
  value       = try(join("", aws_redshift_cluster.this[*].cluster_version), null)
  description = "The version of Redshift engine software"
}

output "cluster_public_key" {
  value       = try(join("", aws_redshift_cluster.this[*].cluster_public_key), null)
  description = "The public key for the cluster"
}

output "cluster_revision_number" {
  value       = try(join("", aws_redshift_cluster.this[*].cluster_revision_number), null)
  description = "The specific revision number of the database in the cluster"
}

output "cluster_nodes" {
  value       = try(data.aws_redshift_cluster.this[*].cluster_nodes, null)
  description = "The nodes in the cluster. Cluster node blocks are documented below"
}

output "cluster_namespace_arn" {
  value       = try(join("", data.aws_redshift_cluster.this[*].cluster_namespace_arn), null)
  description = "The namespace Amazon Resource Name (ARN) of the cluster"
}

##-------------------------------------------------------------
## KMS KEY
##-------------------------------------------------------------
output "kms_key_arn" {
  value       = try(join("", aws_kms_key.redshift[*].arn), null)
  description = "KMS Key ARN."
}

output "kms_key_id" {
  value       = try(join("", aws_kms_key.redshift[*].key_id), null)
  description = "KMS Key ID."
}

output "kms_alias_arn" {
  value       = try(join("", aws_kms_alias.default[*].arn), null)
  description = "KMS Alias ARN."
}

output "kms_alias_name" {
  value       = try(join("", aws_kms_alias.default[*].name), null)
  description = "KMS Alias name."
}

##-------------------------------------------------------------
## IAM ROLE
##-------------------------------------------------------------
output "iam_role_arn" {
  value       = try(module.redshift_iam_role.arn, null)
  description = "The Amazon Resource Name (ARN) specifying the role."
}

output "iam_role_name" {
  value       = try(module.redshift_iam_role.name, null)
  description = "Name of specifying the role."
}

##-------------------------------------------------------------
## SECURITY GROUP
##-------------------------------------------------------------
output "security_group_id" {
  value       = try(module.security_group.security_group_id, null)
  description = "IDs on the AWS Security Groups associated with the instance."
}

output "security_group_arn" {
  value       = try(module.security_group.security_group_arn, null)
  description = "IDs on the AWS Security Groups associated with the instance."
}

##-------------------------------------------------------------
## SUBNET GROUP
##-------------------------------------------------------------
output "subnet_group_id" {
  value       = try(join("", aws_redshift_subnet_group.this[*].id), null)
  description = "The Redshift Subnet group ID."
}

output "subnet_group_arn" {
  value       = try(join("", aws_redshift_subnet_group.this[*].arn), null)
  description = "Amazon Resource Name (ARN) of the Redshift Subnet group name"
}

##-------------------------------------------------------------
## PARAMETER GROUP
##-------------------------------------------------------------
output "parameter_group_id" {
  value       = try(join("", aws_redshift_parameter_group.this[*].id), null)
  description = "The Redshift parameter group name."
}

output "parameter_group_arn" {
  value       = try(join("", aws_redshift_parameter_group.this[*].arn), null)
  description = "Amazon Resource Name (ARN) of parameter group"
}

##-------------------------------------------------------------
## SECRETS MANAGER
##-------------------------------------------------------------
output "secret_arn" {
  value       = try(join("", aws_secretsmanager_secret.master_password[*].arn), null)
  description = "ARN of the secret."
}
output "secret_id" {
  value       = try(join("", aws_secretsmanager_secret_version.master_password[*].id), null)
  description = "A pipe delimited combination of secret ID and version ID."
}

##-------------------------------------------------------------
## REDSHIFT ENDPOINT
##-------------------------------------------------------------
output "endpoint_address" {
  value       = try(join("", aws_redshift_endpoint_access.this[*].address), null)
  description = "The DNS address of the endpoint."
}
output "endpoint_id" {
  value       = try(join("", aws_redshift_endpoint_access.this[*].id), null)
  description = "The Redshift-managed VPC endpoint name."
}
output "endpoint_port" {
  value       = try(join("", aws_redshift_endpoint_access.this[*].port), null)
  description = "The port number on which the cluster accepts incoming connections."
}
output "vpc_endpoint" {
  value       = try(join("", aws_redshift_endpoint_access.this[*].vpc_endpoint), null)
  description = "The connection endpoint for connecting to an Amazon Redshift cluster through the proxy. See details below."
}
