/* -----------------------------------------------------------------------------
  FILE: variables.tf
  MODULE: aws/iam-role

  DESCRIPTION:
    Variables for configuring IAM role resources, including role name, trust
    policy, policy template directories, template variables, and existing policy
    ARNs. These variables enable flexible and validated creation of IAM roles
    and associated policies within the aws/iam-role Terraform module.
----------------------------------------------------------------------------- */

variable "role_name" {
  description = "Name of the IAM role to be created."
  type        = string
}

variable "trust_policy_filepath" {
  description = "Path to the JSON file that defines the trust policy to be associated with the role."
  type        = string
}

variable "policy_templates_source_dir" {
  description = "Input directory containing all templates defined for creating IAM policies."
  type        = string
}

variable "policy_templates_destination_dir" {
  description = "Output directory to be used to store all template files already rendered after variable substitution. If not passed explicitly, the template output directory will be automatically created by the module at the same level as the path defined in var.policies_templates_source_dir"
  type        = string
  default     = ""
}

variable "policy_templates_vars" {
  description = "Variables and their respective values to be substituted in the provided policy templates."
  type        = map(string)
}

variable "existent_policy_arns" {
  description = "ARNs of existing IAM policies to be linked in the role created through this module call."
  type        = list(string)
  default     = []
}
