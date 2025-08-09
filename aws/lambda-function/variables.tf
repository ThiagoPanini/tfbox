/* -----------------------------------------------------------------------------
  FILE: variables.tf
  MODULE: aws/lambda-function

DESCRIPTION:
    Input variables for configuring AWS Lambda functions, including function name,
    handler, runtime, IAM role, deployment package options, layers, VPC settings,
    environment variables, tags, event sources, versioning, alias, monitoring,
    and log retention. These variables enable flexible and validated creation of
    Lambda resources within the aws/lambda-function Terraform module.
----------------------------------------------------------------------------- */


/* --------------------------------
   VARIABLES: Lambda Package
-------------------------------- */

variable "source_code_path" {
  description = "The local path where the Lambda source code is located (e.g 'app', 'app/src' or 'app/src/my_app_slice')."
  type        = string

  validation {
    condition     = !endswith(var.source_code_path, "/")
    error_message = "The source code path must not end with a slash ('/')."
  }
}


/* --------------------------------
   VARIABLES: Lambda Layers
-------------------------------- */

variable "create_lambda_layers" {
  description = "Whether to create Lambda Layers using the aws/lambda-layer module."
  type        = bool
  default     = false
}

variable "layers_map" {
  description = "Map of Lambda Layers to create if create_lambda_layers is true. Each key is the layer name, and the value is an object with layer configuration."
  type = map(
    object(
      {
        requirements             = list(string)
        runtime                  = string
        description              = optional(string, "A lambda layer created by Terraform module at git::https://github.com/ThiagoPanini/tfbox.git?ref=aws/lambda-layer")
        compatible_architectures = optional(list(string), ["x86_64"])
        license_info             = optional(string, null)
      }
    )
  )

  validation {
    condition     = var.create_lambda_layers == false || length(var.layers_map) > 0
    error_message = "If create_lambda_layers is true, lambda_layers_info must contain at least one layer configuration."
  }
}


/* --------------------------------
   VARIABLES: Lambda Function
-------------------------------- */

variable "function_name" {
  description = "Name of the Lambda function"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.function_name)) && length(var.function_name) >= 1 && length(var.function_name) <= 64
    error_message = "Lambda function name must be 1-64 characters long and consist only of alphanumeric characters, underscores, or hyphens."
  }
}

variable "runtime" {
  description = "Lambda runtime (e.g., python3.13, nodejs22.x)"
  type        = string
}

variable "architectures" {
  description = "Lambda code architecture (e.g., x86_64, arm64)"
  type        = list(string)
  default     = ["x86_64"]

  validation {
    condition     = can(regex("^(x86_64|arm64)$", join(",", var.architectures)))
    error_message = "Lambda architectures must be either ['x86_64'] or ['arm64']."
  }
}

variable "role_arn" {
  description = "IAM role ARN for Lambda execution"
  type        = string

  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/.+$", var.role_arn))
    error_message = "role_arn must be a valid IAM role ARN."
  }
}

variable "timeout" {
  description = "Function timeout in seconds"
  type        = number
  default     = 60

  validation {
    condition     = var.timeout >= 1 && var.timeout <= 900
    error_message = "Timeout must be between 1 and 900 seconds."
  }
}

variable "memory_size" {
  description = "Function memory size in MB from 128 MB to 10240 MB (10 GB)"
  type        = number
  default     = 128

  validation {
    condition     = var.memory_size >= 128 && var.memory_size <= 10240
    error_message = "Memory size must be between 128 and 10240 MB."
  }
}

variable "lambda_handler" {
  description = "Lambda function handler (e.g., lambda_function.lambda_handler)."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_.]+$", var.lambda_handler))
    error_message = "Handler must be a valid Python module and function name (e.g., module.function)."
  }
}
