/* -----------------------------------------------------------------------------
  FILE: outputs.tf
  MODULE: aws/sns-topic

  DESCRIPTION:
    Outputs for the SNS topic module, including ARN, name, and ID of the created
    topic resource.
----------------------------------------------------------------------------- */

output "topic_arn" {
  description = "ARN of the SNS topic."
  value       = aws_sns_topic.this.arn
}

output "topic_name" {
  description = "Name of the SNS topic."
  value       = aws_sns_topic.this.name
}

output "topic_id" {
  description = "ID of the SNS topic."
  value       = aws_sns_topic.this.id
}
