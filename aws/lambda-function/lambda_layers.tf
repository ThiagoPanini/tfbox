/* -----------------------------------------------------------------------------
  FILE: lambda_layers.tf
  MODULE: aws/lambda-function

  DESCRIPTION:
    This file conditionally calls the aws/lambda-layer module to create
    Lambda Layers based on the input variables. It passes the layers_info
    map to the module for layer creation.

  RESOURCES:
    - module.aws_lambda_layers:
        Provisions Lambda Layers if enabled.
----------------------------------------------------------------------------- */

# Calling the Lambda Layers module to create layers if enabled
module "aws_lambda_layers" {
  count      = var.create_lambda_layers ? 1 : 0
  source     = "git::https://github.com/ThiagoPanini/tfbox.git?ref=aws/lambda-layer/v0.4.0"
  layers_map = var.layers_map
}
