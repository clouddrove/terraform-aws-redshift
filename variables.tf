variable "enable" {
  description = "Set this to false to prevent creation of all resources and supported data sources in this module."
  type        = bool
  default     = true
}

##-------------------------------------------------------------
## LABELS
##-------------------------------------------------------------
variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "extra_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)."
}

variable "repository" {
  type        = string
  default     = "https://github.com/clouddrove/terraform-aws-redshift"
  description = "Terraform current module repo"

  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^https://", var.repository))
    error_message = "The module-repo value must be a valid Git repo link."
  }
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "label_order" {
  type        = list(any)
  default     = ["environment", "name"]
  description = "Label order, e.g. `name`,`application`."
}

variable "tags" {
  type        = map(any)
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)."
}

variable "managedby" {
  type        = string
  default     = "hello@clouddrove.com"
  description = "ManagedBy, eg 'CloudDrove'."
}

##-------------------------------------------------------------
## KMS KEY
##-------------------------------------------------------------
variable "enable_encryption" {
  description = "Whether the data in the cluster is encrypted."
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "(Optional) ARN of an existing KMS key to use for encryption. If not set, a new KMS key will be created. Works only when `enable_encryption` is set to `true`"
  type        = string
  default     = ""
}

variable "key_usage" {
  type        = string
  default     = "ENCRYPT_DECRYPT"
  sensitive   = true
  description = "Specifies the intended use of the key. Defaults to ENCRYPT_DECRYPT, and only symmetric encryption and decryption are supported."
}

variable "deletion_window_in_days" {
  type        = number
  default     = 10
  description = "Duration in days after which the key is deleted after destruction of the resource."
}

variable "enable_key_rotation" {
  description = "Whether the data in the cluster is encrypted."
  type        = bool
  default     = false
}

variable "customer_master_key_spec" {
  type        = string
  default     = "SYMMETRIC_DEFAULT"
  description = "Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: SYMMETRIC_DEFAULT, RSA_2048, RSA_3072, RSA_4096, ECC_NIST_P256, ECC_NIST_P384, ECC_NIST_P521, or ECC_SECG_P256K1. Defaults to SYMMETRIC_DEFAULT."
  sensitive   = true
}

variable "kms_resource_policy" {
  type        = string
  default     = null
  description = "A valid policy JSON document. Although this is a key policy, not an IAM policy, an `aws_iam_policy_document`, in the form that designates a principal, can be used"
}

variable "alias" {
  type        = string
  default     = ""
  description = "The display name of the alias. The name must start with the word `alias` followed by a forward slash."
}

##-------------------------------------------------------------
## IAM ROLE
##-------------------------------------------------------------
variable "create_iam_role" {
  description = "Flag to create IAM roles for Redshift"
  type        = bool
  default     = true
}

variable "assume_role_policy" {
  type        = string
  default     = ""
  sensitive   = true
  description = "Whether to create Iam role."
}

variable "managed_policy_arns" {
  type        = list(any)
  default     = []
  description = "Set of exclusive IAM managed policy ARNs to attach to the IAM role"
}

variable "policy" {
  type        = string
  default     = ""
  sensitive   = true
  description = "(Required) The inline policy document. This is a JSON formatted string. For more information about building IAM policy documents with Terraform, see the https://learn.hashicorp.com/terraform/aws/iam-policy Document Guide"
}

variable "iam_role_arns" {
  description = "List of IAM role ARNs to associate with the Redshift cluster"
  type        = list(string)
  default     = []
}

variable "default_iam_role_arn" {
  description = "(Required) The default IAM role ARN to associate with the Redshift cluster"
  type        = string
  default     = ""
}

##-------------------------------------------------------------
## SECURITY GROUP
##-------------------------------------------------------------
variable "create_security_group" {
  description = "Flag to indicate if an existing security group should be used"
  type        = bool
  default     = true
}

