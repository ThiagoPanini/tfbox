/* -----------------------------------------------------------------------------
  FILE: locals.tf
  MODULE: aws/dynamodb-table

  DESCRIPTION:
    This file defines local variables for the aws/dynamodb-table Terraform module.
    The purpose of these locals is to centralize dynamic values—such as the AWS
    account ID and region name—retrieved at runtime.

  LOCAL VARIABLES:
    - account_id: The AWS account ID of the current caller.
    - region_name: The AWS region in which resources are being deployed.
----------------------------------------------------------------------------- */

locals {
  account_id  = data.aws_caller_identity.current.account_id
  region_name = data.aws_region.current.name
}
