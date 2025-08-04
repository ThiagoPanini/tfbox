/* -----------------------------------------------------------------------------
  FILE: main.tf
  MODULE: aws/lambda-function

  DESCRIPTION:
    This Terraform module provisions AWS Lambda functions with flexible
    configuration and best practices. Supports inline and S3-based deployment
    packages, Lambda Layers, VPC, IAM, event sources, versioning, aliases, and
    monitoring integrations.

  RESOURCES:
    - aws_lambda_function.this: Provisions the Lambda function.
    - aws_cloudwatch_log_group.lambda: Creates log group for Lambda.
    - aws_lambda_alias.this: Optionally creates Lambda alias.
    - aws_lambda_event_source_mapping.this: Configures event source mappings.
----------------------------------------------------------------------------- */

# Build Lambda deployment package (zip) from source_path
resource "null_resource" "zip_lambda_package" {

  provisioner "local-exec" {
    command = "cd ${local.source_dir_parent} && zip -r ${local.output_zip} ${local.source_dir_name}"
  }

  triggers = {
    always_run = timestamp()
  }
}

# Build Lambda function
resource "aws_lambda_function" "this" {
  function_name = var.function_name
  runtime       = var.runtime
  architectures = var.architectures
  role          = var.role_arn
  timeout       = var.timeout
  memory_size   = var.memory_size

  filename = local.output_zip
  handler  = var.lambda_handler

  depends_on = [
    null_resource.zip_lambda_package
  ]
}

# Cleanup zip after deployment (optional, controlled by var.cleanup_after_build)
resource "null_resource" "cleanup_lambda_package" {
  count = var.cleanup_after_build ? 1 : 0

  provisioner "local-exec" {
    command     = "rm -f ${local.output_zip}"
    interpreter = ["/bin/bash", "-c"]
  }

  triggers = {
    always_run = timestamp()
  }

  depends_on = [
    aws_lambda_function.this
  ]
}

/*
ToDos:
  - Enable lambda layers support by optionally calling aws/lambda-layer module
  - Add support for VPC configuration
  - Add support for environment variables
  - Add support for event sources (Eventbridge, SQS, SNS, S3, etc.)
  - Add support for tags
  - Add support for KMS encryption
*/
