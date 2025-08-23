## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| alias | The display name of the alias. The name must start with the word `alias` followed by a forward slash. | `string` | `""` | no |
| allowed\_ips | (Optional) List of CIDR blocks (IPs) to allow traffic from. | `list(string)` | `[]` | no |
| assume\_role\_policy | Whether to create Iam role. | `string` | `""` | no |
| cluster\_config | Configuration map for the Redshift cluster | <pre>object({<br>    database_name                       = optional(string, null)<br>    master_username                     = optional(string, null)<br>    master_password                     = optional(string, null)<br>    number_of_nodes                     = optional(number, null)<br>    publicly_accessible                 = optional(bool, null)<br>    availability_zone                   = optional(string, null)<br>    subnet_ids                          = optional(list(string), [])<br>    vpc_id                              = optional(string, null)<br>    cluster_type                        = optional(string, null) # valid values are - single-node, multi-node.<br>    node_type                           = optional(string, null) # valid values are ra3.large, ra3.xplus, ra3.4xlarge, ra3.16xlarge<br>    automated_snapshot_retention_period = optional(number, null) # valid values are 1 to 35 (days).<br>    parameter_group_family              = optional(string, null) # valid values are redshift-1.0, redshift-2.0<br>  })</pre> | `{}` | no |
| create\_endpoint\_access | Flag to control the creation of Redshift endpoint access | `bool` | `false` | no |
| create\_iam\_role | Flag to create IAM roles for Redshift | `bool` | `true` | no |
| create\_parameter\_group | Whether to create a new Redshift parameter group. | `bool` | `true` | no |
| create\_random\_password | Flag to create a random password if master\_password is not provided | `bool` | `true` | no |
| create\_secret\_manager | Whether to create a new AWS Secrets Manager secret for storing the Redshift master password. If false, no secret will be created and you must provide your own secret ARN. | `bool` | `true` | no |
| create\_security\_group | Flag to indicate if an existing security group should be used | `bool` | `true` | no |
| create\_subnet\_group | Whether to create a new Redshift subnet group. If false, you must provide an existing subnet\_group\_id. | `bool` | `true` | no |
| customer\_master\_key\_spec | Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: SYMMETRIC\_DEFAULT, RSA\_2048, RSA\_3072, RSA\_4096, ECC\_NIST\_P256, ECC\_NIST\_P384, ECC\_NIST\_P521, or ECC\_SECG\_P256K1. Defaults to SYMMETRIC\_DEFAULT. | `string` | `"SYMMETRIC_DEFAULT"` | no |
| default\_iam\_role\_arn | (Required) The default IAM role ARN to associate with the Redshift cluster | `string` | `""` | no |
| deletion\_window\_in\_days | Duration in days after which the key is deleted after destruction of the resource. | `number` | `10` | no |
| enable | Set this to false to prevent creation of all resources and supported data sources in this module. | `bool` | `true` | no |
| enable\_encryption | Whether the data in the cluster is encrypted. | `bool` | `false` | no |
| enable\_key\_rotation | Whether the data in the cluster is encrypted. | `bool` | `false` | no |
| endpoint\_resource\_owner | Resource owner of the Redshift endpoint | `string` | `""` | no |
| endpoint\_vpc\_security\_group\_ids | List of VPC security group IDs for the Redshift endpoint | `list(string)` | `[]` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| existing\_subnet\_group\_id | ID of an existing Redshift subnet group. Leave empty to create a new one. | `string` | `""` | no |
| iam\_role\_arns | List of IAM role ARNs to associate with the Redshift cluster | `list(string)` | `[]` | no |
| key\_usage | Specifies the intended use of the key. Defaults to ENCRYPT\_DECRYPT, and only symmetric encryption and decryption are supported. | `string` | `"ENCRYPT_DECRYPT"` | no |
| kms\_key\_arn | (Optional) ARN of an existing KMS key to use for encryption. If not set, a new KMS key will be created. Works only when `enable_encryption` is set to `true` | `string` | `""` | no |
| kms\_resource\_policy | A valid policy JSON document. Although this is a key policy, not an IAM policy, an `aws_iam_policy_document`, in the form that designates a principal, can be used | `string` | `null` | no |
| label\_order | Label order, e.g. `name`,`application`. | `list(any)` | <pre>[<br>  "environment",<br>  "name"<br>]</pre> | no |
| managed\_policy\_arns | Set of exclusive IAM managed policy ARNs to attach to the IAM role | `list(any)` | `[]` | no |
| managedby | ManagedBy, eg 'CloudDrove'. | `string` | `"hello@clouddrove.com"` | no |
| name | Name  (e.g. `app` or `cluster`). | `string` | `""` | no |
| override\_special | Supply your own list of special characters `!#$%&*()-_=+[]{}<>:?` to use for string generation. This overrides the default character list in the special argument. The special argument must still be set to true for any overwritten characters to be used in generation. | `string` | `""` | no |
| parameter\_group\_name | Name of the Redshift parameter group. If not provided, cluster\_config.cluster\_identifier will be used (dots replaced with hyphens). | `string` | `""` | no |
| parameter\_group\_parameters | List of parameters to apply in the Redshift parameter group. | <pre>list(object({<br>    name  = string<br>    value = string<br>  }))</pre> | `[]` | no |
| policy | (Required) The inline policy document. This is a JSON formatted string. For more information about building IAM policy documents with Terraform, see the https://learn.hashicorp.com/terraform/aws/iam-policy Document Guide | `string` | `""` | no |
| random\_password\_length | The length of the random password to be generated | `number` | `16` | no |
| repository | Terraform current module repo | `string` | `"https://github.com/clouddrove/terraform-aws-redshift"` | no |
| security\_group\_ids | (Optional) A list of Virtual Private Cloud (VPC) security groups to be associated with the cluster. | `list(string)` | `[]` | no |
| skip\_final\_snapshot | (Optional) Determines whether a final snapshot of the cluster is created before Amazon Redshift deletes the cluster. If true , a final cluster snapshot is not created. If false , a final cluster snapshot is created before the cluster is deleted. Default is false. | `bool` | `true` | no |
| tags | Additional tags (e.g. map(`BusinessUnit`,`XYZ`). | `map(any)` | `{}` | no |
| use\_existing\_subnet\_group | Flag to indicate if an existing subnet group should be used | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | Amazon Resource Name (ARN) of cluster |
| automated\_snapshot\_retention\_period | The backup retention period |
| availability\_zone | The availability zone of the Cluster |
| cluster\_identifier | The Cluster Identifier |
| cluster\_namespace\_arn | The namespace Amazon Resource Name (ARN) of the cluster |
| cluster\_nodes | The nodes in the cluster. Cluster node blocks are documented below |
| cluster\_public\_key | The public key for the cluster |
| cluster\_revision\_number | The specific revision number of the database in the cluster |
| cluster\_type | The cluster type |
| cluster\_version | The version of Redshift engine software |
| database\_name | The name of the default database in the Cluster |
| dns\_name | The DNS name of the cluster |
| encrypted | Whether the data in the cluster is encrypted |
| endpoint | The connection endpoint |
| endpoint\_address | The DNS address of the endpoint. |
| endpoint\_id | The Redshift-managed VPC endpoint name. |
| endpoint\_port | The port number on which the cluster accepts incoming connections. |
| iam\_role\_arn | The Amazon Resource Name (ARN) specifying the role. |
| iam\_role\_name | Name of specifying the role. |
| id | The Redshift Cluster ID. |
| kms\_alias\_arn | KMS Alias ARN. |
| kms\_alias\_name | KMS Alias name. |
| kms\_key\_arn | KMS Key ARN. |
| kms\_key\_id | KMS Key ID. |
| node\_type | The type of nodes in the cluster |
| parameter\_group\_arn | Amazon Resource Name (ARN) of parameter group |
| parameter\_group\_id | The Redshift parameter group name. |
| port | The Port the cluster responds on |
| preferred\_maintenance\_window | The backup window |
| secret\_arn | ARN of the secret. |
| secret\_id | A pipe delimited combination of secret ID and version ID. |
| security\_group\_arn | IDs on the AWS Security Groups associated with the instance. |
| security\_group\_id | IDs on the AWS Security Groups associated with the instance. |
| subnet\_group\_arn | Amazon Resource Name (ARN) of the Redshift Subnet group name |
| subnet\_group\_id | The Redshift Subnet group ID. |
| vpc\_endpoint | The connection endpoint for connecting to an Amazon Redshift cluster through the proxy. See details below. |
| vpc\_security\_group\_ids | The VPC security group Ids associated with the cluster |

