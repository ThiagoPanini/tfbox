/* -----------------------------------------------------------------------------
  FILE: outputs.tf
  MODULE: aws/lambda-function

  DESCRIPTION:
    Outputs for the Lambda function module, including function ARN, name, and IAM role ARN.
----------------------------------------------------------------------------- */

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.this.arn
}

output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.this.function_name
}

output "function_role_arn" {
  description = "IAM role ARN used by the Lambda function"
  value       = aws_lambda_function.this.role
}
