/* -----------------------------------------------------------------------------
  FILE: locals.tf
  MODULE: aws/glue-job

  DESCRIPTION:
    This file defines local variables for the aws/glue-job Terraform module.
    The purpose of these locals is to centralize dynamic values—such as the AWS
    account ID and region name—retrieved at runtime.

  LOCAL VARIABLES:
    - account_id: The AWS account ID of the current caller.
    - region_name: The AWS region in which resources are being deployed.
----------------------------------------------------------------------------- */

locals {
  # Account ID and region name for further use in the module
  account_id  = data.aws_caller_identity.current.account_id
  region_name = data.aws_region.current.region

  # Building local values for uploading Glue scripts to S3
  fileset_pattern = "${var.glue_assets_local_application_folder}/**/*{${join(",", var.file_extensions_to_upload)}}"
  glue_assets     = fileset(path.root, local.fileset_pattern)
}


output "fileset_pattern" {
  value = local.fileset_pattern
}

output "glue_assets" {
  value = local.glue_assets
}
