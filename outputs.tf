/* -----------------------------------------------------------------------------
  FILE: outputs.tf
  MODULE: aws/dynamodb-table

  DESCRIPTION:
    Outputs for the DynamoDB table module, including table name, ARN, and ID.
----------------------------------------------------------------------------- */

output "table_name" {
  description = "Name of the DynamoDB table."
  value       = aws_dynamodb_table.this.name
}

output "table_arn" {
  description = "ARN of the DynamoDB table."
  value       = aws_dynamodb_table.this.arn
}

output "table_id" {
  description = "ID of the DynamoDB table."
  value       = aws_dynamodb_table.this.id
}
