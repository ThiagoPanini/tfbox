/* -----------------------------------------------------------------------------
  FILE: outputs.tf
  MODULE: aws/iam-role

  DESCRIPTION:
    Outputs for the IAM role module, including role name, ARN, and attached
    policy ARNs.
----------------------------------------------------------------------------- */

output "roles_arns" {
  description = "ARNs of the created IAM roles."
  value       = { for role in aws_iam_role.roles : role.name => role.arn }
}

output "policies_arns" {
  description = "ARNs of the policies attached to the IAM roles."
  value       = { for policy in aws_iam_policy.policies : policy.name => policy.arn }
}
