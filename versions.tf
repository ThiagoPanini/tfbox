/* -----------------------------------------------------------------------------
  FILE: versions.tf
  MODULE: aws/sns-topic

  DESCRIPTION:
    Configuration of Terraform version and provider used for deployment of
    module infrastructure resources.
----------------------------------------------------------------------------- */

terraform {
  required_version = ">= 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }
  }
}
