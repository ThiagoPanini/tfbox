/* -----------------------------------------------------------------------------
  FILE: variables.tf
  MODULE: aws/lambda-layer

  DESCRIPTION:
    Variables for configuring AWS Lambda layers, including layer information,
    mount point for layer builds, and cleanup options. These variables enable
    flexible and validated creation of Lambda layers within the aws/lambda-layer
    Terraform module.
----------------------------------------------------------------------------- */

variable "layers_programming_language" {
  description = "The programming language for the Lambda layers. Currently, only 'python' is supported."
  type        = string
  default     = "python"

  validation {
    condition     = var.layers_programming_language == "python"
    error_message = "Currently, only 'python' is supported as the programming language for Lambda layers."
  }
}

variable "layers_config" {
  description = "A configuration object for the Lambda layers, including the mount point for building layers and whether to clean up temporary build directories after layer creation."
  type = list(
    object(
      {
        name                     = string
        requirements             = list(string)
        runtime                  = list(string)
        description              = optional(string, "A lambda layer powered by tfbox")
        compatible_architectures = optional(list(string), ["x86_64"])
        license_info             = optional(string, null)
      }
    )
  )
}
