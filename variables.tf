/* -----------------------------------------------------------------------------
  FILE: variables.tf
  MODULE: aws/sns-topic

  DESCRIPTION:
    Variables for configuring AWS SNS topics, including topic name, display name,
    FIFO options, encryption, policies, subscriptions, tags, and data protection.
    These variables enable flexible and validated creation of SNS topics within
    the aws/sns-topic Terraform module.
----------------------------------------------------------------------------- */

variable "name" {
  description = "Name of the SNS topic."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.name))
    error_message = "SNS topic name must consist of alphanumeric characters, underscores, or hyphens."
  }
}

variable "display_name" {
  description = "Display name for the SNS topic."
  type        = string
  default     = null

  validation {
    condition     = length(var.display_name) <= 100
    error_message = "Display name must have a maximum length of 100 characters."
  }
}

variable "fifo_topic" {
  description = "Whether this is a FIFO topic."
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Enable content-based deduplication for FIFO topics."
  type        = bool
  default     = false
}

variable "kms_master_key_id" {
  description = "KMS key ID for encryption."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to the SNS topic."
  type        = map(string)
  default     = {}
}

variable "create_topic_policy" {
  description = "Whether to create a topic policy."
  type        = bool
  default     = false
}

variable "topic_policy" {
  description = "Inline topic policy JSON."
  type        = string
  default     = null

  validation {
    condition     = (!var.create_topic_policy || var.topic_policy == null || can(jsondecode(var.topic_policy)))
    error_message = "If create_topic_policy is true and topic_policy is set, it must be a valid JSON string."
  }
}

variable "topic_policy_file_path" {
  description = "Path to topic policy JSON file."
  type        = string
  default     = null

  validation {
    condition     = (!var.create_topic_policy || var.topic_policy_file_path == null || can(file(var.topic_policy_file_path)))
    error_message = "If create_topic_policy is true and topic_policy_file_path is set, it must be a valid file path."
  }
}

variable "subscriptions" {
  description = "List of subscription objects."
  type = list(object({
    protocol               = string
    endpoint               = string
    endpoint_auto_confirms = optional(bool, false)
    raw_message_delivery   = optional(bool, false)
  }))
  default = []

  validation {
    condition     = alltrue([for sub in var.subscriptions : can(regex("^(http|https|sqs|email|lambda)$", sub.protocol))])
    error_message = "Each subscription protocol must be one of: http, https, sqs, email, lambda."
  }
}

variable "create_data_protection_policy" {
  description = "Whether to create a data protection policy."
  type        = bool
  default     = false
}

variable "data_protection_policy" {
  description = "Inline data protection policy JSON."
  type        = string
  default     = null

  validation {
    condition     = (!var.create_data_protection_policy || var.data_protection_policy == null || can(jsondecode(var.data_protection_policy)))
    error_message = "When var.create_data_protection_policy is true and var.data_protection_policy_file_path is null, then you're setting a data protection policy using an inline policy and so var.data_protection_policy must be a valid JSON string."
  }
}

variable "data_protection_policy_file_path" {
  description = "Path to data protection policy JSON file."
  type        = string
  default     = null

  validation {
    condition     = (!var.create_data_protection_policy || var.data_protection_policy_file_path == null || can(file(var.data_protection_policy_file_path)))
    error_message = "When var.create_data_protection_policy is true and var.data_protection_policy is null, then you're setting a data protection policy using a file and so var.data_protection_policy_file_path must be a valid file path."
  }
}