variable "security_group_ids" {
  description = "(Optional) A list of Virtual Private Cloud (VPC) security groups to be associated with the cluster."
  type        = list(string)
  default     = []
}
variable "allowed_ips" {
  description = "(Optional) List of CIDR blocks (IPs) to allow traffic from."
  type        = list(string)
  default     = []
}

##-------------------------------------------------------------
## SUBNET GROUP
##-------------------------------------------------------------
variable "create_subnet_group" {
  description = "Whether to create a new Redshift subnet group. If false, you must provide an existing subnet_group_id."
  type        = bool
  default     = true
}

variable "existing_subnet_group_id" {
  description = "ID of an existing Redshift subnet group. Leave empty to create a new one."
  type        = string
  default     = ""
}

##-------------------------------------------------------------
## PARAMETER GROUP
##-------------------------------------------------------------

variable "create_parameter_group" {
  description = "Whether to create a new Redshift parameter group."
  type        = bool
  default     = true
}

variable "parameter_group_name" {
  description = "Name of the Redshift parameter group. If not provided, cluster_config.cluster_identifier will be used (dots replaced with hyphens)."
  type        = string
  default     = ""
}

variable "parameter_group_parameters" {
  description = "List of parameters to apply in the Redshift parameter group."
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

##-------------------------------------------------------------
## MANAGED PASSWORD
##-------------------------------------------------------------
variable "create_random_password" {
  description = "Flag to create a random password if master_password is not provided"
  type        = bool
  default     = true
}

variable "override_special" {
  description = "Supply your own list of special characters `!#$%&*()-_=+[]{}<>:?` to use for string generation. This overrides the default character list in the special argument. The special argument must still be set to true for any overwritten characters to be used in generation."
  type        = string
  default     = ""
}

variable "random_password_length" {
  description = "The length of the random password to be generated"
  type        = number
  default     = 16
}

variable "create_secret_manager" {
  description = "Whether to create a new AWS Secrets Manager secret for storing the Redshift master password. If false, no secret will be created and you must provide your own secret ARN."
  type        = bool
  default     = true
}

##-------------------------------------------------------------
## REDSHIFT CLUSTER
##-------------------------------------------------------------
variable "use_existing_subnet_group" {
  description = "Flag to indicate if an existing subnet group should be used"
  type        = bool
  default     = false
}

variable "cluster_config" {
  description = "Configuration map for the Redshift cluster"
  type = object({
    database_name                       = optional(string, null)
    master_username                     = optional(string, null)
    master_password                     = optional(string, null)
    number_of_nodes                     = optional(number, null)
    publicly_accessible                 = optional(bool, null)
    availability_zone                   = optional(string, null)
    subnet_ids                          = optional(list(string), [])
    vpc_id                              = optional(string, null)
    cluster_type                        = optional(string, null) # valid values are - single-node, multi-node.
    node_type                           = optional(string, null) # valid values are ra3.large, ra3.xplus, ra3.4xlarge, ra3.16xlarge
    automated_snapshot_retention_period = optional(number, null) # valid values are 1 to 35 (days).
    parameter_group_family              = optional(string, null) # valid values are redshift-1.0, redshift-2.0
  })

  default = {}
}

variable "skip_final_snapshot" {
  type        = bool
  default     = true
  description = "(Optional) Determines whether a final snapshot of the cluster is created before Amazon Redshift deletes the cluster. If true , a final cluster snapshot is not created. If false , a final cluster snapshot is created before the cluster is deleted. Default is false."
}

##-------------------------------------------------------------
## REDSHIFT ENDPOINT
##-------------------------------------------------------------

variable "create_endpoint_access" {
  description = "Flag to control the creation of Redshift endpoint access"
  type        = bool
  default     = false
}

variable "endpoint_resource_owner" {
  description = "Resource owner of the Redshift endpoint"
  type        = string
  default     = ""
}

variable "endpoint_vpc_security_group_ids" {
  description = "List of VPC security group IDs for the Redshift endpoint"
  type        = list(string)
  default     = []
}
