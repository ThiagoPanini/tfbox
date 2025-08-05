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

variable "source_code_path" {
  description = "The local path where the Lambda source code is located (e.g 'app', 'app/src' or 'app/src/my_app_slice')."
  type        = string

  validation {
    condition     = !endswith(var.source_code_path, "/")
    error_message = "The source code path must not end with a slash ('/')."
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

variable "cleanup_after_build" {
  description = "Whether to cleanup the zip file after deployment."
  type        = bool
  default     = true
}

/*
variable "create_iam_role" {
  description = "Whether to create a new IAM role for the Lambda function"
  type        = bool
  default     = true
}

variable "role_arn" {
  description = "IAM role ARN for Lambda execution"
  type        = string
  default     = null

  validation {
    condition     = var.create_iam_role || can(regex("^arn:aws:iam::[0-9]{12}:role/.+$", var.role_arn))
    error_message = "If create_iam_role is false, role_arn must be a valid IAM role ARN."
  }
}




variable "handler" {
  description = "Function entrypoint handler"
  type        = string
}

variable "source_path" {
  description = "Local path to Lambda source code directory to be zipped."
  type        = string
}

variable "output_zip_path" {
  description = "Path to output zip file for Lambda deployment package."
  type        = string
  default     = "./app/lambda_function_package.zip"
}

variable "cleanup_after_build" {
  description = "Whether to cleanup the zip file after deployment."
  type        = bool
  default     = true
}

variable "filename" {
  description = "Path to local deployment package (zip)"
  type        = string
  default     = null
}

variable "s3_bucket" {
  description = "S3 bucket for deployment package"
  type        = string
  default     = null
}

variable "s3_key" {
  description = "S3 key for deployment package"
  type        = string
  default     = null
}

variable "source_code_hash" {
  description = "Base64-encoded SHA256 hash of deployment package"
  type        = string
  default     = null
}

variable "layers" {
  description = "List of Lambda Layer ARNs"
  type        = list(string)
  default     = []
}

variable "memory_size" {
  description = "Amount of memory in MB"
  type        = number
  default     = 128
}

variable "timeout" {
  description = "Function timeout in seconds"
  type        = number
  default     = 3
}

variable "environment_variables" {
  description = "Map of environment variables"
  type        = map(string)
  default     = {}
}

variable "subnet_ids" {
  description = "List of VPC subnet IDs"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "List of VPC security group IDs"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "tracing_mode" {
  description = "X-Ray tracing mode (Active/PassThrough)"
  type        = string
  default     = "PassThrough"
}

variable "log_retention_in_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
}

variable "enable_alias" {
  description = "Enable Lambda alias creation"
  type        = bool
  default     = false
}

variable "alias_name" {
  description = "Name of the Lambda alias"
  type        = string
  default     = "live"
}

variable "event_sources" {
  description = "List of event source mappings (objects with arn, enabled)"
  type        = list(object({ arn = string, enabled = bool }))
  default     = []
}
*/
