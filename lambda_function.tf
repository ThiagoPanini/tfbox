/* -----------------------------------------------------------------------------
  FILE: lambda_function.tf
  MODULE: aws/lambda-function

  DESCRIPTION:
    This Terraform module provisions AWS Lambda functions with flexible
    configuration and best practices.

  RESOURCES:
    - aws_lambda_function.this:
        Provisions the Lambda function.
----------------------------------------------------------------------------- */

# Build Lambda function
resource "aws_lambda_function" "this" {
  function_name = var.function_name
  runtime       = var.runtime
  architectures = var.architectures
  role          = var.role_arn
  timeout       = var.timeout
  memory_size   = var.memory_size

  filename = local.output_zip_package
  handler  = var.lambda_handler

  layers = var.layers_arns

  environment {
    variables = var.environment_variables
  }

  tags = var.tags

  depends_on = [
    null_resource.zip_lambda_package
  ]
}
