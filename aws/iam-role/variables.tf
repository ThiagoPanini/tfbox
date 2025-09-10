/* -----------------------------------------------------------------------------
  FILE: variables.tf
  MODULE: aws/iam-role

  DESCRIPTION:
    Variables for configuring IAM role resources, including role name, trust
    policy, policy template directories, template variables, and existing policy
    ARNs. These variables enable flexible and validated creation of IAM roles
    and associated policies within the aws/iam-role Terraform module.
----------------------------------------------------------------------------- */

variable "policies_template_config" {
  description = "Configuration for IAM policy templates, including source and destination directories and template variables."
  type = object(
    {
      templates_source_dir = string
      templates_vars       = map(string)
    }
  )
}

variable "roles_config" {
  description = "List of configuration maps for each IAM role that should be created in a single module call, including role name, trust policy file path and associated policy ARNs."
  type = list(
    object(
      {
        role_name             = string
        trust_policy_filepath = string
        policies_arns         = list(string)
      }
    )
  )
}

variable "tags" {
  description = "Tags to apply to the IAM role."
  type        = map(string)
  default     = {}
}
