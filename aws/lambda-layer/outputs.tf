/* -----------------------------------------------------------------------------
  FILE: outputs.tf
  MODULE: aws/lambda-layer

  DESCRIPTION:
    Outputs for the Lambda layer module, including layer ARNs, layer names, and
    version numbers.
----------------------------------------------------------------------------- */

output "layers_arns" {
  description = "A map of Lambda layer ARNs created by this module, with layer names as keys."
  value       = { for layer in aws_lambda_layer_version.this : layer.layer_name => layer.arn }
}
