/* -----------------------------------------------------------------------------
  FILE: variables.tf
  MODULE: aws/lambda-layer

  DESCRIPTION:
    Variables for configuring AWS Lambda layers, including layer information,
    mount point for layer builds, and cleanup options. These variables enable
    flexible and validated creation of Lambda layers within the aws/lambda-layer
    Terraform module.
----------------------------------------------------------------------------- */

variable "layers_mount_point" {
  description = "The directory where layers will be built. This is a temporary directory used during the layer creation process. If this value is set to an empty string, the module will use a default path based on the root of the Terraform project."
  type        = string
  default     = ""
}

variable "layers_info" {
  description = "A layer configuration map holding the details for each layer to be created. Each key is the logical name of the layer, and the value is an object containing options such as Python requirements, runtime, description, and compatible architectures."
  type = map(
    object(
      {
        python_requirements      = list(string)
        runtime                  = string
        description              = optional(string, "A lambda layer created by Terraform module at git::https://github.com/ThiagoPanini/tfbox.git?ref=aws/lambda-layer")
        compatible_architectures = optional(list(string), ["x86_64"])
        license_info             = optional(string, null)
      }
    )
  )
}

variable "cleanup_after_build" {
  description = "If true, the module will remove the temporary build directories after creating the Lambda layers."
  type        = bool
  default     = true
}
