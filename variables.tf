/* --------------------------------------------------------
FILE: variables.tf @ aws/dynamodb-table module

Variables used in the aws/dynamodb-table module for
definition and creation of tables in DynamoDB
-------------------------------------------------------- */

variable "name" {
  description = "Name of the table to be created in DynamoDB"
  type        = string
}

variable "hash_key" {
  description = "Attribute name to be used as primary key (hash key) of the table"
  type        = string
}

variable "range_key" {
  description = "Attribute name to be used as second part of the secondary key (range key) of the table"
  type        = string
  default     = null
}

variable "attributes" {
  description = "Information about attributes used in index (hash and range key) of the table in the format [{'name': 'field_name', 'type': 'field_type'}]. All indexes defined for the table (hash key and range key) must mandatorily be contained as elements of this attribute list."
  type        = list(map(string))
  default     = []

  validation {
    condition = alltrue([
      for type in distinct([
        for attribute_map in var.attributes : attribute_map.type
      ]) : contains(["S", "N", "B"], type)
    ])
    error_message = "DynamoDB table attributes need to be defined with primitive types that refer to: 'S' for strings, 'N' for numeric and 'B' for binary."
  }
}

variable "billing_mode" {
  description = "Type of billing associated with consumption of items from the created table"
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = var.billing_mode == "PROVISIONED" || var.billing_mode == "PAY_PER_REQUEST"
    error_message = "The variable value must be 'PROVISIONED' or 'PAY_PER_REQUEST'."
  }
}
