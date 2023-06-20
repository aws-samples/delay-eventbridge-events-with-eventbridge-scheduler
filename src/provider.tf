# ------------------------------------------------------------------------------
# PROVIDER CONFIGS
# ------------------------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs

### IaC Account Provider ###
provider "aws" {}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.63.0"
    }
  }
  required_version = ">=1, <2"
}