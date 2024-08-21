output "redshift_cluster_id" {
  value       = module.terraform-aws-redshift.redshift_cluster_id
  description = "The ID of the created Redshift cluster."
}