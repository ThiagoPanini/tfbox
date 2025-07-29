/* -----------------------------------------------------------------------------
  FILE: outputs.tf
  MODULE: aws/sqs-queue

  DESCRIPTION:
    Outputs for the SQS queue module, including queue name, ARN, URL, and DLQ
    ARN if created.
----------------------------------------------------------------------------- */

output "queue_name" {
  description = "Name of the SQS queue."
  value       = aws_sqs_queue.source.name
}

output "queue_arn" {
  description = "ARN of the SQS queue."
  value       = aws_sqs_queue.source.arn
}

output "queue_url" {
  description = "URL of the SQS queue."
  value       = aws_sqs_queue.source.url
}

output "dlq_arn" {
  description = "ARN of the dead-letter queue, if created."
  value       = try(aws_sqs_queue.dlq.arn, null)
}
