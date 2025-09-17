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

variable "exclude_patterns" {
  description = "List of glob patterns for files/directories to exclude from source code hash calculation. These files won't trigger Lambda redeployment when changed."
  type        = list(string)
  default = [
    "**/__pycache__/**",
    "**/*.pyc",
    "**/*.pyo",
    "**/.git/**",
    "**/.gitignore",
    "**/.DS_Store",
    "**/Thumbs.db",
    "**/.vscode/**",
    "**/.idea/**",
    "**/README.md",
    "**/readme.md",
    "**/*.md",
    "**/tests/**",
    "**/test_*.py",
    "**/*_test.py",
    "**/docs/**",
    "**/.pytest_cache/**",
    "**/node_modules/**",
    "**/.env*",
    "**/tmp/**",
    "**/temp/**"
  ]
}

variable "source_code_hash_enabled" {
  description = "Whether to enable source code hash calculation for change detection. If false, will use timestamp-based triggers (always redeploy)."
  type        = bool
  default     = true
}


/* --------------------------------
   VARIABLES: Lambda Layers
-------------------------------- */

variable "layers_arns" {
  description = "List of ARNs for AWS managed Lambda Layers to attach to the function (e.g., AWS provided layers or layers from other accounts)."
  type        = list(string)
  default     = []

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

variable "environment_variables" {
  description = "Map of environment variables to set for the Lambda function."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to the Lambda function."
  type        = map(string)
  default     = {}
}


/* --------------------------------
   VARIABLES: Lambda Trigger
-------------------------------- */

variable "create_eventbridge_trigger" {
  description = "Whether to create an EventBridge rule to trigger the Lambda function based on a cron expression."
  type        = bool
  default     = false
}

variable "cron_expression" {
  description = "Cron expression to schedule the Lambda function using EventBridge (e.g., cron(0 12 * * ? *))."
  type        = string
  default     = ""

  validation {
    condition     = var.create_eventbridge_trigger == false || (var.create_eventbridge_trigger == true && can(regex("^cron\\(.*\\)$", var.cron_expression)))
    error_message = "If create_eventbridge_trigger is true, cron_expression must be a valid cron expression in the format cron(...)."
  }
}
