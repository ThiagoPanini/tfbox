/* -----------------------------------------------------------------------------
  FILE: main.tf
  MODULE: aws/sqs-queue

  DESCRIPTION:
    This Terraform module provisions AWS SQS queues with flexible configuration
    options. It supports both standard and FIFO queues, optional dead-letter
    queues (DLQ), encryption (SSE-SQS or KMS), configurable access policies
    (inline or file-based), and advanced redrive and deduplication settings.

  RESOURCES:
    - aws_sqs_queue.source:
        Creates the primary SQS queue with configurable attributes, supporting
        both standard and FIFO types, encryption, access policies, and optional
        redrive policy for DLQ integration.

    - aws_sqs_queue.dlq:
        Optionally creates a dead-letter queue (DLQ) with matching configuration
        for FIFO or standard, used for handling messages that cannot be processed
        successfully.

    - aws_sqs_queue_redrive_allow_policy.dlq_redrive_allow_policy:
        Optionally creates a redrive allow policy for the DLQ, permitting the
        source queue to redrive messages back to the DLQ when required.
----------------------------------------------------------------------------- */

# Main SQS queue resource
resource "aws_sqs_queue" "source" {
  # Common queue configuration (either standard or FIFO)
  name                       = var.create_fifo_queue ? "${var.name}.fifo" : var.name
  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = var.message_retention_seconds
  delay_seconds              = var.delay_seconds
  max_message_size           = var.max_message_size
  receive_wait_time_seconds  = var.receive_wait_time_seconds

  # FIFO queue configuration (conditions are applied to avoind conflicts in Terraform configuration)
  fifo_queue                  = var.create_fifo_queue
  content_based_deduplication = var.create_fifo_queue ? var.content_based_deduplication : null
  deduplication_scope         = var.create_fifo_queue ? var.deduplication_scope : null
  fifo_throughput_limit       = var.create_fifo_queue ? var.fifo_throughput_limit : null

  # Encryption configuration (conditions are applied to avoid conflicts in Terraform configuration)
  sqs_managed_sse_enabled           = var.sqs_managed_sse_enabled ? true : null
  kms_master_key_id                 = var.sqs_managed_sse_enabled ? null : var.kms_master_key_id
  kms_data_key_reuse_period_seconds = var.sqs_managed_sse_enabled ? null : var.kms_data_key_reuse_period_seconds

  # Access policy configuration
  policy = !var.create_access_policy ? null : lower(var.access_policy_configuration_type) == "inline" ? var.access_policy : file(var.access_policy_file_path)

  # Redrive policy configuration
  redrive_policy = var.create_dead_letter_queue ? jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[0].arn,
    maxReceiveCount     = var.max_receive_count
  }) : null
}

# Dead-letter queue resource
resource "aws_sqs_queue" "dlq" {
  count = var.create_dead_letter_queue ? 1 : 0

  # Common queue configuration (either standard or FIFO)
  name                       = var.create_fifo_queue ? "${var.name}-dlq.fifo" : "${var.name}-dlq"
  visibility_timeout_seconds = var.copy_dlq_config_from_source_queue ? var.visibility_timeout_seconds : var.dlq_visibility_timeout_seconds
  message_retention_seconds  = var.copy_dlq_config_from_source_queue ? var.message_retention_seconds : var.dlq_message_retention_seconds
  delay_seconds              = var.copy_dlq_config_from_source_queue ? var.delay_seconds : var.dlq_delay_seconds
  max_message_size           = var.copy_dlq_config_from_source_queue ? var.max_message_size : var.dlq_max_message_size
  receive_wait_time_seconds  = var.copy_dlq_config_from_source_queue ? var.receive_wait_time_seconds : var.dlq_receive_wait_time_seconds

  # If source queue is FIFO, DLQ must also be FIFO
  fifo_queue                  = var.create_fifo_queue
  content_based_deduplication = !var.create_fifo_queue ? null : var.copy_dlq_config_from_source_queue ? var.content_based_deduplication : var.dlq_content_based_deduplication
  deduplication_scope         = !var.create_fifo_queue ? null : var.copy_dlq_config_from_source_queue ? var.deduplication_scope : var.dlq_deduplication_scope
  fifo_throughput_limit       = !var.create_fifo_queue ? null : var.copy_dlq_config_from_source_queue ? var.fifo_throughput_limit : var.dlq_fifo_throughput_limit

  # Encryption configuration (conditions are applied to avoid conflicts in Terraform configuration)
  sqs_managed_sse_enabled           = var.sqs_managed_sse_enabled ? true : null
  kms_master_key_id                 = var.sqs_managed_sse_enabled ? null : var.kms_master_key_id
  kms_data_key_reuse_period_seconds = var.sqs_managed_sse_enabled ? null : var.kms_data_key_reuse_period_seconds
}

# Redrive allow policy for DLQ
resource "aws_sqs_queue_redrive_allow_policy" "dlq_redrive_allow_policy" {
  count     = var.create_dead_letter_queue ? 1 : 0
  queue_url = aws_sqs_queue.dlq[0].id

  redrive_allow_policy = jsonencode(
    {
      redrivePermission = "byQueue"
      sourceQueueArns = [
        aws_sqs_queue.source.arn
      ]
    }
  )

  depends_on = [
    aws_sqs_queue.source,
    aws_sqs_queue.dlq
  ]
}
