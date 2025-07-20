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

variable "visibility_timeout_seconds" {
  description = "The visibility timeout for the queue (in seconds)."
  type        = number
  default     = 30
}

variable "message_retention_seconds" {
  description = "The length of time, in seconds, that Amazon SQS retains a message."
  type        = number
  default     = 345600
}

variable "delay_seconds" {
  description = "The time in seconds that the delivery of all messages in the queue will be delayed."
  type        = number
  default     = 0
}

variable "max_message_size" {
  description = "The limit of how many bytes a message can contain before Amazon SQS rejects it."
  type        = number
  default     = 262144
}

variable "receive_wait_time_seconds" {
  description = "The time for which a ReceiveMessage call will wait for a message to arrive."
  type        = number
  default     = 0
}

variable "fifo_queue" {
  description = "Boolean to enable FIFO queue."
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Enables content-based deduplication for FIFO queues."
  type        = bool
  default     = false
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

