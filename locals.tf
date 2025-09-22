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
  source_dir_parent  = dirname(var.source_code_path)
  source_dir_name    = basename(var.source_code_path)
  output_zip_package = "${local.source_dir_parent}/${var.function_name}.zip"

  # Get all files, then filter out excluded patterns
  all_files = fileset(var.source_code_path, "**/*")

  # Filter out files matching exclude patterns
  relevant_files = var.source_code_hash_enabled ? [
    for file in local.all_files :
    file if !anytrue([
      for pattern in var.exclude_patterns :
      can(regex(replace(replace(pattern, "**", ".*"), "*", "[^/]*"), file))
    ])
  ] : []

  # Create a hash based on configuration
  source_code_hash = var.source_code_hash_enabled ? md5(join("", [
    for file in local.relevant_files :
    fileexists("${var.source_code_path}/${file}") ?
    "${file}:${filemd5("${var.source_code_path}/${file}")}" : ""
  ])) : timestamp()
}
