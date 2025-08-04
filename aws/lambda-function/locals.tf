/* -----------------------------------------------------------------------------
  FILE: locals.tf
  MODULE: aws/lambda-layer

  DESCRIPTION:
    This file declares local variables for the aws/lambda-layer Terraform module.
    These locals are used to define paths and structures for layer creation,
    including the source code directory and the structure of layer information.

  LOCALS:
    
----------------------------------------------------------------------------- */

locals {
  # Paths information for Lambda function source code
  source_dir_parent = dirname(var.source_code_path)
  source_dir_name   = basename(var.source_code_path)
  output_zip        = "${local.source_dir_parent}/${var.function_name}.zip"
}
