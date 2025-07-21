/* -----------------------------------------------------------------------------
  FILE: variables.tf
  MODULE: aws/sqs-queue

  DESCRIPTION:
    Variables for configuring AWS SQS queues, including queue information,
    visibility timeout, and dead-letter queue options. These variables enable
    flexible and validated creation of SQS queues within the aws/sqs-queue
    Terraform module.
----------------------------------------------------------------------------- */

variable "name" {
  description = "Name of the SQS queue to be created."
  type        = string
}

variable "type" {
  description = "Type of the SQS queue. Can be 'standard' or 'fifo'."
  type        = string
  default     = "standard"

  validation {
    condition     = lower(var.type) == "standard" || lower(var.type) == "fifo"
    error_message = "Queue type must be either 'standard' or 'fifo'."
  }
}

variable "visibility_timeout_seconds" {
  description = "The visibility timeout for the queue (in seconds). Visibility timeout sets the length of time that a message received from a queue (by one consumer) will not be visible to the other message consumers."
  type        = number
  default     = 30

  validation {
    condition     = var.visibility_timeout_seconds >= 0 && var.visibility_timeout_seconds <= 43200
    error_message = "Visibility timeout must be between 0 seconds and 43200 seconds (12 hours)."
  }
}

variable "message_retention_seconds" {
  description = "The length of time, in seconds, that Amazon SQS retains a message that does not get deleted."
  type        = number
  default     = 345600

  validation {
    condition     = var.message_retention_seconds >= 60 && var.message_retention_seconds <= 1209600
    error_message = "Message retention must be between 60 seconds (1 minute) and 1209600 seconds (14 days)."
  }
}

variable "delay_seconds" {
  description = "The time, in seconds, that the delivery of all messages in the queue will be delayed. Any messages sent to the queue remain invisible to consumers for the duration of the delay period"
  type        = number
  default     = 0

  validation {
    condition     = var.delay_seconds >= 0 && var.delay_seconds <= 900
    error_message = "Delay seconds must be between 0 and 900 seconds (15 minutes)."
  }
}

variable "max_message_size" {
  description = "The limit of how many bytes a message can contain before Amazon SQS rejects it."
  type        = number
  default     = 262144

  validation {
    condition     = var.max_message_size >= 1024 && var.max_message_size <= 262144
    error_message = "Max message size must be between 1024 (1 KB) and 262144 bytes (256 KB)."
  }
}

variable "receive_wait_time_seconds" {
  description = "The time for which a ReceiveMessage call will wait for a message to arrive. In other words, the maximum amount of time that polling will wait for messages to become available to receive."
  type        = number
  default     = 0

  validation {
    condition     = var.receive_wait_time_seconds >= 0 && var.receive_wait_time_seconds <= 20
    error_message = "Receive wait time must be between 0 and 20 seconds."
  }
}

variable "enable_fifo_queue" {
  description = "Boolean to enable FIFO queue."
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Enables content-based deduplication for FIFO queues."
  type        = bool
  default     = false
}

variable "deduplication_scope" {
  description = "The deduplication scope for FIFO queues. Can be 'messageGroup' or 'queue'."
  type        = string
  default     = "messageGroup"

  validation {
    condition     = var.deduplication_scope == "messageGroup" || var.deduplication_scope == "queue"
    error_message = "Deduplication scope must be either 'messageGroup' or 'queue'."
  }
}

variable "fifo_throughput_limit" {
  description = "The throughput limit for FIFO queues. Can be 'perMessageGroupId' or 'perQueue'."
  type        = string
  default     = "perQueue"

  validation {
    condition     = var.fifo_throughput_limit == "perMessageGroupId" || var.fifo_throughput_limit == "perQueue"
    error_message = "FIFO Throughput limit must be either 'perMessageGroupId' or 'perQueue'."
  }
}

variable "sqs_managed_sse_enabled" {
  description = "Boolean to enable SQS managed server-side encryption (SSE)."
  type        = bool
  default     = false
}

variable "kms_master_key_id" {
  description = "The ID of the KMS master key used for server-side encryption (SSE) if SQS managed SSE is not enabled."
  type        = string
  default     = ""
}

variable "kms_data_key_reuse_period_seconds" {
  description = "The length of time, in seconds, for which the KMS data key is cached. This is only applicable if KMS master key is used."
  type        = number
  default     = 300

  validation {
    condition     = var.kms_data_key_reuse_period_seconds >= 60 && var.kms_data_key_reuse_period_seconds <= 86400
    error_message = "KMS data key reuse period must be between 60 seconds (1 minute) and 86400 seconds (1 day)."
  }
}


variable "enable_dead_letter_queue" {
  description = "Whether to create and attach a dead letter queue."
  type        = bool
  default     = false
}

variable "max_receive_count" {
  description = "The number of times a message is delivered to the source queue before being moved to the dead-letter queue."
  type        = number
  default     = 5
}

