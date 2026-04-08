# Terraform version
terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.80.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.2.1"
    }
  }

  provider_meta "aws" {
    module_name = "clouddrove/terraform-aws-redshift"
  }
}
