/* -----------------------------------------------------------------------------
  FILE: outputs.tf
  MODULE: aws/lambda-layer

  DESCRIPTION:
    Outputs for the Lambda layer module, including layer ARNs, layer names, and
    version numbers.
----------------------------------------------------------------------------- */

output "layer_arns" {
  description = "ARNs of the created Lambda layers."
  value       = [for l in aws_lambda_layer_version.this : l.arn]
}

output "layer_names" {
  description = "Names of the created Lambda layers."
  value       = [for l in aws_lambda_layer_version.this : l.layer_name]
}

output "layer_versions" {
  description = "Version numbers of the created Lambda layers."
  value       = [for l in aws_lambda_layer_version.this : l.version]
}
