/* -----------------------------------------------------------------------------
  FILE: main.tf
  MODULE: aws/sqs-queue

  DESCRIPTION:
    This Terraform module creates AWS SQS queues based on the provided
    configuration. It supports various queue settings, including visibility
    timeout, message retention, and dead-letter queue configuration.

  RESOURCES:
    - aws_sqs_queue.this:
      Creates the main SQS queue with specified attributes.

    - aws_sqs_queue.dlq:
      Creates a dead-letter queue if enabled, which is used for messages that
      cannot be processed successfully.

----------------------------------------------------------------------------- */

resource "aws_sqs_queue" "this" {
  # Common queue configuration (either standard or FIFO)
  name                       = var.name
  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = var.message_retention_seconds
  delay_seconds              = var.delay_seconds
  max_message_size           = var.max_message_size
  receive_wait_time_seconds  = var.receive_wait_time_seconds

  # FIFO queue configuration (if applicable)
  fifo_queue                  = var.enable_fifo_queue
  content_based_deduplication = var.content_based_deduplication
  deduplication_scope         = var.deduplication_scope
  fifo_throughput_limit       = var.fifo_throughput_limit

  # Encryption configuration
  sqs_managed_sse_enabled           = var.sqs_managed_sse_enabled
  kms_master_key_id                 = var.kms_master_key_id
  kms_data_key_reuse_period_seconds = var.kms_data_key_reuse_period_seconds
}


/*
TODOS:
  - Access policy configuration
  - Redrive policy configuration
  - DLQ configuration
*/
