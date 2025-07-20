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
  name                        = var.name
  visibility_timeout_seconds  = var.visibility_timeout_seconds
  message_retention_seconds   = var.message_retention_seconds
  delay_seconds               = var.delay_seconds
  max_message_size            = var.max_message_size
  receive_wait_time_seconds   = var.receive_wait_time_seconds
  fifo_queue                  = var.fifo_queue
  content_based_deduplication = var.content_based_deduplication

  dynamic "redrive_policy" {
    for_each = var.enable_dead_letter_queue ? [1] : []
    content {
      dead_letter_target_arn = aws_sqs_queue.dlq[0].arn
      max_receive_count      = var.max_receive_count
    }
  }
}

resource "aws_sqs_queue" "dlq" {
  count      = var.enable_dead_letter_queue ? 1 : 0
  name       = "${var.name}-dlq"
  fifo_queue = var.fifo_queue
}

/* IDEIAS:
    - FIFO enabled and FIFO configuration
    - DLQ Configuration
    - Encryption configuration (KMS vs SSE)

Ou então:
    - Variable for queue type (standard vs FIFO)
    - Variable for queue attributes (visibility timeout, message retention, and FIFO config) in a JSON
    - Variable for dead-letter queue configuration (enabled/disabled, max receive count)
    - Variable for encryption configuration (KMS key ARN or SSE)
    - Variable for tags to apply to the queue
    - Variable for queue policy (if needed)
*/
