/* -----------------------------------------------------------------------------
  FILE: variables.tf
  MODULE: aws/sqs-queue

  DESCRIPTION:
    Variables for configuring AWS SQS queues, including queue information,
    visibility timeout, and dead-letter queue options. These variables enable
    flexible and validated creation of SQS queues within the aws/sqs-queue
    Terraform module.
----------------------------------------------------------------------------- */

/* --------------------------------
  SOURCE QUEUE VARIABLES
-------------------------------- */

variable "name" {
  description = "Name of the SQS queue to be created."
  type        = string
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

variable "create_fifo_queue" {
  description = "Boolean to create FIFO queue."
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

variable "create_access_policy" {
  description = "Boolean to enable creation of access policy for the SQS queue."
  type        = bool
  default     = false
}

variable "access_policy_configuration_type" {
  description = "Type of access policy configuration. Can be 'inline' or 'file'."
  type        = string
  default     = "file"

  validation {
    condition     = lower(var.access_policy_configuration_type) == "inline" || lower(var.access_policy_configuration_type) == "file"
    error_message = "Access policy configuration type must be either 'inline' or 'file'."
  }
}

variable "access_policy" {
  description = "The access policy for the SQS queue. This is required if access_policy_configuration_type is 'inline'."
  type        = string
  default     = ""

  validation {
    condition     = var.create_access_policy && var.access_policy_configuration_type == "inline" ? var.access_policy != "" : true
    error_message = "Access policy must be provided if create_access_policy is true and access_policy_configuration_type is 'inline'."
  }
}

variable "access_policy_file_path" {
  description = "The file path for the access policy if access_policy_configuration_type is 'file'."
  type        = string
  default     = ""

  validation {
    condition     = var.create_access_policy && var.access_policy_configuration_type == "file" ? var.access_policy_file_path != "" : true
    error_message = "Access policy file path must be provided if create_access_policy is true and access_policy_configuration_type is 'file'."
  }
}


/* --------------------------------
  DEAD-LETTER QUEUE VARIABLES
-------------------------------- */

variable "create_dead_letter_queue" {
  description = "Whether to create and attach a dead letter queue."
  type        = bool
  default     = true
}

variable "max_receive_count" {
  description = "The number of times a message is delivered to the source queue before being moved to the dead-letter queue."
  type        = number
  default     = 5
}

variable "dlq_visibility_timeout_seconds" {
  description = "The visibility timeout for the queue (in seconds). Visibility timeout sets the length of time that a message received from a queue (by one consumer) will not be visible to the other message consumers."
  type        = number
  default     = 30

  validation {
    condition     = var.dlq_visibility_timeout_seconds >= 0 && var.dlq_visibility_timeout_seconds <= 43200
    error_message = "Visibility timeout for DLQ must be between 0 seconds and 43200 seconds (12 hours)."
  }
}

variable "dlq_message_retention_seconds" {
  description = "The length of time, in seconds, that Amazon SQS retains a message that does not get deleted."
  type        = number
  default     = 345600

  validation {
    condition     = var.dlq_message_retention_seconds >= 60 && var.dlq_message_retention_seconds <= 1209600
    error_message = "Message retention for DLQ must be between 60 seconds (1 minute) and 1209600 seconds (14 days)."
  }
}

variable "dlq_delay_seconds" {
  description = "The time, in seconds, that the delivery of all messages in the DLQ will be delayed. Any messages sent to the queue remain invisible to consumers for the duration of the delay period"
  type        = number
  default     = 0

  validation {
    condition     = var.dlq_delay_seconds >= 0 && var.dlq_delay_seconds <= 900
    error_message = "Delay seconds for DLQ must be between 0 and 900 seconds (15 minutes)."
  }
}

variable "dlq_max_message_size" {
  description = "The limit of how many bytes a message can contain before Amazon SQS rejects it."
  type        = number
  default     = 262144

  validation {
    condition     = var.dlq_max_message_size >= 1024 && var.dlq_max_message_size <= 262144
    error_message = "Max message size must be between 1024 (1 KB) and 262144 bytes (256 KB)."
  }
}

variable "dlq_receive_wait_time_seconds" {
  description = "The time for which a ReceiveMessage call will wait for a message to arrive. In other words, the maximum amount of time that polling will wait for messages to become available to receive."
  type        = number
  default     = 0

  validation {
    condition     = var.dlq_receive_wait_time_seconds >= 0 && var.dlq_receive_wait_time_seconds <= 20
    error_message = "Receive wait time for DLQ must be between 0 and 20 seconds."
  }
}

variable "dlq_content_based_deduplication" {
  description = "Enables content-based deduplication for DLQ FIFO queues."
  type        = bool
  default     = false
}

variable "dlq_deduplication_scope" {
  description = "The deduplication scope for DLQ FIFO queues. Can be 'messageGroup' or 'queue'."
  type        = string
  default     = "messageGroup"

  validation {
    condition     = var.dlq_deduplication_scope == "messageGroup" || var.dlq_deduplication_scope == "queue"
    error_message = "Deduplication scope must be either 'messageGroup' or 'queue'."
  }
}

variable "dlq_fifo_throughput_limit" {
  description = "The throughput limit for DLQ FIFO queues. Can be 'perMessageGroupId' or 'perQueue'."
  type        = string
  default     = "perQueue"

  validation {
    condition     = var.dlq_fifo_throughput_limit == "perMessageGroupId" || var.dlq_fifo_throughput_limit == "perQueue"
    error_message = "DLQ FIFO Throughput limit must be either 'perMessageGroupId' or 'perQueue'."
  }
}

variable "dlq_sqs_managed_sse_enabled" {
  description = "Boolean to enable SQS managed server-side encryption (SSE) for DLQ."
  type        = bool
  default     = false
}

variable "dlq_kms_master_key_id" {
  description = "The ID of the KMS master key used for server-side encryption (SSE) if SQS managed SSE is not enabled for DLQ."
  type        = string
  default     = ""
}

variable "dlq_kms_data_key_reuse_period_seconds" {
  description = "The length of time, in seconds, for which the KMS data key is cached. This is only applicable if KMS master key is used."
  type        = number
  default     = 300

  validation {
    condition     = var.dlq_kms_data_key_reuse_period_seconds >= 60 && var.dlq_kms_data_key_reuse_period_seconds <= 86400
    error_message = "KMS data key reuse period for DLQ must be between 60 seconds (1 minute) and 86400 seconds (1 day)."
  }
}
