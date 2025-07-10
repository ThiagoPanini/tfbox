/* --------------------------------------------------------
FILE: variables.tf @ aws/lambda-layer module

Variables used in the aws/lambda-layer module for
definition, creation and configuration of layers (and versions) of
layers to be used in Lambda functions on AWS
-------------------------------------------------------- */

variable "flag_create_from_dir" {
  description = "Flag to indicate if the layer(s) will be created through .zip file(s) available in a specific path provided by the user."
  type        = bool
  default     = true

  validation {
    condition     = var.flag_create_from_dir || var.flag_create_from_input
    error_message = "At least one of the variable values var.flag_create_from_dir or var.flag_create_from_input needs to be true. The user needs to choose whether to create layer(s) through .zip files saved in a specific directory (var.flag_create_from_dir = true) or if they want to create layer(s) by passing a list of parameter maps with the details of the layer(s) to be created directly to the module call (var.flag_create_from_input = true)."
  }
}

variable "flag_create_from_input" {
  description = "Flag to indicate if the layer(s) will be created through a map (dictionary) passed by the user containing all information of the layer(s)."
  type        = bool
  default     = false
}

variable "compatible_architectures" {
  description = "List containing all compatible architectures for the Lambda layer version to be created."
  type        = list(string)
  default     = ["arm64", "x86_64"]
}

variable "compatible_runtimes" {
  description = "List containing all compatible runtimes for the layer version to be created"
  type        = list(string)
}

variable "license_info" {
  description = "Information related to software license related to the layer. Can be in SPDX identifier format (e.g.: MIT), a URL hosting the license (e.g.: https://opensource.org/licenses/MIT) or the full text of the license."
  type        = string
  default     = null
}

variable "layers_source_code_dir" {
  description = "Directory containing all .zip files to be used for creating layers."
  type        = string
  default     = ""

  validation {
    condition     = var.flag_create_from_input || (var.flag_create_from_dir && var.layers_source_code_dir != "")
    error_message = "When var.flag_create_from_dir is true and var.flag_create_from_input is false, the variable var.layers_source_code_dir needs to be explicitly defined by the user with a directory path where the .zip files of the layers to be created are stored."
  }
}

variable "layers_input_params" {
  description = "List of map(s) (dictionary) containing the necessary information for creating layers. This dictionary can contain all parameters accepted by the aws_lambda_layer_version resource (check documentation). The content of this variable is interpreted by the module and used as basis for parameterization of the aws_lambda_layer_version resource."
  type        = list(map(string))
  default     = []

  validation {
    condition     = (var.flag_create_from_input && var.layers_input_params != [])
    error_message = "When var.flag_create_from_input is true, the variable var.layers_input_params needs to be explicitly defined by the user with a list of maps containing the information of the layer(s) to be created. ${var.flag_create_from_input && var.layers_input_params == []}"
  }
}


output "condition" {
  value = (var.flag_create_from_input && var.layers_input_params != [])
}
