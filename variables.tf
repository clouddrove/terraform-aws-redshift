variable "region" {
  description = "The AWS region to create resources in"
  type        = string
}

variable "name" {
  description = "The name used for the resources"
  type        = string
}

variable "repository" {
  description = "The repository name"
  type        = string
}

variable "environment" {
  description = "The environment name"
  type        = string
}

variable "managedby" {
  description = "Managed by label"
  type        = string
}

variable "label_order" {
  description = "The order of labels"
  type        = list(string)
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = map(string)
}

variable "use_existing_security_group" {
  description = "Flag to indicate if an existing security group should be used"
  type        = bool
  default     = false
}

variable "existing_security_group_id" {
  description = "ID of the existing security group to use"
  type        = string
  default     = ""
}

variable "use_existing_subnet_group" {
  description = "Flag to indicate if an existing subnet group should be used"
  type        = bool
  default     = false
}

variable "existing_subnet_group_name" {
  description = "Name of the existing subnet group to use"
  type        = string
  default     = ""
}

variable "ingress_rules" {
  description = "Ingress rules for the security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "egress_rules" {
  description = "Egress rules for the security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "cluster_config" {
  description = "Configuration map for the Redshift cluster"
  type = object({
    cluster_identifier                  = string
    database_name                       = string
    master_username                     = string
    master_password                     = string
    node_type                           = string
    cluster_type                        = string
    number_of_nodes                     = number
    publicly_accessible                 = bool
    automated_snapshot_retention_period = number
    availability_zone                   = string
    subnet_group_name                   = string
    subnet_ids                          = list(string)
    vpc_id                              = string
    security_group_name                 = string
  })
}

variable "create_random_password" {
  description = "Flag to create a random password if master_password is not provided"
  type        = bool
  default     = false
}

variable "random_password_length" {
  description = "The length of the random password to be generated"
  type        = number
  default     = 16
}

variable "enable" {
  description = "Flag to enable or disable the module"
  type        = bool
  default     = true
}
variable "iam_role_arns" {
  description = "List of IAM role ARNs to associate with the Redshift cluster"
  type        = list(string)
  default     = []
}

variable "default_iam_role_arn" {
  description = "The default IAM role ARN to associate with the Redshift cluster"
  type        = string
  default     = ""
}

variable "iam_role_name" {
  description = "The name to use for the IAM role"
  type        = string
  default     = "RedshiftIAMRole"
}

variable "iam_role_description" {
  description = "The description of the IAM role"
  type        = string
  default     = "IAM role for Redshift cluster"
}

variable "iam_role_policy" {
  description = "The IAM policy JSON for the Redshift role."
  type        = string
}


variable "create_iam_role" {
  description = "Flag to create IAM roles for Redshift"
  type        = bool
  default     = true
}

variable "existing_iam_role_arns" {
  description = "List of existing IAM role ARNs to attach to the Redshift cluster."
  type        = list(string)
  default     = [] # Default to an empty list if no roles are provided
}

variable "create_parameter_group" {
  type        = bool
  default     = false
  description = "Flag to create a new Redshift parameter group."
}

variable "parameter_group_name" {
  type        = string
  description = "Name of the Redshift parameter group."
}

variable "parameter_group_description" {
  type        = string
  description = "Description of the Redshift parameter group."
}

variable "parameter_group_family" {
  type        = string
  description = "The family of the Redshift parameter group."
}

variable "parameter_group_parameters" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "List of parameters for the Redshift parameter group."
}

variable "parameter_group_tags" {
  type        = map(string)
  default     = {}
  description = "Tags to assign to the parameter group."
}


variable "create_endpoint_access" {
  description = "Flag to control the creation of Redshift endpoint access"
  type        = bool
  default     = false
}

variable "endpoint_name" {
  description = "Name of the Redshift endpoint"
  type        = string
}

variable "endpoint_resource_owner" {
  description = "Resource owner of the Redshift endpoint"
  type        = string
}

variable "endpoint_subnet_group_name" {
  description = "Name of the subnet group for the Redshift endpoint"
  type        = string
  default     = null
}

variable "endpoint_vpc_security_group_ids" {
  description = "List of VPC security group IDs for the Redshift endpoint"
  type        = list(string)
}

variable "skip_final_snapshot" {
  description = "The identifier of the final snapshot that is to be created immediately before deleting the cluster."
  type        = bool
}

variable "encryption" {
  description = "Whether the data in the cluster is encrypted."
  type        = bool
}
