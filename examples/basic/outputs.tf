##-------------------------------------------------------------
## REDSHIFT CLUSTER
##-------------------------------------------------------------
output "redshift_cluster_id" {
  value       = module.redshift.id
  description = "The Redshift Cluster ID."
}

output "redshift_cluster_arn" {
  value       = module.redshift.arn
  description = "Amazon Resource Name (ARN) of cluster"
}

output "redshift_cluster_identifier" {
  value       = module.redshift.cluster_identifier
  description = "The Cluster Identifier"
}

output "redshift_cluster_type" {
  value       = module.redshift.cluster_type
  description = "The cluster type"
}

output "redshift_node_type" {
  value       = module.redshift.node_type
  description = "The type of nodes in the cluster"
}

output "redshift_database_name" {
  value       = module.redshift.database_name
  description = "The name of the default database in the Cluster"
}

output "redshift_availability_zone" {
  value       = module.redshift.availability_zone
  description = "The availability zone of the Cluster"
}

output "redshift_snapshot_retention_period" {
  value       = module.redshift.automated_snapshot_retention_period
  description = "The backup retention period"
}

output "redshift_maintenance_window" {
  value       = module.redshift.preferred_maintenance_window
  description = "The backup window"
}

output "redshift_endpoint" {
  value       = module.redshift.endpoint
  description = "The connection endpoint"
}

output "redshift_encrypted" {
  value       = module.redshift.encrypted
  description = "Whether the data in the cluster is encrypted"
}

output "redshift_vpc_security_group_ids" {
  value       = module.redshift.vpc_security_group_ids
  description = "The VPC security group Ids associated with the cluster"
}

output "redshift_dns_name" {
  value       = module.redshift.dns_name
  description = "The DNS name of the cluster"
}

output "redshift_port" {
  value       = module.redshift.port
  description = "The Port the cluster responds on"
}

output "redshift_cluster_version" {
  value       = module.redshift.cluster_version
  description = "The version of Redshift engine software"
}

output "redshift_cluster_public_key" {
  value       = module.redshift.cluster_public_key
  description = "The public key for the cluster"
}

output "redshift_cluster_revision_number" {
  value       = module.redshift.cluster_revision_number
  description = "The specific revision number of the database in the cluster"
}

output "redshift_cluster_nodes" {
  value       = module.redshift.cluster_nodes
  description = "The nodes in the cluster. Cluster node blocks are documented below"
}

output "redshift_cluster_namespace_arn" {
  value       = module.redshift.cluster_namespace_arn
  description = "The namespace Amazon Resource Name (ARN) of the cluster"
}

##-------------------------------------------------------------
## KMS KEY
##-------------------------------------------------------------
output "redshift_kms_key_arn" {
  value       = module.redshift.kms_key_arn
  description = "KMS Key ARN."
}

output "redshift_kms_key_id" {
  value       = module.redshift.kms_key_id
  description = "KMS Key ID."
}

output "redshift_kms_alias_arn" {
  value       = module.redshift.kms_alias_arn
  description = "KMS Alias ARN."
}

output "redshift_kms_alias_name" {
  value       = module.redshift.kms_alias_name
  description = "KMS Alias name."
}

##-------------------------------------------------------------
## IAM ROLE
##-------------------------------------------------------------
output "redshift_iam_role_arn" {
  value       = module.redshift.iam_role_arn
  description = "The Amazon Resource Name (ARN) specifying the role."
}

output "redshift_iam_role_name" {
  value       = module.redshift.iam_role_name
  description = "Name of specifying the role."
}

##-------------------------------------------------------------
## SECURITY GROUP
##-------------------------------------------------------------
output "redshift_security_group_id" {
  value       = module.redshift.security_group_id
  description = "IDs on the AWS Security Groups associated with the instance."
}

output "redshift_security_group_arn" {
  value       = module.redshift.security_group_arn
  description = "IDs on the AWS Security Groups associated with the instance."
}

##-------------------------------------------------------------
## SUBNET GROUP
##-------------------------------------------------------------
output "redshift_subnet_group_id" {
  value       = module.redshift.subnet_group_id
  description = "The Redshift Subnet group ID."
}

output "redshift_subnet_group_arn" {
  value       = module.redshift.subnet_group_arn
  description = "Amazon Resource Name (ARN) of the Redshift Subnet group name"
}

##-------------------------------------------------------------
## PARAMETER GROUP
##-------------------------------------------------------------
output "redshift_parameter_group_id" {
  value       = module.redshift.parameter_group_id
  description = "The Redshift parameter group name."
}

output "redshift_parameter_group_arn" {
  value       = module.redshift.parameter_group_arn
  description = "Amazon Resource Name (ARN) of parameter group"
}

##-------------------------------------------------------------
## SECRETS MANAGER
##-------------------------------------------------------------
output "redshift_secret_arn" {
  value       = module.redshift.secret_arn
  description = "ARN of the secret."
}

output "redshift_secret_id" {
  value       = module.redshift.secret_id
  description = "A pipe delimited combination of secret ID and version ID."
}

##-------------------------------------------------------------
## REDSHIFT ENDPOINT
##-------------------------------------------------------------
output "redshift_endpoint_address" {
  value       = module.redshift.endpoint_address
  description = "The DNS address of the endpoint."
}

output "redshift_endpoint_id" {
  value       = module.redshift.endpoint_id
  description = "The Redshift-managed VPC endpoint name."
}

output "redshift_endpoint_port" {
  value       = module.redshift.endpoint_port
  description = "The port number on which the cluster accepts incoming connections."
}

output "redshift_vpc_endpoint" {
  value       = module.redshift.vpc_endpoint
  description = "The connection endpoint for connecting to an Amazon Redshift cluster through the proxy. See details below."
}
