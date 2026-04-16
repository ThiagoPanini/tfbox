/* -----------------------------------------------------------------------------
  FILE: data.tf
  MODULE: aws/glue-job

  DESCRIPTION:
    This file centralizes Terraform data source definitions.

  DATA SOURCES:
    - aws_caller_identity.current: Retrieves the AWS account ID and user information.
    - aws_region.current: Obtains the current AWS region in use.
----------------------------------------------------------------------------- */

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
