/* -----------------------------------------------------------------------------
  FILE: data.tf
  MODULE: aws/dynamodb-table

  DESCRIPTION:
    Centralized Terraform data source definitions for the AWS DynamoDB Table
    module. This file provides consistent access to AWS account and region
    information, enabling dynamic and environment-aware resource provisioning
    throughout the module.

  DATA SOURCES:
    - aws_caller_identity.current: Retrieves the AWS account ID and user information.
    - aws_region.current: Obtains the current AWS region in use.
----------------------------------------------------------------------------- */

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
