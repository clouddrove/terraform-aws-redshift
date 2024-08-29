## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_config | Configuration map for the Redshift cluster | <pre>object({<br>    cluster_identifier                  = string<br>    database_name                       = string<br>    master_username                     = string<br>    master_password                     = string<br>    node_type                           = string<br>    cluster_type                        = string<br>    number_of_nodes                     = number<br>    publicly_accessible                 = bool<br>    automated_snapshot_retention_period = number<br>    availability_zone                   = string<br>    subnet_group_name                   = string<br>    subnet_ids                          = list(string)<br>    vpc_id                              = string<br>    security_group_name                 = string<br>  })</pre> | n/a | yes |
| create\_endpoint\_access | Flag to control the creation of Redshift endpoint access | `bool` | `false` | no |
| create\_iam\_role | Flag to create IAM roles for Redshift | `bool` | `true` | no |
| create\_parameter\_group | Flag to create a new Redshift parameter group. | `bool` | `false` | no |
| create\_random\_password | Flag to create a random password if master\_password is not provided | `bool` | `false` | no |
| default\_iam\_role\_arn | The default IAM role ARN to associate with the Redshift cluster | `string` | `""` | no |
| egress\_rules | Egress rules for the security group | <pre>list(object({<br>    from_port   = number<br>    to_port     = number<br>    protocol    = string<br>    cidr_blocks = list(string)<br>  }))</pre> | n/a | yes |
| enable | Flag to enable or disable the module | `bool` | `true` | no |
| encryption | Whether the data in the cluster is encrypted. | `bool` | n/a | yes |
| endpoint\_name | Name of the Redshift endpoint | `string` | n/a | yes |
| endpoint\_resource\_owner | Resource owner of the Redshift endpoint | `string` | n/a | yes |
| endpoint\_subnet\_group\_name | Name of the subnet group for the Redshift endpoint | `string` | `null` | no |
| endpoint\_vpc\_security\_group\_ids | List of VPC security group IDs for the Redshift endpoint | `list(string)` | n/a | yes |
| environment | The environment name | `string` | n/a | yes |
| existing\_iam\_role\_arns | List of existing IAM role ARNs to attach to the Redshift cluster. | `list(string)` | `[]` | no |
| existing\_security\_group\_id | ID of the existing security group to use | `string` | `""` | no |
| existing\_subnet\_group\_name | Name of the existing subnet group to use | `string` | `""` | no |
| iam\_role\_arns | List of IAM role ARNs to associate with the Redshift cluster | `list(string)` | `[]` | no |
| iam\_role\_description | The description of the IAM role | `string` | `"IAM role for Redshift cluster"` | no |
| iam\_role\_name | The name to use for the IAM role | `string` | `"RedshiftIAMRole"` | no |
| iam\_role\_policy | The IAM policy JSON for the Redshift role. | `string` | n/a | yes |
| ingress\_rules | Ingress rules for the security group | <pre>list(object({<br>    from_port   = number<br>    to_port     = number<br>    protocol    = string<br>    cidr_blocks = list(string)<br>  }))</pre> | n/a | yes |
| label\_order | The order of labels | `list(string)` | n/a | yes |
| managedby | Managed by label | `string` | n/a | yes |
| name | The name used for the resources | `string` | n/a | yes |
| parameter\_group\_description | Description of the Redshift parameter group. | `string` | n/a | yes |
| parameter\_group\_family | The family of the Redshift parameter group. | `string` | n/a | yes |
| parameter\_group\_name | Name of the Redshift parameter group. | `string` | n/a | yes |
| parameter\_group\_parameters | List of parameters for the Redshift parameter group. | <pre>list(object({<br>    name  = string<br>    value = string<br>  }))</pre> | n/a | yes |
| parameter\_group\_tags | Tags to assign to the parameter group. | `map(string)` | `{}` | no |
| random\_password\_length | The length of the random password to be generated | `number` | `16` | no |
| region | The AWS region to create resources in | `string` | n/a | yes |
| repository | The repository name | `string` | n/a | yes |
| skip\_final\_snapshot | The identifier of the final snapshot that is to be created immediately before deleting the cluster. | `bool` | n/a | yes |
| tags | Tags to be applied to resources | `map(string)` | n/a | yes |
| use\_existing\_security\_group | Flag to indicate if an existing security group should be used | `bool` | `false` | no |
| use\_existing\_subnet\_group | Flag to indicate if an existing subnet group should be used | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| endpoint\_access\_id | The ID of the created Redshift endpoint access. |
| generated\_master\_password | n/a |
| iam\_role\_id | The ID of the created IAM role for Redshift. |
| iam\_role\_policy\_id | The ID of the created IAM policy for Redshift. |
| redshift\_cluster\_database\_name | The name of the database in the Redshift cluster. |
| redshift\_cluster\_endpoint | The endpoint of the Redshift cluster. |
| redshift\_cluster\_id | The ID of the Redshift cluster. |
| redshift\_cluster\_master\_username | The master username of the Redshift cluster. |
| security\_group\_id | The ID of the created security group. |
| subnet\_group\_name | The name of the created subnet group. |

