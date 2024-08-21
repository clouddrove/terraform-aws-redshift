output "security_group_id" {
  value       = length(aws_security_group.this) > 0 ? aws_security_group.this[0].id : null
  description = "The ID of the created security group."
}

output "subnet_group_name" {
  value       = length(aws_redshift_subnet_group.this) > 0 ? aws_redshift_subnet_group.this[0].name : null
  description = "The name of the created subnet group."
}

output "redshift_cluster_id" {
  value       = var.enable ? aws_redshift_cluster.this[0].id : null
  description = "The ID of the Redshift cluster."
}

output "redshift_cluster_endpoint" {
  value       = var.enable ? aws_redshift_cluster.this[0].endpoint : null
  description = "The endpoint of the Redshift cluster."
}

output "redshift_cluster_master_username" {
  value       = var.enable ? aws_redshift_cluster.this[0].master_username : null
  description = "The master username of the Redshift cluster."
}

output "redshift_cluster_database_name" {
  value       = var.enable ? aws_redshift_cluster.this[0].database_name : null
  description = "The name of the database in the Redshift cluster."
}

output "generated_master_password" {
  value     = random_password.master_password[0].result
  sensitive = true # Mark as sensitive to avoid showing in plain text in the console
}

output "iam_role_id" {
  value       = var.create_iam_role ? aws_iam_role.redshift_role[0].id : null
  description = "The ID of the created IAM role for Redshift."
}

output "iam_role_policy_id" {
  value       = var.create_iam_role ? aws_iam_policy.redshift_policy[0].id : null
  description = "The ID of the created IAM policy for Redshift."
}

output "endpoint_access_id" {
  value       = var.create_endpoint_access && length(aws_redshift_endpoint_access.this) > 0 ? aws_redshift_endpoint_access.this[0].id : null
  description = "The ID of the created Redshift endpoint access."
}
