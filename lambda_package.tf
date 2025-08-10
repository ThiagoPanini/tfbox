/* -----------------------------------------------------------------------------
  FILE: lambda_package.tf
  MODULE: aws/lambda-function

  DESCRIPTION:
    This file handles packaging and cleanup for AWS Lambda deployment artifacts.
    It builds a Lambda deployment package (.zip) from the specified source path
    using a local-exec provisioner, and removes the package after deployment to
    keep the workspace clean.

  RESOURCES:
    - null_resource.zip_lambda_package:
        Creates the Lambda deployment .zip file.

    - null_resource.cleanup_lambda_package:
        Deletes the .zip file after deployment.
----------------------------------------------------------------------------- */

# Build lambda deployment package (.zip) from source_path
resource "null_resource" "zip_lambda_package" {
  provisioner "local-exec" {
    # command = "cd ${var.source_code_path} && zip -r ${local.output_zip_package} ."
    # command = "zip -r ${local.output_zip_package} ${var.source_code_path}"
    # command = "cd $(dirname ${var.source_code_path}) && zip -r ${local.output_zip_package} $(basename ${var.source_code_path})"
    # command = "cd ${local.source_dir_parent} && zip -r ${local.output_zip_package} ${local.source_dir_name}"
    command = "cd ${local.source_dir_parent} && zip -r ${var.function_name}.zip ${local.source_dir_name}"
  }

  triggers = {
    always_run = timestamp()
  }
}

# Cleanup zip after deployment
resource "null_resource" "cleanup_lambda_package" {
  provisioner "local-exec" {
    command     = "rm -f ${local.output_zip_package}"
    interpreter = ["/bin/bash", "-c"]
  }

  triggers = {
    always_run = timestamp()
  }

  depends_on = [
    aws_lambda_function.this
  ]
}
