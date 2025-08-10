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

variable "layers_map" {
  description = "A layer configuration map holding the details for each layer to be created. Each key is the logical name of the layer, and the value is an object containing options such as Python requirements, runtime, description, and compatible architectures."
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
}
